# Implementation progress

This is the single detailed progress tracker. `HANTU_KONTRAKAN_IMPLEMENTATION_PLAN.md` remains the product specification and acceptance-criteria source, with its ticket checkboxes updated to mirror verified completion. Detailed status, evidence, decisions, and remaining work are recorded only here.

## P0 vertical slice

Status: implemented and verified on 2026-10-11.

- P0-01: Flutter scaffold, portrait orientation, Flame game surface, placeholder visuals.
- P0-02: two horizontal tappable room components with tappable ghost children.
- P0-03: deterministic seeded Pocong and Tuyul state.
- P0-04: pure Dart directional compatibility and capped happiness rules.
- P0-05: room detail sheet with numeric state and atomic tenant swap.
- P0-06: one scripted Pocong-versus-Tuyul complaint.
- P0-07: three previewed deterministic choices updating coins and happiness once.
- P0-08: schema-versioned local save/reload plus deterministic tests.

## M1 — Foundation and building prototype

### HK-001 — App foundation

Status: implemented and verified on 2026-10-11.

- Retained the existing Flutter + Flame P0 entry point and extracted the dark Material theme into `AppTheme`.
- Added named-route scaffolding with `/` as the home route.
- Added generated ARB localization for Indonesian and English and migrated the current Flutter HUD, room sheet, and complaint dialog copy.
- Retained runtime portrait locking and added portrait-only Android/iOS manifest declarations to prevent landscape presentation outside Flutter startup.
- Added tests for the named home route, both supported locales, and platform orientation declarations.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 12 tests passed, including 3 HK-001 foundation tests and all P0 regressions.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-002 — 2×2 cutaway building

Status: implemented and verified on 2026-10-11.

- Expanded the Flame world to the specified 2×2 cutaway: rooms 03/04 on the upper floor and rooms 01/02 on the ground floor.
- Preserved Pocong and Tuyul in the existing lower rooms and added visibly locked presentation placeholders for the upper rooms.
- Kept all four rooms as Flame `TapCallbacks` components and routed their stable IDs into Flutter room sheets; locked rooms show a localized read-only explanation.
- Added a deterministic world test covering all four IDs, exact grid coordinates, locked-room state, and every selection callback.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 13 tests passed, including the new HK-002 layout/selection test and all prior regressions.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-003 — Pure Dart domain foundation

Status: implemented and verified on 2026-10-11.

- Hardened `GameState` so ghost and room collections are defensively copied and unmodifiable.
- Added sealed `SwapOccupants` and `ResolveComplaint` commands.
- Added a pure Dart `GameStateController` with deterministic dispatch, identity-preserving no-ops, and revision tracking.
- Updated the Flutter application controller to delegate transitions through typed commands while retaining notification and save behavior.
- Consolidated the established P0 complaint costs/effects and resolution ID in `GameBalance`.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- `flutter test test/simulation test/application`: all 8 focused tests passed.
- `flutter test`: all 15 tests passed, including immutable-state and typed-command coverage plus all previous regressions.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; the simulation layer has no Flutter or Flame imports.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-004 — Versioned save/load and recovery

Status: implemented and verified on 2026-10-13.

- Replaced nullable/catch-all loading with explicit not-found, loaded, corrupt, and unsupported-version outcomes.
- Added strict schema-version validation and a dedicated unsupported-version exception before version-1 decoding.
- Preserved rejected SharedPreferences payloads at both the primary key and a recovery backup key.
- Seeded a safe playable state after rejection while exposing the recovery reason and avoiding writes during initialization.
- Retained save/reload survival for room swaps, complaint resolution, wallet changes, and happiness effects.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- `flutter test test/services test/application`: all 7 focused persistence/application tests passed.
- `flutter test`: all 19 tests passed, including missing-save, round-trip, corrupt-save, unsupported-version, backup-preservation, fallback, and reload coverage.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-005 — Debug HUD and deterministic runtime

Status: implemented and verified on 2026-10-13. Milestone M1 is complete.

- Added a debug-only HUD showing coins, chaos, Pocong/Tuyul happiness, active tick count, injected clock time, and RNG seed.
- Added manual one-second tick and seeded-state reset controls, both routed through typed domain commands and persisted normally.
- Added injectable `GameClock` and resettable `SeededRandomSource` runtime dependencies with deterministic tests.
- Added persisted chaos and active simulation seconds under schema version 2, plus an explicit version-1 migration.
- Kept actual economy accrual, periodic chaos changes, incidents, and offline simulation outside HK-005.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- Focused simulation, runtime, persistence, and debug-HUD suite: all 22 tests passed.
- `flutter test`: all 24 tests passed, including deterministic clock/seed, RNG reset, tick/reset persistence, debug HUD, and v1 migration coverage.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

## M2 — Ghosts and room management

### HK-006 — Ghost definitions and placeholder animations

Status: implemented and verified on 2026-10-13.

- Added plan-accurate immutable definitions for Pocong, Kuntilanak, Tuyul, and Genderuwo, including economy, unlock, preference, neighbor, chaos, and ability metadata.
- Expanded placeholder rendering to support all four ghost kinds with distinct colors.
- Added state-driven idle, happy, angry, and special procedural animation modes; special action overrides the happiness-derived mode.
- Added a typed special-action command and debug toggle so the rendered special mode can be activated and persisted.
- Advanced saves to schema version 3 and added version-2 migration with inactive special actions.
- Kept Kuntilanak/Genderuwo instantiation, tenant placement, abilities, and final sprite artwork outside HK-006.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- Focused ghost definition, animation, migration, simulation, and UI suite: all 24 tests passed.
- `flutter test`: all 29 tests passed, including exact four-definition data, state-to-animation selection, every ghost kind, command targeting, debug activation, persistence, and v2 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-007 — Tenant placement, moves, swaps, and vacancy validation

Status: implemented and verified on 2026-10-13.

- Added pure-Dart placement and move commands with explicit swap authorization.
- Added state-boundary validation for unique IDs, valid occupant references, and one-room-per-ghost occupancy.
- Vacant placement and vacant moves are atomic; occupied moves without authorization and all malformed moves remain identity-preserving no-ops.
- Replaced the implicit two-room swap button with a destination picker and an explicit occupied-room swap confirmation.
- Kept eligible destinations limited to simulation rooms; locked upper-room economy and unlocks remain deferred to HK-010.
- Confirmed authorized swaps and complaint outcomes survive save/reload without a schema change.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- Focused rule, domain-controller, and application reload suite: all 14 tests passed.
- `flutter test`: all 34 tests passed, including vacancy placement/moves, authorized atomic swaps, invalid no-ops, invariant rejection, typed dispatch, and persisted swaps.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-008 — Happiness, preferences, and directional compatibility

Status: implemented and verified on 2026-10-13.

- Completed all twelve non-self entries in the four-ghost directional compatibility matrix.
- Replaced column-only adjacency with coordinate-based Manhattan adjacency, including vertical neighbors and diagonal exclusion.
- Added immutable room tag-level and furniture-tag inputs plus explicit match/mismatch balance constants and normative subtotal caps.
- Extended happiness to combine base, room, furniture, compatibility, and event components deterministically with the final 0–100 clamp.
- Advanced saves to schema version 4 and added explicit version-3 migration defaults for row and tag fields.
- Kept upgrade actions, furniture inventory/slots, and individual item-to-tag mapping deferred to HK-010.

Verification:

- Dart formatter completed successfully.
- `flutter analyze`: no issues found.
- Focused happiness, persistence, placement, and controller suite: all 26 tests passed.
- `flutter test`: all 39 tests passed, including the full directional matrix, Pocong ← Tuyul = -15, horizontal/vertical/diagonal adjacency, room/furniture scoring and caps, neutral legacy environments, and v3 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-009 — Room and ghost detail sheets

Status: implemented and verified on 2026-10-13.

- Split Flame room-surface and ghost tap callbacks so each opens the correct Flutter-owned sheet.
- Added a state-driven occupied/vacant room sheet with tenant, localized mood, complete happiness breakdown, profile action, and move/swap action.
- Added a ghost profile sheet with localized archetype, current room, happiness, base rent, preferred tags, disliked neighbor, ability, breakdown, and valid move action.
- Added a pure-Dart happiness breakdown value so UI totals and component rows share one calculation.
- Added Indonesian and English detail/profile localization while retaining placeholder profile artwork.
- Kept upgrades, furniture slots, unlock controls, and their economy outside HK-009.

Verification:

- Dart formatter and localization generation completed successfully.
- `flutter analyze`: no issues found.
- Focused detail-sheet, Flame callback, and happiness suite: all 11 tests passed.
- `flutter test`: all 42 tests passed, including occupied/vacant action visibility, exact state-driven breakdown values, ghost definition/profile content, and distinct room/ghost selection callbacks.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-010 — Room upgrades, unlocks, and furniture slots

Status: implemented and verified on 2026-10-13. Milestone M2 is complete.

- Promoted all four cutaway rooms into persisted state with rooms 03/04 locked by default.
- Added atomic unlock commands for the exact room 03/04 coin and player-level gates.
- Added comfort, silence, mystical affinity, and durability levels with exact 100/200 costs and a hard level-2 cap.
- Connected upgrades to HK-008 room preference tags and happiness calculations.
- Added one primary and one decoration slot per room plus twelve slot-validated placeholder furniture definitions and derived happiness tags.
- Added localized room controls with disabled maxed, unaffordable, and locked actions.
- Advanced saves to schema version 5 with explicit legacy defaults for player level, locked upper rooms, upgrades, and furniture.
- Kept XP/level progression, furniture purchasing/inventory, rent, and broader economy out of HK-010.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused room-management, detail-sheet, persistence, and Flame-world suite: all 20 tests passed.
- `flutter test`: all 50 tests passed, including wallet-floor safety, unlock gates, escalating upgrade costs, max-level no-ops, locked-room no-ops, slot replacement, UI disabling, twelve-item content, and v4 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

## M3 — Economy and offline earnings

### HK-011 — Precise deterministic rent accrual

Status: implemented and verified on 2026-10-13.

- Added a pure-Dart fixed-point rent system using integer microcoins and exact percentage multipliers.
- Implemented happiness, comfort, and chaos multipliers plus Tuyul's unmultiplied 15% base-rent bonus.
- Added chunk-independent elapsed-second accrual with a persisted modulo-60 remainder.
- Added typed `AdvanceSimulation` dispatch; debug ticks now exercise the production accrual rule while remaining independent from Flame frames.
- Persisted pending rent and fractional remainder under save schema version 6 with version-5 migration defaults.
- Exposed floored pending whole coins in the debug HUD without collecting them.
- Kept wallet collection and idempotent claim IDs deferred to HK-012; offline snapshot/lifecycle behavior remains HK-013.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused rent, controller, persistence, and HUD suite: all 28 tests passed.
- `flutter test`: all 57 tests passed, including the 18.1125 worked example, Tuyul bonus semantics, multiplier thresholds, 601-second chunk equivalence, carried fractional remainder, non-positive no-ops, save round-trip, and v5 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-012 — Atomic and idempotent Collect All

Status: implemented and verified on 2026-10-13.

- Added typed rent collection with caller-visible claim IDs and persisted replay protection.
- Atomically transfers claimable whole coins to the wallet while preserving sub-coin microcoins and the elapsed-time remainder.
- Rejects empty IDs, duplicate claims, and balances below one coin as identity-preserving no-ops.
- Added a localized Collect All control that shows floored claimable coins and disables itself at zero.
- Advanced saves to schema version 7 with explicit version-6 migration and completed-claim round-trip coverage.
- Kept offline snapshots and resume claims deferred to HK-013.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused collection, controller-reload, persistence, and widget suite: all 21 tests passed.
- `flutter test`: all 64 tests passed, including atomic whole-coin payout, fractional preservation, duplicate replay before/after reload, early-claim retry behavior, visible wallet updates, disabled zero balance, save round-trip, and v6 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-013 — Offline snapshot and capped earnings

Status: implemented and verified on 2026-10-13.

- Added pure-Dart pause/resume rules that snapshot the complete current rent rate and credit elapsed offline time at 50%, capped at four hours.
- Added atomic snapshot consumption so repeated resume or reload calls cannot credit the same absence twice; negative elapsed time credits zero and is still consumed.
- Routed background and resume lifecycle events through typed domain commands, including cold-launch consumption of a persisted snapshot.
- Added pending-rent integration without running active simulation, incidents, chaos, reputation, or ability logic offline.
- Advanced saves to schema version 8 with explicit version-7 migration and offline snapshot round-trip coverage.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused offline-rule, lifecycle-controller, persistence, and widget coverage: all 27 tests passed.
- `flutter test`: all 74 tests passed, including 2-hour and 5-hour worked examples, four-hour capping, 50% earnings, snapshot-rate capture, repeated resume/load protection, clock rollback, ordered lifecycle persistence, and v7 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-014 — Four ghost abilities and persisted cooldowns

Status: implemented and verified on 2026-10-13.

- Added chunk-independent active cooldown execution for Pocong's 30-coin reward and Kuntilanak's +1 reputation reward at their happiness thresholds.
- Retained Tuyul's exact continuous base-rent bonus and added Genderuwo's deterministic 25% repair-discount query without implementing HK-020 repairs early.
- Persisted per-instance cooldowns and reputation under save schema version 9 with explicit version-8 migration.
- Kept ability processing outside offline resume, so capped offline rent cannot trigger active-only rewards or consume cooldown time.
- Added controller-reload coverage proving a partially elapsed cooldown resumes from its saved value.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused ability, rent, offline, persistence, and controller suite: all 39 tests passed.
- `flutter test`: all 83 tests passed, including all four abilities, happiness gates, multi-trigger chunk equivalence, cooldown reload, reputation cap, offline exclusion, and v8 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-015 — Balance and serialization regression suite

Status: implemented and verified on 2026-10-13. Milestone M3 is complete.

- Added a canonical regression suite for the documented 85/70 Pocong happiness example, exact 18.1125 rent example, upgrade/unlock prices, and 2-hour/5-hour offline earnings.
- Corrected preferred-furniture happiness from the provisional +5 to the documented +10 while preserving the existing +10 aggregate cap.
- Added a fully populated schema-v9 JSON round-trip that proves subsequent deterministic rent accrual, ability cooldown progression, and Collect All behavior remain identical.
- Retained all narrower M2/M3 unit, persistence, lifecycle, and controller regression tests.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused balance, happiness, rent, room-management, and persistence suite: all 36 tests passed.
- `flutter test`: all 88 tests passed, including every documented worked example and post-serialization deterministic continuation.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

## M4 — Chaos, incidents, and comedy

### HK-016 — Chaos, reputation, and event modifier expiry

Status: implemented and verified on 2026-10-13.

- Added deterministic ten-active-minute chaos ticks using occupied ghost contributions and the plan's natural -4 adjustment.
- Added explicit event chaos/reputation delta handling with 0–100 clamps while retaining ability-only passive reputation gains.
- Added persisted 600-active-second happiness modifier expiry; offline time never changes chaos, reputation, or expiry progress.
- Added boundary-aware active simulation so rent, abilities, modifier expiry, and chaos remain chunk independent when state changes mid-update.
- Advanced saves to schema version 10 with explicit version-9 migration and expiry round-trip coverage.
- Added reputation to the existing debug HUD; no incident scheduler or incident UI was implemented early.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused chaos, abilities, rent, serialization, persistence, controller, and HUD suite: all 50 tests passed.
- `flutter test`: all 95 tests passed, including exact chaos contributions, both bounds, chunk equivalence, active expiry, offline exclusion, and v9 migration.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-017 — Seeded incident scheduler, gating, cooldowns, and rolling cap

Status: implemented and verified on 2026-10-13.

- Added pure-Dart incident definition metadata and eligibility checks for general, resident, happiness, player-level, and chaos gates.
- Added deterministic checks at each 60 active seconds using the exact chaos probability formula and an injectable seeded RNG with persisted continuation state.
- Enforced one unresolved incident, a three-active-minute post-resolution cooldown, and at most three unscripted incidents per rolling ten active minutes.
- Added short persisted incident history to prevent immediate repeats when alternatives are eligible.
- Added typed idempotent incident resolution and persisted pending incident, spawn history, completed resolution IDs, and scheduler state.
- Advanced saves to schema version 11 with explicit version-10 migration defaults; offline resume remains unable to run or advance the scheduler.
- Kept the complete ten localized incidents, choice effects, and incident Flutter presentation in HK-018/HK-019.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused scheduler, persistence, rules, and controller suite: all 33 tests passed.
- `flutter test`: all 103 tests passed, including probability, eligibility, overlap prevention, cooldown, rolling cap, idempotency, chunk/reload determinism, migration, and offline exclusion.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; the scheduler remains pure Dart.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-018 — Ten localized incidents and branching outcomes

Status: implemented and verified on 2026-10-13.

- Authored all ten planned incident concepts as immutable pure-Dart data with stable IDs.
- Added Indonesian and English title, dialogue, choice label, and post-choice response text for every branch.
- Added exactly documented coin, per-ghost-kind happiness, chaos, and reputation deltas for 20 deterministic choices.
- Expanded scheduler eligibility for minimum happiness, reputation, occupied-room, and resident-room durability gates.
- Added 180–300 active-second authored cooldowns and connected them to the HK-017 scheduler while preserving its three-minute minimum.
- Added catalog validation and exact-effect snapshot tests covering every incident and choice.
- Kept effect application, affordability handling, previews, dialogs, and outcome presentation deferred to HK-019.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused incident catalog and scheduler suite: all 12 tests passed.
- `flutter test`: all 108 tests passed, including the complete bilingual catalog, exact effects for all 20 choices, expanded eligibility, and authored cooldown behavior.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; incident content and rules remain pure Dart.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-019 — Incident decisions, consequence previews, and outcomes

Status: implemented and verified on 2026-10-13. Milestone M4 incident flow is complete; HK-020 remains separate repair/departure work.

- Added a localized active-incident button, decision dialog, exact consequence previews, affordability disabling, and a non-dismissible resolved-outcome dialog with the authored response.
- Extended `ResolveIncident` with the stable choice ID required by the plan and routed it through the application and pure-Dart domain controllers.
- Incident resolution now validates the pending incident, authored choice, wallet affordability, and unique resolution ID before atomically applying coin, resident happiness, chaos, and reputation effects.
- Duplicate taps/replays, stale or mismatched incidents, unknown choices, blank identifiers, and unaffordable choices are identity-preserving no-ops and cannot award effects or clear the pending incident.
- Successful choices clear the pending incident, record the completed resolution token, start the authored scheduler cooldown, notify Flutter once, and persist before the outcome dialog is shown.
- Added Indonesian and English UI copy for the incident entry point, previews, affordability message, resolved heading, and continuation action.

Implementation decisions:

- Consequence previews are derived from the same immutable `IncidentEffects` objects used by the domain transition, preventing UI text from drifting from applied values.
- Happiness deltas apply only to currently placed residents of the targeted ghost kinds. They add to the current temporary event modifier, respect the established -20/+20 event cap, and refresh its 600-active-second expiry.
- Coin costs must be affordable before any part of a choice is applied. Chaos and reputation retain their established 0–100 clamps.
- The default resolution token is stable for the pending incident, selected choice, and current active second. Domain correctness still relies on pending-incident matching and the persisted completed-token set rather than the Flutter dialog guard.
- No save-schema change is required: HK-017 already persists the active incident, resolution IDs, history, and cooldown timestamps.
- `docs/implementation_progress.md` is now the only progress/decision tracker. The implementation plan remains specification-only, and the historical `docs/decisions.md` is no longer updated.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused incident, application-controller, and widget suite: all 23 tests passed.
- `flutter test`: all 111 tests passed, including atomic exact effects, replay rejection, invalid/unaffordable no-ops, localized preview UI, persistence, and resolved outcome presentation.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; effect application remains pure Dart.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

### HK-020 — Repair costs, durability discounts, and persistence

Status: implemented and verified on 2026-10-13. Milestone M4 is complete.

- Added persisted per-room repair-required state and a persisted completed-repair ID set under save schema version 12, with explicit version-11 migration defaults.
- Added pure-Dart `RepairSystem` cost calculation and a typed `RepairRoom(roomId, repairId)` command routed through both controllers.
- Added atomic repair behavior: validate room/damage/token/funds, deduct the exact cost, clear damage, and record the repair ID in one immutable transition.
- Added localized repair state, exact cost, affordability disabling, and repair action to the Flutter room detail sheet.
- Confirmed repair state and replay protection survive JSON, save-service, and application-controller reloads; offline resume never repairs or charges a room.

Implementation decisions:

- The plan defines durability and Genderuwo discounts but not a base price. HK-020 therefore establishes a 100-coin base repair cost and durability-level percentages of 100%, 80%, and 60%, producing costs of 100/80/60 at levels 0/1/2.
- A Genderuwo occupying the damaged room at happiness 60+ applies the existing 25% ability discount after durability, producing exact costs of 75/60/45.
- A repair ID is recorded only after a successful charge. Blank IDs, completed IDs, unknown/locked/undamaged rooms, zero costs, and insufficient funds are identity-preserving no-ops.
- Damage generation and tenant departure are not invented in HK-020 because the plan defines neither timing nor thresholds. The persisted repair-required state is ready for later incident/tutorial/content triggers, while offline time explicitly cannot create or resolve damage.
- The implementation plan checkboxes for verified HK-017 through HK-020 are synchronized with this tracker as requested; detailed progress remains in this file.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused repair, persistence, controller, room-sheet, and Genderuwo-ability suite: all 44 tests passed.
- `flutter test`: all 120 tests passed, including exact durability/Genderuwo discounts, atomic payment, replay rejection, save migration, reload persistence, UI affordability, and offline exclusion.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; repair rules remain pure Dart.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.

## Scope intentionally deferred

- HK-023 and all later tickets.
- Furniture purchasing/inventory, automatic damage generation, tenant departures, ads, IAP, analytics, cloud/network services, final artwork, and remaining localization.

## Verification evidence

- `/Users/indra/flutter/bin/cache/dart-sdk/bin/dart format lib test`: 20 files formatted successfully.
- `flutter analyze`: no issues found.
- `flutter test`: 9 tests passed. Coverage includes directional compatibility, adjacency and caps, atomic swapping, idempotent incident effects, controller reload, JSON persistence/corrupt-save fallback, and the visible Flutter complaint flow.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.
- Acceptance flow is covered by the widget and controller tests: initial Pocong happiness 35 from the −15 Tuyul penalty; soundproofing resolves the complaint once, changes coins 200 → 150 and happiness 35 → 55, then persists the resolved state.

## Remaining validation

- No emulator or physical-device session was attached, so touch interaction and cold restart were validated through automated tests and the Android build rather than a manual device run.
- A physical-device launch remains pending; Android bootability is currently evidenced by the successful debug APK build and automated widget tests.

### HK-021 — Opening story, guided tutorial, and scripted incident

Status: implemented and verified on 2026-10-13.

- Added a persisted pure-Dart tutorial state machine covering the inheritance story, Pocong placement, first-rent collection, Kuntilanak placement, scripted Pak RT incident, locked-room preview, and unrestricted handoff.
- New saves begin with both available rooms vacant and unscripted incidents disabled. Existing schema-version-12 saves migrate as tutorial-complete so established players are not forced through onboarding.
- Placing Pocong in Room 1 makes an immediate 10-coin tutorial rent claim available through the existing atomic Collect All path.
- Placing Kuntilanak in Room 2 injects the authored Pak RT incident directly, bypassing its normal chaos gate and all scheduler RNG. Choice resolution still uses HK-019's validated, idempotent incident command and exact authored effects.
- Added a compact localized Flutter tutorial panel in Indonesian and English. Flame remains responsible only for the cutaway world; no tutorial rules were added to rendering components.
- Completing the locked-room handoff re-enables unscripted incidents and removes the tutorial panel without locking normal play.
- Advanced saves to schema version 13 for `tutorialStep`, including persistence/reload coverage and explicit version-12 migration behavior.

Implementation decisions and assumptions:

- The narrative describes Pocong as an informal rent-free occupant, while the actionable room assignment begins vacant so the player performs the required placement themselves.
- Room 2 is already structurally available; the tutorial introduces it together with Kuntilanak instead of inventing a room-unlock rule ahead of HK-022.
- The first rent is a deterministic 10-coin tutorial grant, matching Pocong's base rent and avoiding wall-clock waiting during onboarding. It is stored as pending microcoins and collected by the normal idempotent rent command.
- The scripted incident uses the existing `pak_rt_complaint` definition at initial chaos 40 even though its unscripted eligibility requires chaos 70. This is intentional evidence that scripted tutorial incidents bypass random eligibility checks while retaining normal choice validation and effects.
- The legacy P0 Pocong/Tuyul complaint remains available in the established seeded sandbox but is already resolved in the new-player tutorial state, preventing two competing complaint flows.
- Tutorial skip remains deferred because the plan marks it as optional after initial testing. HK-021 adds no level, mission, analytics, ads, purchase, cloud, or network behavior.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 123 tests passed, including the complete new-player widget flow from story through ghost placement, rent collection, scripted choice, locked-room handoff, and persisted completion.
- Pure-Dart tests verify random incidents remain disabled during onboarding, the Pak RT event bypasses its chaos gate, choice resolution applies once, tutorial progress round-trips under schema version 13, and version-12 saves skip onboarding.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; tutorial state and transitions remain independent from Flutter and Flame.
- The implementation-plan HK-021 checkbox is synchronized with this tracker as requested.

### HK-022 — Levels 1–10 and deterministic unlock definitions

Status: implemented and verified on 2026-10-14.

- Added immutable pure-Dart definitions for levels 1–10, cumulative XP thresholds, ghost unlocks, and room eligibility.
- Added deterministic XP granting and level derivation with invalid grants ignored and XP capped at the level-10 threshold.
- Added a typed `GrantExperience` command through the domain and application controllers so later mission rewards can use the same persisted transition.
- Enforced ghost placement gates from the existing ghost unlock levels: Pocong 1, Kuntilanak 2, Tuyul 3, and Genderuwo 5.
- Connected room 3 and room 4 purchase eligibility to the progression definitions at levels 3 and 5 while retaining their existing 400/800-coin costs.
- Updated the HK-021 first-rent step to award level-2 XP before Kuntilanak placement, so tutorial placement obeys the normal progression gate.
- Persisted `playerExperience` under save schema version 14. Older saves derive the minimum XP for their persisted level, preserving existing unlock access after migration.

Implementation decisions and assumptions:

- The plan specifies ten levels and exact unlock levels but leaves XP thresholds unresolved. HK-022 uses cumulative thresholds `0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200`; these are centralized tuning data rather than UI constants.
- Level is derived only when XP is granted. XP grants are additive, accept positive integers only, and cap at 3200/level 10; they do not decrease levels or overflow beyond the current MVP range.
- Levels 4 and 6–10 intentionally have no content unlocks yet. Inventing missions, rewards, currencies, or additional content remains outside HK-022 and belongs to HK-023 or later tuning work.
- Ghost instances may exist in persisted state before they unlock, but unassigned locked ghosts cannot be placed. This keeps stable ghost IDs and save compatibility while making the actual gameplay gate deterministic.
- Schema 13 and older saves receive the threshold floor for their saved level rather than being reset to level 1 or granted progress beyond what their level already represented.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 129 tests passed.
- Progression tests cover all threshold boundaries, exact unlock definitions, chunk-independent XP grants, level-10 capping, invalid-grant no-ops, ghost/room gates, JSON continuation, schema-13 migration, and application-controller reload.
- The HK-021 widget acceptance flow still passes with the new level-2 gate.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; progression remains pure Dart.
- The implementation-plan HK-022 checkbox is synchronized with this tracker as requested.
