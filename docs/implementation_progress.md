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

- HK-028 and all later tickets.
- Furniture purchasing/inventory, automatic damage generation, tenant departures, IAP, cloud/network services, and final art refinement.

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

### HK-023 — Ten beginner missions and one-time reward claims

Status: implemented and verified on 2026-10-14.

- Added ten ordered, bilingual beginner mission definitions covering Pocong placement, first rent, Kuntilanak placement, first incident, Comfort upgrade, furniture, happiness 70, Tuyul placement, Room 3 unlock, and player level 5.
- Added pure-Dart mission completion checks derived from persisted gameplay evidence instead of transient UI notifications or counters.
- Added atomic `ClaimMissionReward(missionId)` handling across domain and application controllers. A claim validates the mission, prerequisite, objective, and persisted completed-ID set before applying any reward.
- Added centralized coin, XP, and Kristal Mistis rewards. XP uses HK-022's progression system, while Kristal Mistis remains cosmetic-only and is not required by any mechanic.
- Added a localized Flutter mission dialog showing all objectives, exact rewards, progress/claim state, and disabled claimed actions. Current Kristal Mistis is visible in the home status row.
- Persisted Kristal Mistis and completed mission IDs under save schema version 15. Version-14 migration preserves exact XP and initializes mission rewards safely.

Implementation decisions and assumptions:

- Mission order is explicit: `place_pocong`, `collect_first_rent`, `place_kuntilanak`, `resolve_first_incident`, `upgrade_comfort`, `furnish_room`, `happy_tenant`, `place_tuyul`, `unlock_room_03`, and `reach_level_5`.
- Rewards are tuning data rather than widget logic. XP rewards are `25, 25, 50, 50, 75, 75, 100, 150, 250, 250`; coin rewards total 720; Kristal Mistis rewards total 5 across the happiness and level-5 missions.
- Missions must be claimed in order. Completing a later objective early preserves the underlying state, but its reward remains unavailable until the preceding mission has been claimed.
- Placement, rent, incident, upgrade, furniture, happiness, room, and level completion are calculated from current persisted state. No analytics hooks, wall-clock counters, or network state are required.
- `resolve_first_incident` uses the HK-017/HK-019 persisted incident-resolution IDs; the older P0 complaint does not substitute for an incident.
- Mission XP is sufficient to progress from the tutorial's level 2 through the Room 3 and level-5 gates when the ordered objectives are completed. Economy pacing remains tunable and should be revisited with playtest data.
- Kristal Mistis has no spend path in HK-023, consistent with the plan's requirement that key MVP mechanics not depend on premium cosmetic currency.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 137 tests passed.
- Mission tests cover the exact ten-item catalog, all ordered claims, deterministic rewards, prerequisite rejection, incomplete/blank/unknown no-ops, duplicate replay rejection, XP/level progression, five-crystal total, JSON continuation, schema-14 migration, and controller reload.
- Widget coverage verifies a completed mission is visibly claimable, updates coins/XP and persistence once, then exposes a disabled claimed action.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; mission rules and content remain pure Dart.
- The implementation-plan HK-023 checkbox is synchronized with this tracker as requested.

### HK-024 — Complete Indonesian/English localization and language toggle

Status: implemented and verified on 2026-10-14.

- Added a localized language picker that switches the player-facing Flutter UI and active incident dialogue immediately between Indonesian and English.
- Persisted the selected `id`/`en` language code under save schema version 16; restarting with the same save restores the selection. Existing version-15 saves continue to use device locale until the player chooses a language.
- Completed localization for furniture names, preference tags, happiness moods, and Flame-rendered room labels/locked state. Authored incidents and missions retain their existing bilingual pure-Dart content.
- Added catalog parity tests requiring the Indonesian and English ARB files to contain the same nonempty message keys, plus exhaustive checks for every current furniture and preferred-tag identifier.
- Added widget acceptance coverage proving an English save switches the status UI and active incident dialogue to Indonesian, persists the choice, and restores Indonesian after app reconstruction.

Implementation decisions and assumptions:

- A missing saved language deliberately delegates to Flutter's supported device-locale negotiation. An explicit test-only `locale` override remains authoritative so deterministic widget tests can still select a locale without mutating save data.
- The persisted setting stores only supported language codes (`id` or `en`). Blank, unsupported, and duplicate commands are identity-preserving no-ops in the pure-Dart rules layer.
- Simulation content remains Flutter/Flame-free. Flutter resolves furniture/tag/mood copy, while localized strings are injected into Flame components; Flame does not read localization context or own game rules.
- Proper names such as Pocong, Kuntilanak, Tuyul, and Genderuwo are intentionally identical in both languages.
- The debug HUD remains developer-only diagnostic output guarded by `kDebugMode`; it is not player-facing release content and is excluded from the localization catalog.

Verification:

- `flutter gen-l10n` completed successfully.
- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused localization, app, persistence, mission, detail-sheet, and Flame suite passed after updating prior assertions to the localized labels.
- `flutter test`: all 143 tests passed, including catalog parity, exhaustive furniture/tag resolution, bilingual mission copy, language-command validation, schema-15 migration, schema-16 round trip, live dialogue switching, and reload persistence.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; deterministic simulation and localization preference rules remain independent from rendering.
- The implementation-plan HK-024 checkbox is synchronized with this tracker as requested.

### HK-025 — Consent-aware gameplay analytics hooks

Status: implemented and verified on 2026-10-14.

- Added a platform-neutral analytics service boundary with a no-op default, so the game has no analytics SDK, network dependency, account identifier, or external transmission in this ticket.
- Defined the plan's stable event catalog: app, tutorial, placement, room, rent, incident, offline earnings, future rewarded-ad, and future purchase events.
- Added exact per-event payload schemas. Current hooks emit only aggregate numbers, booleans, enum values, and stable authored game-content IDs; arbitrary fields and collection/object payloads are rejected before reaching an adapter.
- Added persisted explicit analytics consent under save schema version 17. Fresh and migrated saves default to denied, and revocation immediately prevents subsequent events.
- Connected successful application-layer transitions for app open, tutorial start/completion, ghost placement, room upgrade/unlock, rent collection, incident start/choice/resolution, and offline earnings. Invalid or duplicate domain commands emit nothing.
- Analytics recording happens only after the deterministic transition and save complete. Adapter failures are swallowed and cannot roll back rewards, state changes, or persistence.

Implementation decisions and assumptions:

- HK-025 supplies hooks and consent enforcement, not a vendor integration. Selecting/configuring an analytics provider and exposing the full localized privacy/consent settings UI remain HK-028 work.
- Consent is a persisted pure-Dart boolean controlled through an idempotent command. There is no implicit opt-in, and enabling consent does not retroactively emit events that occurred while disabled.
- Payloads intentionally exclude names, email addresses, user/device/account IDs, advertising IDs, free text, precise timestamps, locale, IP/location data, save contents, claim/resolution IDs, and raw currency values tied to purchases.
- Room, incident, choice, product, placement, attribute, and ghost-kind identifiers are authored game catalog identifiers, not player identifiers. Future ad/purchase adapters must use the already declared schemas rather than add provider-specific personal fields.
- `incident_choice_selected` and `incident_resolved` are separate hooks emitted after one successful atomic resolution. This preserves the plan's funnel names without creating a second gameplay mutation.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused analytics, application-controller, save migration, pure-domain, lifecycle, and widget suite: all 48 tests passed before the final full regression run.
- `flutter test`: all 150 tests passed.
- Tests prove default denial, explicit persisted opt-in, immediate revocation, exact event order through the tutorial/incident flow, stable payload fields, rejection of unapproved/complex fields, schema-16 migration to denied, schema-17 round trip, and failure isolation.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; consent state and commands remain independent from Flutter and Flame.
- The implementation-plan HK-025 checkbox is synchronized with this tracker as requested.

### HK-026 — Music, sound effects, and persisted audio settings

Status: implemented and verified on 2026-10-14.

- Added an injectable audio service boundary with a production `audioplayers` adapter and a no-op test/default adapter.
- Added an original generated placeholder ambient loop plus distinct generated cues for coin collection, upgrades, room unlocks, incidents, repairs, and ghost placement/moves. No third-party or system audio assets are redistributed.
- Added localized Indonesian/English audio settings with independent music/effect mute controls and 0–100% volume sliders.
- Persisted audio preferences under save schema version 18. Version-17 and older saves migrate to audible defaults: music 35%, effects 70%, neither muted.
- Music starts during application audio initialization, pauses with the app lifecycle, and resumes through the same serialized lifecycle queue used by offline persistence.
- Successful gameplay transitions route cosmetic cues only after state and save completion. Muted effects are suppressed, invalid/no-op commands produce no cue, and adapter failures cannot change deterministic game state.

Implementation decisions and assumptions:

- HK-026 uses small PCM WAV tones generated in code as explicit placeholder audio. Final composed music and mastered SFX remain an asset-production task; replacing the generated sources does not require changing gameplay rules or settings contracts.
- Audio settings belong to pure-Dart saved state, while playback belongs to the injected application service. `lib/simulation` remains free of Flutter, Flame, and audio-plugin imports.
- Music and effects use separate players so a short cue does not interrupt the looping background track. Effect playback uses low-latency mode.
- Mute and volume are independent: muting retains the chosen volume for later unmute. Invalid, non-finite, or out-of-range volumes are rejected atomically.
- Lifecycle audio operations share the existing serialized pause/resume queue. This prevents rapid lifecycle changes from reordering offline snapshots, a race caught and fixed by the focused tests.
- Audio is cosmetic and best-effort. Plugin errors are isolated from saves and gameplay, and automated tests use the injected recording/no-op adapter rather than platform channels.

Verification:

- `flutter pub get` completed with `audioplayers 6.7.1`; no unrelated service SDK was added.
- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- Focused audio, controller, lifecycle, persistence, localization, and settings widget suite: all 50 tests passed after the lifecycle ordering correction.
- `flutter test`: all 154 tests passed.
- `flutter build apk --debug`: succeeded at `build/app/outputs/flutter-apk/app-debug.apk`, validating Android plugin integration.
- Save tests cover schema-18 round trip and schema-17 audible-default migration; controller tests cover initialization, settings updates, mute suppression, lifecycle pause/resume, effects, and reload restoration.
- `rg 'package:(flutter|flame)' lib/simulation`: no matches; audio preferences and validation remain pure Dart.
- The implementation-plan HK-026 checkbox is synchronized with this tracker as requested.

Remaining validation:

- No emulator or physical device was attached, so audible output, device volume interaction, and interruption behavior were validated through the adapter contract, lifecycle tests, and Android build rather than a manual listening session.

### HK-027 — Rewarded ad integration and safe rent claims

Status: implemented and verified on 2026-10-14.

- Added an injectable rewarded-ad service boundary and a production Google Mobile Ads adapter restricted to Android/iOS. Development uses Google's published sample application IDs and rewarded test-unit IDs only.
- Added a localized opt-in action that doubles one pending Collect All payout, with a maximum of three successfully earned bonuses per local calendar day. The normal Collect All action remains independent and available without an ad.
- Added a pure-Dart two-stage rewarded-rent system. Beginning the flow snapshots whole pending coins, commits the base payout, and persists a unique pending bonus claim before asking the platform adapter to load an ad.
- Earned-reward callbacks grant the snapshotted bonus exactly once. Duplicate callbacks, mismatched IDs, completed claims, overlapping claims, and claims above the daily cap are identity-preserving no-ops.
- Ad load failure, dismissal, unavailability, or adapter exceptions clear only the pending bonus. They never reverse or block the already-persisted base payout. A restart also clears an interrupted pending bonus while retaining its base payout.
- Save schema version 19 persists pending/completed rewarded claims and daily successful-bonus state, with explicit version-18 migration defaults.
- Existing consent-aware analytics now records the rewarded flow using the previously allowlisted `ad_offer_shown`, `ad_started`, `ad_reward_earned`, and `ad_failed` schemas. Ad requests are non-personalized; the complete consent/privacy settings work remains HK-028.

Implementation decisions and assumptions:

- The rewarded base and bonus are modeled as one base rent claim plus a separate idempotent bonus record. The bonus never re-claims the pending-rent balance, which may continue accruing while the ad is visible.
- Only successful earned-reward callbacks consume the three-per-day allowance. Failed, unavailable, dismissed, and interrupted attempts do not consume it.
- The local day key is captured when the claim begins, so a callback crossing midnight belongs to the day on which its offer started.
- Test IDs are deliberately hard-coded in the adapter/platform manifests for this ticket. Production ad identifiers and personalized-ad consent must not be introduced before the HK-028 privacy gate and release configuration.
- Mobile Ads initialization is lazy and failures are isolated behind the adapter. The deterministic simulation has no Flutter, Flame, or ads-SDK imports.

Verification:

- `flutter pub get` completed with `google_mobile_ads 5.3.1` resolved from the declared compatible constraint.
- Localization generation and Dart formatting completed successfully.
- Focused rewarded-rent, ad-adapter, persistence, controller, widget, and localization suite: all 55 tests passed.
- `flutter test`: all 165 tests passed.
- `flutter analyze`: no issues found.
- `flutter build apk --debug`: succeeded at `build/app/outputs/flutter-apk/app-debug.apk`, validating the Android plugin and manifest integration.
- Tests cover success, load failure/unavailability, adapter exception, cancellation semantics, duplicate earned callbacks, daily cap/reset, fractional-rent preservation, schema-19 round trip, version-18 migration, interrupted-restart recovery, analytics order, official test identifiers, and visible localized collection feedback.
- `rg 'package:(flutter|flame|google_mobile_ads)' lib/simulation`: no matches; rewarded claim rules remain pure Dart.
- The implementation-plan HK-027 checkbox is synchronized with this tracker as requested.

Remaining validation:

- No emulator or physical device was attached, so a real test-ad load/dismiss/earn session and iOS runtime integration remain unverified. Automated adapter/domain/UI tests and the Android debug build provide the current local evidence.
- HK-027-B is now next; HK-028 remains deferred and continues to own the full consent/privacy settings and optional external error/crash-reporting integration.

### HK-027-B — Production-style visual/audio asset integration

Status: implemented and locally verified on 2026-10-14.

- Used the built-in image-generation workflow with the user-supplied composite sheets as identity/style references. Generated four transparent 4×4 atlases: Pocong, Kuntilanak, Tuyul, and Genderuwo, each with four left-to-right frames for `idle`, `happy`, `angry`, and `special`.
- Normalized every atlas to 1448×1084 RGBA pixels, producing exact 362×271 cells. Flame slices the state rows deterministically and changes the active loop from existing ghost state/happiness without changing simulation rules.
- Added a transparent 2×2 Indonesian kontrakan cutaway derived from image #3's environment direction. The existing room IDs, hit areas, localization labels, locked overlays, and tap routing remain independent components above the art.
- Added an original text-free 128×128 Koin Arwah icon derived from image #2's rendering direction and a text-free 128×128 settings button derived from image #1. Wallet values, tooltips, and semantics remain live localized Flutter content; `Rp`, cash, gems, energy, and baked example counters were not imported.
- Replaced the generated audio tones with the selected supplied `cozy_night_loop.wav` plus coin, upgrade, unlock, incident, repair, and ghost WAV cues. The existing injectable audio service, independent music/effect volume, mute behavior, lifecycle pause/resume, low-latency effects, and failure isolation are unchanged.
- Added a checked-in asset manifest documenting source notes, atlas layout, state order, anchor contract, runtime paths, selected audio, and excluded concepts. Original composite source sheets remain outside the repository.
- Retained the procedural ghost renderer as a test/degraded fallback when no atlas is injected; production `HantuGame` preloads and injects all generated assets.

Implementation decisions and assumptions:

- Image generation created state loops from the selected key-pose art rather than claiming the composite sheet already contained movement frames. Subtle pose variation is intentional; exact pixel interpolation between independently painted frames is not assumed.
- The 4×4 atlas contract is presentation-only: row order is stable and documented, while animation timing differs by emotional state. All special effects remain within the same cell and character component anchor.
- The environment is one composited background because HK-027-B does not add furniture purchasing or placement. Existing room components remain independently selectable, and future interactive furniture can be layered separately.
- Only audio cues already represented by `AudioCue` were adopted. Unused pack concepts do not create new commands, content, or gameplay behavior.
- Full production mastering, additional UI-surface replacement, and art polish can continue without changing these asset IDs or the simulation boundary.

Verification:

- Image-generation outputs were visually inspected before integration; each final workspace atlas preserves the intended ghost identity and contains sixteen transparent frames.
- Focused asset, Flame, controller, app, and widget suite: all 38 tests passed after correcting nested Flutter asset registration.
- `flutter test`: all 169 tests passed.
- Asset tests verify the four-kind manifest, exact 4×4 RGBA dimensions, state order, bundled cutaway/icon, valid RIFF/WAVE headers, mono 44.1 kHz 16-bit music, and silent loop boundaries.
- `flutter analyze`: no issues found.
- `flutter build apk --debug`: succeeded at `build/app/outputs/flutter-apk/app-debug.apk`, validating Android asset and audio packaging.
- `rg 'package:(flutter|flame|audioplayers)' lib/simulation`: no matches; no deterministic rule, save schema, economy value, or monetization flow changed.
- The implementation-plan HK-027-B checkbox is synchronized with this tracker.

Remaining validation:

- No emulator or physical device was attached. Atlas scale/readability, perceived animation smoothness, music repetition, effect loudness, and audible loop quality still require an actual-device art/audio review.
- The selected audio remains prototype material per its supplied README. Final mastering or replacement can retain the current paths and adapter contract.
- HK-028 is now the next unfinished ticket.

### HK-028 — Consent, privacy, and optional crash reporting

Status: implemented and locally verified on 2026-10-14.

- Added localized privacy settings beside the existing audio settings. Analytics and external crash/error reporting are independently opt-in, persist across reload, default off, and explain that the offline game remains playable without external services.
- Added a Google UMP adapter that refreshes consent information at launch, loads a required consent form, reports whether ads may be requested, and exposes the privacy-options form only when required.
- Gated the Google rewarded-ad adapter on UMP `canRequestAds`. Consent failure or unavailable external services return the existing safe unavailable/base-only path and do not block local collection or play.
- Added an injectable error-reporting boundary plus consent-aware wrapper. Flutter framework errors and uncaught platform-dispatcher errors are wired at bootstrap when a provider is configured; this repository deliberately ships a no-op delegate because no crash provider credentials/configuration were supplied.
- Added save schema 20 for crash-reporting consent with explicit version-19 migration to disabled. Consent commands and persistence remain pure Dart.

Implementation decisions and assumptions:

- Analytics consent is not treated as ad consent. Google UMP independently owns ad eligibility and required privacy choices.
- External diagnostic transmission is denied until the saved opt-in is loaded. Adapter errors are best-effort and never allowed to alter deterministic game state or stop startup.
- A provider-specific crash SDK, production ad IDs, privacy-policy URL, and store declarations remain release configuration rather than invented local defaults. The provider boundary is ready for that configuration.

Verification:

- Localization generation and Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 175 tests passed.
- `flutter build apk --debug`: succeeded at `build/app/outputs/flutter-apk/app-debug.apk`.
- New tests cover schema-20 round trip, version-19 disabled migration, idempotent pure-Dart consent commands, reporter opt-in/failure isolation, persisted localized settings, required ad privacy entry, and continued offline play when the privacy adapter throws.
- `rg 'package:(flutter|flame|google_mobile_ads)' lib/simulation`: no matches; deterministic simulation remains platform-independent.
- The implementation-plan HK-028 checkbox is synchronized with this tracker.

Remaining validation:

- No emulator or physical device was attached, so the live Google UMP form/privacy-options flow and device-level framework crash capture remain unverified.
- No external crash-reporting vendor is configured. Vendor console delivery can only be integration-validated after the owner selects a provider and supplies its platform configuration.
- HK-029 is now the next unfinished ticket.

### HK-029 — Regression, lifecycle, device, and performance pass

Status: implemented and locally/device verified on 2026-10-14.

- Added an integration-test target for a bounded offline device smoke flow covering application launch, Flame asset loading, visible wallet state, rent collection and persistence, and opening settings without framework exceptions.
- Added compact 360×640 and large 430×932 phone viewport regressions for the home and settings surfaces.
- Added deterministic performance and economy stress coverage: 10,000 one-second simulation commands under a five-second guard, exact JSON continuation, 100 repeated save/reload cycles, fractional-rent preservation, and duplicate claim rejection.
- Fixed the compact-width overflow discovered by the new test. The wallet, crystal, and happiness summary now wraps responsively instead of forcing one horizontal row.
- Existing lifecycle, offline snapshot, rewarded-claim, migration, incident, mission, progression, asset, localization, and analytics/privacy coverage remains part of the complete regression suite.

Implementation decisions and assumptions:

- With no previously documented device matrix, local acceptance uses 360×640 and 430×932 logical phone viewports plus the connected physical iPhone running iOS 26.6.2. Android runtime validation requires a connected Android target; Android compilation/package integration is covered by the debug APK build.
- Timing limits are intentionally coarse regression tripwires rather than claims of 60/120 FPS profiling. HK-029 does not add production telemetry or change game balance to improve a benchmark.
- The device integration test injects local services so external consent, ads, audio, and reporting cannot make the core offline smoke flow flaky.

Verification:

- Dart formatting completed successfully.
- `flutter analyze`: no issues found.
- `flutter test`: all 178 tests passed.
- `flutter test integration_test/hk029_device_test.dart -d <connected iPhone>`: one device integration test passed, including automatic signing, Xcode build, installation, launch, and interaction.
- `flutter build apk --debug`: succeeded at `build/app/outputs/flutter-apk/app-debug.apk`.
- The focused HK-029 suite passes both target viewport layouts, the 10,000-command performance guard, exact reload continuation, repeated serialization, fractional economy preservation, and duplicate-claim protection.
- No high-severity save or economy defect is known after the complete regression pass.
- The implementation-plan HK-029 checkbox is synchronized with this tracker.

Remaining validation:

- No Android phone or emulator was connected, so physical Android interaction/frame behavior remains unverified despite the successful Android debug build.
- The device smoke provides a broad responsiveness guard, not detailed raster/UI frame timing or long-duration thermal profiling across low-end hardware.
- HK-030 is now the next unfinished ticket.

### HK-030 — Store material and Android closed-test preparation

Status: locally prepared and verified on 2026-10-14; acceptance remains blocked on owner-controlled release inputs.

- Fixed the reported black Flame game area. `KontrakanWorld` was incorrectly nested as a second Flame `World`, whose normal render tree Flame intentionally suppresses. It is now a `PositionComponent`, the camera is centered on the 360×360 scene, and asset failures retain procedural fallback rendering.
- Added a bounded-frame physical-device screenshot harness. The latest iPhone development capture visibly contains the cutaway building, rooms, Pocong, and Tuyul; it proves the blank-screen defect is resolved.
- Added a generated 1024×1024 launcher icon and propagated it to all existing Android mipmap and iOS AppIcon slots.
- Added localized Indonesian/English in-app privacy-policy text and a tested settings entry, plus store-listing, privacy-policy, and closed-test drafts under `docs/store/`.
- Changed the Android launcher label to `Hantu Kontrakan` and removed release use of the debug signing key. An unsigned release AAB compiles successfully and is explicitly not represented as uploadable.

Implementation decisions and assumptions:

- Android now uses the owner-confirmed `com.indesyakaryadigital.hantu_kontrakan` application ID. iOS remains unchanged because Apple does not allow the underscore in that exact identifier; selecting its permanent Apple-compatible form remains an owner decision.
- The canonical privacy policy uses the confirmed publisher contact. Its public HTTPS URL, production Google Mobile Ads IDs, and Play upload key remain owner-controlled release inputs.
- Store screenshots must contain real app UI and no debug HUD. Physical-iPhone profile captures now cover gameplay and settings; they still require final Android release-candidate confirmation before Play upload.
- Deterministic simulation and balance were not changed.

Verification:

- `flutter gen-l10n`: completed successfully.
- Dart formatting: completed with no remaining changes.
- `flutter analyze`: no issues found.
- `flutter test`: all 180 tests passed, including the Android application-ID guard and localized in-app privacy-policy coverage.
- Focused Flame tests: 2 passed, including 360×360 camera framing.
- Debug `flutter drive ... -d <connected iPhone>`: passed on iOS 26.6.2; the captured 1125×2436 image visibly shows the rendered cutaway and ghost sprites.
- Profile device capture: built, installed, launched, and passed on iOS 26.6.2. Visually inspected 1125×2436 gameplay and settings screenshots contain real app UI, no debug HUD, the rendered cutaway, ghost sprites, and the privacy settings entry. The harness waits for Flame's loading marker to disappear and advances bounded frames before capture; screenshot transfer is excluded from the debug responsiveness timer.
- `flutter build appbundle --release`: succeeded at `build/app/outputs/bundle/release/app-release.aab` (57.6 MB).
- `jarsigner -verify ...`: reports `jar is unsigned`, confirming that no debug or fabricated production signature was used.
- `rg 'package:(flutter|flame|google_mobile_ads)' lib/simulation`: no matches.

Remaining acceptance work:

- Owner must select the Apple-compatible permanent iOS bundle identifier and publish the canonical policy at a public HTTPS URL.
- Owner must supply Play upload signing outside version control and Play Console access, replace test ad IDs, complete Data safety/ads/content declarations, and install-test the Play-delivered closed-track build.
- Capture final non-debug Android phone screenshots from that signed release candidate.
- HK-030 remains unchecked in the implementation plan because a functioning closed beta package has not yet been uploaded and validated.

Follow-up configuration on 2026-10-14:

- Applied the confirmed Android namespace/application ID `com.indesyakaryadigital.hantu_kontrakan` and moved `MainActivity` to its matching Kotlin package.
- Did not apply that exact value to iOS because Apple bundle identifiers reject underscores. A valid Apple-compatible alternative remains an explicit owner decision before the App Store identifier is registered.
- Replaced the privacy draft with canonical `docs/store/PRIVACY_POLICY.md`, including the confirmed publisher, support contact, local-data behavior, optional diagnostics, rewarded-ad processing, deletion behavior, security, and publication instructions. The localized in-app privacy dialog now mirrors those material disclosures.
- Added `docs/store/ADMOB_SETUP.md` with platform app-ID, rewarded-unit, test-device, UMP, app-ads.txt, store-declaration, and closed-track verification steps. Production identifiers remain intentionally unset.

### Pre-beta gameplay and UX review

Status: review complete on 2026-10-14; redesign implementation not started.

- Audited the physical-device home screenshot, Flutter/Flame composition,
  mission/progression content, rent presentation, room panels, incident cadence,
  furniture choices, and audio assets after player feedback reported a
  prototype-like UI and five-minute boredom.
- Confirmed the issue is both presentation and game design: the world is boxed
  inside an application shell, primary actions live in administrative controls,
  and the current one-time content cannot sustain repeat 10–30 minute sessions.
- Added the canonical redesign proposal at `docs/GAMEPLAY_UX_REVIEW.md` and a
  high-fidelity direction concept at `docs/gameplay_ux_redesign_concept.png`.
- Recommended UX-R1 through UX-R6 before final HK-030 closed-beta acceptance.
  No gameplay code, deterministic balance, saves, or release configuration was
  changed by this review.

Roadmap preparation follow-up:

- Converted the proposal into ordered pre-beta tickets HK-030-A through
  HK-030-F in the implementation plan, with HK-030-A as the next unfinished
  implementation task.
- Added the agreed property-portfolio direction: the existing four-room
  kontrakan is Chapter 1; full occupancy leads to optimization and expansion,
  earlier properties remain useful, and at least one second playable property
  or progression stage is required before monetized beta.
- Prepared HK-030-A boundaries and acceptance criteria. It changes only the
  full-screen shell, HUD, navigation, and action reachability; per-room economy,
  panel redesign, recurring goals, portfolio state, and new audio remain in
  their later tickets.
- HK-030-A is complete and locally verified. Its implementation did not include
  the panel redesign or later economy work delivered by subsequent tickets.

### HK-030-A — Full-screen world shell

Status: locally verified on 2026-10-14.

- Replaced the application-style home scaffold with an edge-to-edge Flame world,
  a compact themed HUD, four-destination bottom navigation, safe-area overlays,
  and in-world collection, complaint, and incident controls.
- Kept settings, language, missions, ghost profiles, room improvements, normal
  collection, and rewarded collection reachable. Rewarded collection moved to
  a secondary action panel without changing eligibility or claim behavior.
- Added localized English and Indonesian navigation/action labels and responsive
  widget coverage at 360x640 and 430x932. The tests assert that the game surface
  fills both viewports, no `AppBar` remains, and all four navigation routes work
  without overflow.
- Preserved the pure-Dart simulation, balance, persistence schema, ad adapter,
  and audio lifecycle. No `lib/simulation` files changed for this ticket.
- Validation evidence: `dart format lib test` completed with no pending format
  changes; `flutter analyze` reported no issues; all 180 `flutter test` tests
  passed; `flutter build apk --debug` produced
  `build/app/outputs/flutter-apk/app-debug.apk`; `git diff --check` passed.
- A fresh physical iOS screenshot could not be captured in this environment:
  the wired device lacks a usable provisioning profile, while the already
  provisioned wireless device installed/launched the app but did not expose its
  Dart VM service. Automated acceptance and the Android artifact are unaffected.

### HK-030-B — Themed interaction system

Status: locally verified on 2026-10-14.

- Added shared game-panel primitives for dialogs, bottom sheets, choice cards,
  primary actions, and secondary actions using the established night, wood,
  parchment, gold, and green visual language.
- Migrated room, ghost, mission, incident, complaint, incident-result,
  destination/swap, language, settings, privacy, action-center, and locked-room
  flows. No primary feature flow retains `AlertDialog` or `SimpleDialog`.
- Reworked mission presentation into readable stacked cards with an explicit
  reward preview and guarded claim action. Existing mission ordering, rewards,
  eligibility, and exactly-once domain behavior remain unchanged.
- Added a one-time offline-return panel backed by the rent delta already
  calculated by deterministic resume processing. The delta is presentation-only
  transient controller state; no simulation rules or persisted schema changed.
- Added panel regression coverage for compact portrait layout with visible
  keyboard and 1.5x text scaling, duplicate primary-action taps, and exactly-once
  offline-summary consumption. Existing English and Indonesian gameplay widget
  tests continue to cover settings, missions, complaint, and incident flows.
- Validation evidence: formatting completed; `flutter analyze` reported no
  issues; all 183 `flutter test` tests passed; Android debug build succeeded;
  `git diff --check` passed.
- HK-030-C is the next unfinished ticket. This work does not add per-room rent,
  coin bubbles, collect-one state, or any save migration reserved for HK-030-C.

### HK-030-C — In-world rent collection

Status: locally verified on 2026-10-15.

- Replaced the single claimable-rent bucket with schema-v21 persisted per-room
  microcoin balances and per-room fractional accrual remainders. Existing
  aggregate accessors remain compatibility views over those room balances.
- Added deterministic v20 migration that assigns the legacy aggregate balance
  to the first eligible room in stable room-ID order. Save/reload preserves
  every room balance and remainder exactly.
- Rent ticks and offline earnings distribute their exact aggregate microcoins
  across eligible rooms in stable order. Regression coverage proves totals are
  chunk-independent and equal before and after reload.
- Added accessible Flutter coin bubbles anchored over the Flame rooms. A player
  can collect one room or all rooms; both paths preserve sub-coin fractions,
  persist atomically, and share claim-ID duplicate protection.
- Added themed collection feedback and a one-time offline-return breakdown by
  room. The controller holds only transient presentation deltas; simulation and
  persistence remain independent from Flame rendering.
- Normal rent is credited before any rewarded prompt is offered. The optional
  ad action applies only a snapshotted bonus, so unavailable, dismissed,
  interrupted, or duplicate callbacks cannot withhold or duplicate base rent.
- Physical-iPhone integration evidence captured the home, collection result,
  and settings flows on 2026-10-15. Review found readable panels and a visible
  room-to-HUD flow; a follow-up layout patch shortened visible HUD labels while
  retaining full semantic labels, moved bubbles clear of room titles, and
  raised collect-all above bottom navigation. That final patch passes widget
  layout tests. Recapture attempts compiled, signed, installed, and launched;
  one was denied Xcode automation (`osascript: -2`) and the retry could not
  discover the Dart VM service over the wireless connection.
- Validation evidence: formatting completed; `flutter analyze` reported no
  issues; all 186 `flutter test` tests passed; Android debug build succeeded;
  the earlier iPhone integration run passed; `git diff --check` passed.
- HK-030-D is the next unfinished ticket. No recurring contracts, tenant
  requests, daily chest state, portfolio progression, or audio redesign was
  added in HK-030-C.

### HK-030-D — Repeatable session goals

Status: locally verified on 2026-10-15.

- Reframed the original ten ordered missions as localized Chapter 1 content
  without changing their prerequisites, rewards, or exactly-once claims.
- Added three daily actions: collect rent twice, actively manage the property
  for three minutes, and collect from one deterministic unlocked tenant room.
  The tenant target rotates by local day across occupied unlocked rooms, with
  an unlocked-room fallback during onboarding.
- Added schema-v22 persistence for the local day key, tenant target, bounded
  progress, claimed task IDs, and daily chest state. Version-21 saves migrate
  with no active schedule and receive one on controller initialization.
- Daily refresh is a pure-Dart command: the same day is identity-preserving;
  a later valid day deterministically resets progress, claims, and chest state.
  Progress is derived only from successful simulation commands, so duplicate
  rent claims and offline time cannot inflate it.
- Added localized progress bars, compact status feedback, task rewards, and an
  exactly-once daily chest. All rewards are ordinary coins/XP and no task or
  chest requires advertising, locked rooms, or moving a valid tenant layout.
- Added a lifecycle-aware foreground ticker that advances the existing pure
  simulation by ten deterministic seconds. It pauses with the app and makes
  active rent generation and the management-time task function in normal play,
  not only through the debug control.
- Validation evidence: formatting completed; `flutter analyze` reported no
  issues; all 195 `flutter test` tests passed; Android debug build succeeded;
  `git diff --check` passed. Coverage includes local-day rollover, chunking,
  save/reload, v21 migration, duplicate claims, lifecycle pause, localization,
  and the three-task/Chapter 1 widget flow.
- A physical-iPhone run compiled, signed, installed, launched, exercised the
  home/collection/daily-goals/settings sequence, and captured the daily panel
  with live `1/2` rent and `10/180` active-time progress. Its final assertion
  incorrectly included screenshot-transfer latency; after correcting that
  harness issue, the retry could not rediscover the Dart VM service over Wi-Fi.
- HK-030-E is the next unfinished ticket. This ticket adds no owned furniture,
  second property, portfolio economy, crystal sinks, or audio redesign.

### HK-030-E — Visible progression and property portfolio

Status: locally verified on 2026-10-15.

- Added schema-v23 persistence for the active property, stable per-property
  room sets, owned furniture, and completed ghost stories. Version-22 saves
  migrate into `kontrakan_pertama` with all existing furniture treated as
  starter-owned, preserving the prior room and economy state.
- Completing all four initial rooms now enables a free expansion into
  `kontrakan_pasar`, a second four-room playable cutaway. Unlocking also adds a
  new Pocong tenant, while level 5 now deterministically adds the Genderuwo
  needed to complete the initial property.
- Property switching persists the room state of both locations. All owned
  properties accrue rent in stable property/room order, while the selected
  property alone is rendered and directly managed. Globally unique room IDs
  keep balances, remainders, claims, and reloads unambiguous.
- Added derived room tiers, a filtered owned-furniture picker, and two optional
  crystal workshop items. Required progression remains free and works with
  zero crystals, ads, IAP, or network access.
- Expanded the ghost roster with saved, exactly-once story milestones that
  become available after the ghost is housed. The localized portfolio shows
  story completion, property occupancy, active/visit state, expansion status,
  owned inventory, and crystal prices.
- Added pure-Dart coverage for free expansion, cross-property earning,
  revisiting, schema migration, ownership enforcement, crystal spending, story
  persistence, and room tiers, plus widget coverage for the complete expansion
  and property-switch route and Flame coverage for dynamic room IDs.
- Validation evidence: formatting completed; `flutter analyze` reported no
  issues; all Flutter tests passed; Android debug build succeeded; and
  `git diff --check` passed.
- HK-030-F is the next unfinished ticket. HK-030-E does not replace music,
  ambience, effects, haptics, or reduced-motion behavior.

### HK-030-F — Audio identity and game feel

Status: implementation and technical validation complete on 2026-10-15;
subjective 20-minute audio acceptance remains pending.

- Evaluated both supplied packs rather than treating their README files as
  instructions. V2 is the stronger foundation: three materially distinct
  16.55–20.87 second themes and 34 purpose-specific effects replace the first
  pack's smaller generic vocabulary.
- Updated the checked-in deterministic audio builder and generated a
  154.11-second mono PCM16 32kHz horror-comedy night suite from nine varied
  movements across all three V2 themes. Sample peaks stay below full scale and
  the manifest records the source, method, duration, and expanded sound set.
- Expanded the runtime adapter to independent main, tension, ambience, and
  effect players. Cricket or breeze ambience occurs at randomized 24–51 second
  intervals; active incidents or chaos 70+ add a quiet mystery tension stem.
  Every player pauses, resumes, updates volume, and disposes with the
  application lifecycle.
- Added distinct rent, furniture, upgrade, unlock, reward, repair, positive and
  negative incident, UI, and happiness-sensitive per-character tenant cues.
  Cosmetic adapter failures remain isolated after state and save completion.
- Added schema-v24 persisted haptic and reduced-motion preferences with v23
  migration. Production uses native haptics behind an injectable adapter;
  reduced motion removes particle travel and respects the platform animation
  preference while retaining color-independent icon feedback.
- Added controller, migration, localization, settings, asset-duration,
  no-short-track, scene-transition, haptic-gating, and visual-feedback tests.
  A dedicated physical-device flow uses the real audio plugin and covers rent,
  incident tension/resolution, settings, lifecycle pause/resume, screenshot,
  and clean teardown.
- Physical iPhone evidence: the app compiled, signed, installed, launched, the
  audio/feedback lifecycle scenario passed, and no native audio exception or
  lingering playback callback remained. The same real-plugin flow was rerun
  after the V2 replacement and passed in 13 seconds. Formatting was clean,
  `flutter analyze` found no issues, all 208 tests passed, the Android debug APK
  rebuilt, and `git diff --check` passed. Automated checks cannot judge whether
  the procedurally synthesized music is premium or pleasant for a full 20
  minutes.
- Final ticket acceptance therefore requires a human 20-minute listen on a
  target phone, checking repetition, music/effect balance, speaker distortion,
  incident tension, mute/volume controls, and personal horror-comedy fit.

### HK-030-G1 — Interaction correctness

Status: locally verified on 2026-10-15.

- Added two-way tenant assignment: a vacant unlocked room can choose an
  eligible unassigned ghost, and an unassigned ghost profile can choose an
  eligible vacant unlocked room. Eligibility is checked through the existing
  pure-Dart placement rule and successful placement uses the saved controller
  command.
- Mission navigation now displays its attention badge only when a chapter
  reward, daily reward, or daily chest is actually claimable. Merely having
  unfinished tasks no longer produces a permanent red notification.
- Removed the floating secondary world action that overlapped Collect All.
  Normal collection remains immediate and the optional rewarded bonus remains
  available only after base rent has been collected and persisted.
- Made level, coin, and crystal HUD chips interactive. Localized panels now
  show level progress and immediate objectives, the current rent rate, and the
  actual crystal uses/sources already supported by the game. The crystal panel
  does not imply an unavailable purchase flow.
- Added English and Indonesian strings plus widget coverage for vacant-room
  assignment, Room 3 assignment persistence, claimable-only mission attention,
  the removed overlap control, and all three HUD explanations.
- Verification passed: formatting, `flutter analyze`, the focused room/detail,
  home widget, and localization tests, all 210 Flutter tests, an Android debug
  APK build, and `git diff --check`.
- HK-030-G2 is next. Portrait world composition, room/lock visual redesign,
  profile simplification, navigation onboarding, and commercial audio remain
  deliberately outside G1.
