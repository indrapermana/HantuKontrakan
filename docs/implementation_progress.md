# Implementation progress

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

## Scope intentionally deferred

- HK-015 and all later tickets.
- Furniture purchasing/inventory, random incidents, ads, IAP, analytics, cloud/network services, final artwork, and full localization.

## Verification evidence

- `/Users/indra/flutter/bin/cache/dart-sdk/bin/dart format lib test`: 20 files formatted successfully.
- `flutter analyze`: no issues found.
- `flutter test`: 9 tests passed. Coverage includes directional compatibility, adjacency and caps, atomic swapping, idempotent incident effects, controller reload, JSON persistence/corrupt-save fallback, and the visible Flutter complaint flow.
- `flutter build apk --debug`: succeeded; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.
- Acceptance flow is covered by the widget and controller tests: initial Pocong happiness 35 from the −15 Tuyul penalty; soundproofing resolves the complaint once, changes coins 200 → 150 and happiness 35 → 55, then persists the resolved state.

## Remaining validation

- No emulator or physical-device session was attached, so touch interaction and cold restart were validated through automated tests and the Android build rather than a manual device run.
- A physical-device launch remains pending; Android bootability is currently evidenced by the successful debug APK build and automated widget tests.
