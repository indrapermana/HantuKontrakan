import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';
import '../services/audio_service.dart';
import '../services/error_reporting_service.dart';
import '../services/game_feedback_service.dart';
import '../services/privacy_consent_service.dart';
import '../services/rewarded_ad_service.dart';
import '../services/save_service.dart';
import '../simulation/commands/game_command.dart';
import '../simulation/constants/game_balance.dart';
import '../simulation/game_state_controller.dart';
import '../simulation/models/game_state.dart';
import '../simulation/models/daily_goal_definition.dart';
import '../simulation/models/ghost.dart';
import '../simulation/models/room.dart';
import '../simulation/models/tutorial_step.dart';
import '../simulation/systems/game_rules.dart';
import '../simulation/systems/daily_goal_system.dart';
import '../simulation/systems/happiness_system.dart';
import '../simulation/systems/repair_system.dart';
import '../simulation/systems/rewarded_rent_system.dart';
import 'simulation_runtime.dart';

class GameController extends ChangeNotifier {
  GameController({
    required SaveService saveService,
    AnalyticsService analyticsService = const NoopAnalyticsService(),
    AudioService audioService = const NoopAudioService(),
    ErrorReportingService errorReportingService =
        const NoopErrorReportingService(),
    PrivacyConsentService privacyConsentService =
        const UnavailablePrivacyConsentService(),
    RewardedAdService rewardedAdService = const UnavailableRewardedAdService(),
    GameFeedbackService feedbackService = const NoopGameFeedbackService(),
    GameClock clock = const SystemGameClock(),
    int randomSeed = GameBalance.defaultRandomSeed,
  }) : _saveService = saveService,
       _analyticsService = analyticsService,
       _audioService = audioService,
       _errorReportingService = errorReportingService,
       _privacyConsentService = privacyConsentService,
       _rewardedAdService = rewardedAdService,
       _feedbackService = feedbackService,
       _clock = clock,
       _randomSource = SeededRandomSource(randomSeed);

  final SaveService _saveService;
  final AnalyticsService _analyticsService;
  final AudioService _audioService;
  final ErrorReportingService _errorReportingService;
  final PrivacyConsentService _privacyConsentService;
  final RewardedAdService _rewardedAdService;
  final GameFeedbackService _feedbackService;
  final GameClock _clock;
  final SeededRandomSource _randomSource;
  int _rentClaimSequence = 0;
  int _repairSequence = 0;
  int _rewardedRentSequence = 0;
  int _pendingOfflineEarningsCoins = 0;
  Map<String, int> _pendingOfflineEarningsCoinsByRoom = const {};
  int _pendingRewardOfferCoins = 0;
  int _feedbackSequence = 0;
  GameFeedbackSignal? _feedbackSignal;
  Future<void> _lifecycleOperation = Future<void>.value();
  GameStateController _domainController = GameStateController(
    GameState.seeded(),
  );
  bool _isReady = false;
  SaveLoadResult _loadResult = const SaveNotFound();

  GameState get state => _domainController.state;
  bool get isReady => _isReady;
  int get revision => _domainController.revision;
  bool get hasPendingComplaint => !state.complaintResolved;
  SaveLoadResult get loadResult => _loadResult;
  SaveRejectionReason? get saveRecoveryReason => switch (_loadResult) {
    SaveRejected(:final reason) => reason,
    _ => null,
  };
  DateTime get debugNow => _clock.now();
  int get randomSeed => _randomSource.seed;

  int happinessFor(String ghostId) =>
      HappinessSystem.happinessFor(state, ghostId);
  int compatibilityFor(String ghostId) =>
      HappinessSystem.compatibilityFor(state, ghostId);
  int get pendingRentCoins =>
      state.pendingRentMicrocoins ~/ GameBalance.microcoinsPerCoin;
  int pendingRentCoinsForRoom(String roomId) =>
      state.pendingRentCoinsForRoom(roomId);
  Map<String, int> get pendingRentCoinsByRoom => {
    for (final room in state.rooms)
      room.id: state.pendingRentCoinsForRoom(room.id),
  };
  int repairCostFor(String roomId) => RepairSystem.costFor(state, roomId);
  int get rewardedRentBonusesRemaining =>
      RewardedRentSystem.remainingForDay(state, _localDayKey(_clock.now()));
  bool get canCollectRewardedRent =>
      _pendingRewardOfferCoins > 0 &&
      RewardedRentSystem.canBegin(
        state,
        _localDayKey(_clock.now()),
        _pendingRewardOfferCoins,
      );
  int get pendingRewardOfferCoins => _pendingRewardOfferCoins;
  GameFeedbackSignal? get feedbackSignal => _feedbackSignal;
  List<DailyGoalDefinition> get dailyGoals =>
      DailyGoalSystem.definitions(state);

  int takePendingOfflineEarningsCoins() {
    return takePendingOfflineEarnings().totalCoins;
  }

  OfflineEarningsPresentation takePendingOfflineEarnings() {
    final presentation = OfflineEarningsPresentation(
      totalCoins: _pendingOfflineEarningsCoins,
      coinsByRoom: _pendingOfflineEarningsCoinsByRoom,
    );
    _pendingOfflineEarningsCoins = 0;
    _pendingOfflineEarningsCoinsByRoom = const {};
    return presentation;
  }

  Future<void> initialize() async {
    _loadResult = await _saveService.load();
    _domainController = GameStateController(switch (_loadResult) {
      SaveLoaded(:final state) => state,
      SaveNotFound() => GameState.newGame(),
      SaveRejected() => GameState.seeded(),
    });
    final interruptedRewardedClaim = state.pendingRewardedRentClaim;
    if (interruptedRewardedClaim != null) {
      _domainController.dispatch(
        CancelRewardedRentClaim(claimId: interruptedRewardedClaim.id),
      );
      await _saveService.save(state);
    }
    final beforeResume = state;
    final resumed = _domainController.dispatch(
      ResumeFromOffline(timestampMillis: _clock.now().millisecondsSinceEpoch),
    );
    _pendingOfflineEarningsCoins =
        (state.pendingRentMicrocoins - beforeResume.pendingRentMicrocoins) ~/
        GameBalance.microcoinsPerCoin;
    _pendingOfflineEarningsCoinsByRoom = _offlineRoomCoinDeltas(
      beforeResume,
      state,
    );
    final dailyGoalsRefreshed = _domainController.dispatch(
      EnsureDailyGoals(dayKey: _localDayKey(_clock.now())),
    );
    if ((resumed || dailyGoalsRefreshed) && _loadResult is! SaveRejected) {
      await _saveService.save(state);
    }
    _isReady = true;
    _syncErrorReportingConsent();
    notifyListeners();
    unawaited(_initializePrivacy());
    await _runAudio(() => _audioService.initialize(_audioPreferences));
    await _syncAudioScene();
    if (resumed) {
      await _recordTransition(
        ResumeFromOffline(timestampMillis: _clock.now().millisecondsSinceEpoch),
        beforeResume,
        state,
      );
    }
    await _record(GameplayAnalyticsEvent(GameplayAnalyticsEventName.appOpen));
  }

  Future<void> placeGhost(String ghostId, String roomId) async {
    await _dispatch(PlaceGhost(ghostId: ghostId, roomId: roomId));
  }

  Future<void> continueTutorial() async {
    await _dispatch(const ContinueTutorial());
  }

  Future<void> grantExperience(int amount) async {
    await _dispatch(GrantExperience(amount: amount));
  }

  Future<bool> claimMissionReward(String missionId) =>
      _dispatch(ClaimMissionReward(missionId: missionId));

  Future<bool> refreshDailyGoals() =>
      _dispatch(EnsureDailyGoals(dayKey: _localDayKey(_clock.now())));

  Future<bool> claimDailyGoal(String goalId) =>
      _dispatch(ClaimDailyGoal(goalId: goalId));

  Future<bool> claimDailyChest() => _dispatch(const ClaimDailyChest());

  Future<bool> setLanguageCode(String languageCode) =>
      _dispatch(SetLanguageCode(languageCode: languageCode));

  Future<bool> setAnalyticsConsent(bool granted) =>
      _dispatch(SetAnalyticsConsent(granted: granted));

  Future<bool> setErrorReportingConsent(bool granted) async {
    final changed = await _dispatch(SetErrorReportingConsent(granted: granted));
    _syncErrorReportingConsent();
    return changed;
  }

  Future<bool> isPrivacyOptionsRequired() async {
    try {
      return await _privacyConsentService.isPrivacyOptionsRequired();
    } on Object catch (error, stackTrace) {
      await _report(error, stackTrace, reason: 'privacy_options_status');
      return false;
    }
  }

  Future<void> showPrivacyOptions() async {
    try {
      await _privacyConsentService.showPrivacyOptions();
    } on Object catch (error, stackTrace) {
      await _report(error, stackTrace, reason: 'privacy_options_form');
    }
  }

  Future<bool> setAudioPreferences({
    required bool musicMuted,
    required bool soundMuted,
    required double musicVolume,
    required double soundVolume,
  }) async {
    final changed = await _dispatch(
      SetAudioPreferences(
        musicMuted: musicMuted,
        soundMuted: soundMuted,
        musicVolume: musicVolume,
        soundVolume: soundVolume,
      ),
    );
    if (changed) {
      await _runAudio(() => _audioService.updatePreferences(_audioPreferences));
    }
    return changed;
  }

  Future<bool> setFeedbackPreferences({
    required bool hapticsEnabled,
    required bool reducedMotionEnabled,
  }) => _dispatch(
    SetFeedbackPreferences(
      hapticsEnabled: hapticsEnabled,
      reducedMotionEnabled: reducedMotionEnabled,
    ),
  );

  Future<void> moveGhost(
    String ghostId,
    String targetRoomId, {
    bool allowSwap = false,
  }) async {
    await _dispatch(
      MoveGhost(
        ghostId: ghostId,
        targetRoomId: targetRoomId,
        allowSwap: allowSwap,
      ),
    );
  }

  Future<void> unlockRoom(String roomId) async {
    await _dispatch(UnlockRoom(roomId: roomId));
  }

  Future<void> upgradeRoom(String roomId, RoomAttribute attribute) async {
    await _dispatch(UpgradeRoom(roomId: roomId, attribute: attribute));
  }

  Future<void> equipFurniture(
    String roomId,
    String furnitureId,
    FurnitureSlot slot,
  ) async {
    await _dispatch(
      EquipFurniture(roomId: roomId, furnitureId: furnitureId, slot: slot),
    );
  }

  Future<bool> purchaseFurniture(String furnitureId) =>
      _dispatch(PurchaseFurniture(furnitureId: furnitureId));

  Future<bool> unlockSecondProperty() =>
      _dispatch(const UnlockSecondProperty());

  Future<bool> switchProperty(String propertyId) =>
      _dispatch(SwitchProperty(propertyId: propertyId));

  Future<bool> completeGhostStory(String ghostId) =>
      _dispatch(CompleteGhostStory(ghostId: ghostId));

  Future<void> resolveComplaint(ComplaintChoice choice) async {
    await _dispatch(
      ResolveComplaint(
        choice: choice,
        resolutionId: GameBalance.p0ComplaintResolutionId,
      ),
    );
  }

  Future<void> debugTick() async {
    await advanceSimulation(GameBalance.debugTickSeconds);
  }

  Future<void> advanceSimulation(int elapsedSeconds) async {
    await _dispatch(AdvanceSimulation(seconds: elapsedSeconds));
  }

  Future<int> collectAllRent({String? claimId}) async {
    final resolvedClaimId =
        claimId ??
        'rent-${_clock.now().microsecondsSinceEpoch}-$revision-${_rentClaimSequence++}';
    final walletBefore = state.walletCoins;
    await _dispatch(CollectAllRent(claimId: resolvedClaimId));
    final collected = state.walletCoins - walletBefore;
    if (collected > 0) _pendingRewardOfferCoins = collected;
    return collected;
  }

  Future<int> collectRoomRent(String roomId, {String? claimId}) async {
    final resolvedClaimId =
        claimId ??
        'rent-$roomId-${_clock.now().microsecondsSinceEpoch}-$revision-${_rentClaimSequence++}';
    final walletBefore = state.walletCoins;
    await _dispatch(CollectRoomRent(roomId: roomId, claimId: resolvedClaimId));
    final collected = state.walletCoins - walletBefore;
    if (collected > 0) _pendingRewardOfferCoins = collected;
    return collected;
  }

  Future<RewardedRentCollectionResult> collectAllRentWithRewardedAd({
    int? bonusCoins,
  }) async {
    final claimId =
        'rewarded-rent-${_clock.now().microsecondsSinceEpoch}-$revision-${_rewardedRentSequence++}';
    final baseCoins = bonusCoins ?? await collectAllRent(claimId: claimId);
    if (baseCoins <= 0) return RewardedRentCollectionResult.noClaim;
    final began = await _dispatch(
      BeginRewardedRentClaim(
        claimId: claimId,
        localDayKey: _localDayKey(_clock.now()),
        bonusCoins: baseCoins,
      ),
    );
    if (!began) return RewardedRentCollectionResult.noClaim;

    await _record(
      GameplayAnalyticsEvent(GameplayAnalyticsEventName.adOfferShown, {
        'placement': 'double_rent',
      }),
    );
    await _record(
      GameplayAnalyticsEvent(GameplayAnalyticsEventName.adStarted, {
        'placement': 'double_rent',
      }),
    );

    var bonusGranted = false;
    RewardedAdOutcome outcome;
    try {
      outcome = await _rewardedAdService.showRewardedAd(
        onRewardEarned: () async {
          final granted = await _dispatch(
            GrantRewardedRentBonus(claimId: claimId),
          );
          bonusGranted = bonusGranted || granted;
        },
      );
    } on Object {
      outcome = RewardedAdOutcome.failed;
    }

    if (state.pendingRewardedRentClaim?.id == claimId) {
      await _dispatch(CancelRewardedRentClaim(claimId: claimId));
    }
    if (!bonusGranted) {
      await _record(
        GameplayAnalyticsEvent(GameplayAnalyticsEventName.adFailed, {
          'placement': 'double_rent',
          'reason_code': outcome.name,
        }),
      );
      _pendingRewardOfferCoins = 0;
      return RewardedRentCollectionResult.baseOnly(baseCoins: baseCoins);
    }
    _pendingRewardOfferCoins = 0;
    return RewardedRentCollectionResult.bonusEarned(
      baseCoins: baseCoins,
      bonusCoins: baseCoins,
    );
  }

  Future<bool> resolveIncident(
    String incidentId,
    String choiceId, {
    String? resolutionId,
  }) async {
    final resolvedId =
        resolutionId ??
        'incident-$incidentId-$choiceId-${state.activeSimulationSeconds}';
    return _dispatch(
      ResolveIncident(
        incidentId: incidentId,
        choiceId: choiceId,
        resolutionId: resolvedId,
      ),
    );
  }

  Future<bool> repairRoom(String roomId, {String? repairId}) async {
    final resolvedRepairId =
        repairId ??
        'repair-$roomId-${_clock.now().microsecondsSinceEpoch}-$revision-${_repairSequence++}';
    return _dispatch(RepairRoom(roomId: roomId, repairId: resolvedRepairId));
  }

  Future<void> pauseForOffline() async {
    if (!_isReady) return;
    final timestampMillis = _clock.now().millisecondsSinceEpoch;
    _lifecycleOperation = _lifecycleOperation.then((_) async {
      await _runAudio(_audioService.pauseBackground);
      await _dispatch(PauseForOffline(timestampMillis: timestampMillis));
    });
    await _lifecycleOperation;
  }

  Future<void> resumeFromOffline() async {
    if (!_isReady) return;
    final timestampMillis = _clock.now().millisecondsSinceEpoch;
    _lifecycleOperation = _lifecycleOperation.then((_) async {
      final pendingBefore = state.pendingRentMicrocoins;
      final stateBefore = state;
      await _dispatch(ResumeFromOffline(timestampMillis: timestampMillis));
      final earnedCoins =
          (state.pendingRentMicrocoins - pendingBefore) ~/
          GameBalance.microcoinsPerCoin;
      if (earnedCoins > 0) {
        _pendingOfflineEarningsCoins = earnedCoins;
        _pendingOfflineEarningsCoinsByRoom = _offlineRoomCoinDeltas(
          stateBefore,
          state,
        );
        notifyListeners();
      }
      await _runAudio(_audioService.resumeBackground);
    });
    await _lifecycleOperation;
  }

  Future<void> resetState() async {
    _randomSource.reset();
    await _dispatch(const ResetGame());
    await refreshDailyGoals();
  }

  Future<void> setGhostSpecialAction(String ghostId, bool active) async {
    await _dispatch(SetGhostSpecialAction(ghostId: ghostId, active: active));
  }

  Future<bool> _dispatch(GameCommand command) async {
    final before = state;
    if (!_domainController.dispatch(command)) return false;
    notifyListeners();
    await _saveService.save(state);
    await _recordTransition(command, before, state);
    await _playTransition(command, before, state);
    await _syncAudioScene();
    await _emitFeedback(command, before, state);
    return true;
  }

  AudioPreferences get _audioPreferences => AudioPreferences(
    musicMuted: state.musicMuted,
    soundMuted: state.soundMuted,
    musicVolume: state.musicVolume,
    soundVolume: state.soundVolume,
  );

  Future<void> _playTransition(
    GameCommand command,
    GameState before,
    GameState after,
  ) async {
    AudioCue? cue;
    if (before.activeIncidentId == null && after.activeIncidentId != null) {
      cue = AudioCue.incidentAlert;
    } else {
      cue = switch (command) {
        CollectAllRent() ||
        CollectRoomRent() ||
        BeginRewardedRentClaim() ||
        GrantRewardedRentBonus() => AudioCue.coin,
        UpgradeRoom() => AudioCue.upgrade,
        UnlockRoom() => AudioCue.unlock,
        EquipFurniture() || PurchaseFurniture() => AudioCue.furniture,
        ClaimMissionReward() ||
        ClaimDailyGoal() ||
        ClaimDailyChest() ||
        UnlockSecondProperty() ||
        CompleteGhostStory() => AudioCue.reward,
        SwitchProperty() => AudioCue.uiClick,
        RepairRoom() => AudioCue.repair,
        PlaceGhost(:final ghostId) ||
        MoveGhost(:final ghostId) => _ghostReactionCue(after, ghostId),
        ResolveIncident() || ResolveComplaint() =>
          after.chaos <= before.chaos && after.reputation >= before.reputation
              ? AudioCue.incidentGood
              : AudioCue.incidentBad,
        _ => null,
      };
    }
    if (cue != null && !state.soundMuted) {
      await _runAudio(() => _audioService.play(cue!));
    }
  }

  AudioCue _ghostReactionCue(GameState state, String ghostId) {
    final happiness = HappinessSystem.happinessFor(state, ghostId);
    if (happiness < 40) return AudioCue.ghostAngry;
    final happy = happiness >= 80;
    return switch (state.ghostById(ghostId).kind) {
      GhostKind.pocong => happy ? AudioCue.pocongHappy : AudioCue.pocong,
      GhostKind.kuntilanak =>
        happy ? AudioCue.kuntilanakHappy : AudioCue.kuntilanak,
      GhostKind.tuyul => happy ? AudioCue.tuyulHappy : AudioCue.tuyul,
      GhostKind.genderuwo =>
        happy ? AudioCue.genderuwoHappy : AudioCue.genderuwo,
    };
  }

  Future<void> _syncAudioScene() => _runAudio(
    () => _audioService.setScene(
      state.activeIncidentId != null || state.chaos >= 70
          ? AudioScene.tension
          : AudioScene.calm,
    ),
  );

  Future<void> _emitFeedback(
    GameCommand command,
    GameState before,
    GameState after,
  ) async {
    final kind =
        before.activeIncidentId == null && after.activeIncidentId != null
        ? GameFeedbackKind.warning
        : switch (command) {
            CollectAllRent() ||
            CollectRoomRent() ||
            GrantRewardedRentBonus() => GameFeedbackKind.coin,
            UpgradeRoom() ||
            EquipFurniture() ||
            PurchaseFurniture() => GameFeedbackKind.upgrade,
            UnlockRoom() || UnlockSecondProperty() => GameFeedbackKind.unlock,
            ClaimMissionReward() ||
            ClaimDailyGoal() ||
            ClaimDailyChest() ||
            CompleteGhostStory() => GameFeedbackKind.reward,
            PlaceGhost() || MoveGhost() => GameFeedbackKind.tenant,
            ResolveIncident() || ResolveComplaint() => GameFeedbackKind.reward,
            _ => null,
          };
    if (kind == null) return;
    _feedbackSignal = GameFeedbackSignal(
      sequence: ++_feedbackSequence,
      kind: kind,
    );
    notifyListeners();
    if (!after.hapticsEnabled) return;
    final haptic = kind == GameFeedbackKind.warning
        ? HapticCue.warning
        : kind == GameFeedbackKind.tenant
        ? HapticCue.selection
        : HapticCue.success;
    try {
      await _feedbackService.haptic(haptic);
    } on Object {
      // Haptics are cosmetic and must never interrupt deterministic gameplay.
    }
  }

  Future<void> _runAudio(Future<void> Function() operation) async {
    try {
      await operation();
    } on Object {
      // Audio is cosmetic and must never interrupt deterministic gameplay.
    }
  }

  Future<void> _initializePrivacy() async {
    try {
      await _privacyConsentService.initialize();
      notifyListeners();
    } on Object catch (error, stackTrace) {
      await _report(error, stackTrace, reason: 'privacy_consent_initialize');
    }
  }

  Future<void> _report(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {
    if (!state.errorReportingConsentGranted) return;
    try {
      await _errorReportingService.record(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } on Object {
      // Diagnostics are optional and cannot affect local gameplay.
    }
  }

  void _syncErrorReportingConsent() {
    final service = _errorReportingService;
    if (service is ConsentAwareErrorReportingService) {
      service.setEnabled(state.errorReportingConsentGranted);
    }
  }

  Future<void> _recordTransition(
    GameCommand command,
    GameState before,
    GameState after,
  ) async {
    final events = <GameplayAnalyticsEvent>[];

    if (before.activeIncidentId == null && after.activeIncidentId != null) {
      events.add(
        GameplayAnalyticsEvent(GameplayAnalyticsEventName.incidentStarted, {
          'incident_id': after.activeIncidentId!,
          'scripted': !before.unscriptedIncidentsEnabled,
        }),
      );
    }
    if (!before.tutorialStep.isCompleted && after.tutorialStep.isCompleted) {
      events.add(
        GameplayAnalyticsEvent(GameplayAnalyticsEventName.tutorialCompleted),
      );
    }

    switch (command) {
      case ContinueTutorial()
          when before.tutorialStep == TutorialStep.openingStory:
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.tutorialStarted),
        );
      case PlaceGhost(:final ghostId, :final roomId):
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.ghostPlaced, {
            'ghost_kind': after.ghostById(ghostId).kind.name,
            'room_id': roomId,
          }),
        );
      case UpgradeRoom(:final roomId, :final attribute):
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.roomUpgraded, {
            'room_id': roomId,
            'attribute': attribute.name,
            'level': after.roomById(roomId).levelFor(attribute),
          }),
        );
      case UnlockRoom(:final roomId):
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.roomUnlocked, {
            'room_id': roomId,
            'cost': before.walletCoins - after.walletCoins,
          }),
        );
      case CollectAllRent():
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.rentCollected, {
            'coins': after.walletCoins - before.walletCoins,
          }),
        );
      case CollectRoomRent():
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.rentCollected, {
            'coins': after.walletCoins - before.walletCoins,
          }),
        );
      case BeginRewardedRentClaim() when after.walletCoins > before.walletCoins:
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.rentCollected, {
            'coins': after.walletCoins - before.walletCoins,
          }),
        );
      case GrantRewardedRentBonus():
        events.add(
          GameplayAnalyticsEvent(GameplayAnalyticsEventName.adRewardEarned, {
            'placement': 'double_rent',
            'coins': after.walletCoins - before.walletCoins,
          }),
        );
      case ResolveIncident(:final incidentId, :final choiceId):
        events
          ..add(
            GameplayAnalyticsEvent(
              GameplayAnalyticsEventName.incidentChoiceSelected,
              {'incident_id': incidentId, 'choice_id': choiceId},
            ),
          )
          ..add(
            GameplayAnalyticsEvent(
              GameplayAnalyticsEventName.incidentResolved,
              {'incident_id': incidentId, 'choice_id': choiceId},
            ),
          );
      case ResumeFromOffline():
        final earnedMicrocoins =
            after.pendingRentMicrocoins - before.pendingRentMicrocoins;
        if (earnedMicrocoins > 0) {
          events.add(
            GameplayAnalyticsEvent(
              GameplayAnalyticsEventName.offlineEarningsClaimed,
              {'coins': earnedMicrocoins ~/ GameBalance.microcoinsPerCoin},
            ),
          );
        }
      default:
        break;
    }

    for (final event in events) {
      await _record(event);
    }
  }

  Future<void> _record(GameplayAnalyticsEvent event) async {
    if (!state.analyticsConsentGranted) return;
    try {
      await _analyticsService.record(event);
    } on Object {
      // Analytics is best-effort and must never affect local gameplay.
    }
  }

  @override
  void dispose() {
    unawaited(_runAudio(_audioService.dispose));
    super.dispose();
  }
}

class OfflineEarningsPresentation {
  const OfflineEarningsPresentation({
    required this.totalCoins,
    required this.coinsByRoom,
  });

  final int totalCoins;
  final Map<String, int> coinsByRoom;
}

Map<String, int> _offlineRoomCoinDeltas(GameState before, GameState after) => {
  for (final room in after.rooms)
    if ((after.pendingRentMicrocoinsForRoom(room.id) -
                before.pendingRentMicrocoinsForRoom(room.id)) ~/
            GameBalance.microcoinsPerCoin >
        0)
      room.id:
          (after.pendingRentMicrocoinsForRoom(room.id) -
              before.pendingRentMicrocoinsForRoom(room.id)) ~/
          GameBalance.microcoinsPerCoin,
};

sealed class RewardedRentCollectionResult {
  const RewardedRentCollectionResult();

  static const noClaim = RewardedRentNoClaim();

  factory RewardedRentCollectionResult.baseOnly({required int baseCoins}) =
      RewardedRentBaseOnly;

  factory RewardedRentCollectionResult.bonusEarned({
    required int baseCoins,
    required int bonusCoins,
  }) = RewardedRentBonusEarned;
}

final class RewardedRentNoClaim extends RewardedRentCollectionResult {
  const RewardedRentNoClaim();
}

final class RewardedRentBaseOnly extends RewardedRentCollectionResult {
  const RewardedRentBaseOnly({required this.baseCoins});

  final int baseCoins;
}

final class RewardedRentBonusEarned extends RewardedRentCollectionResult {
  const RewardedRentBonusEarned({
    required this.baseCoins,
    required this.bonusCoins,
  });

  final int baseCoins;
  final int bonusCoins;
}

String _localDayKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

extension on TutorialStep {
  bool get isCompleted => this == TutorialStep.completed;
}
