# P0 implementation decisions

Date: 2026-10-11

- The repository was empty except for the implementation plan and was not a Git repository. The P0 establishes the initial Flutter architecture without altering pre-existing application code.
- P0 persistence uses `shared_preferences` with one JSON document and an explicit schema version. Drift is deferred until later milestones need transactions, migrations, and multiple durable records.
- P0 includes only two horizontal room positions. Adjacency is derived from their column coordinates, so the pure Dart rule can reject non-adjacent rooms without depending on Flame geometry.
- Room and furniture happiness contributions are zero in P0 because upgrades and furniture belong to later tickets. Compatibility and event modifiers follow the specified caps.
- The one scripted complaint is resolved permanently. Its three deterministic choices are: soundproofing (−50 coins, Pocong +20), ask Tuyul to calm down (Pocong +10, Tuyul −10), or a peace offering (−25 coins, both +5). These are slice-only tuning values, not the final ten-incident economy.
- Moving in the two-room slice is an atomic occupied-room swap. Vacancy placement and the four-room model remain outside P0.
- Placeholder ghosts and the building are drawn with Flame canvas primitives. Mood changes alter outline color and animation speed, avoiding premature asset production.
- The P0 UI initially used Indonesian-only copy. HK-001 now provides generated Indonesian/English localization scaffolding and localizes the current Flutter presentation; complete future game content and the player-facing language toggle remain part of HK-024.

## HK-001 foundation decisions

Date: 2026-10-11

- Routing uses a small named-route `AppRouter`. There is only one current route, but future screens can be added without moving navigation decisions into feature widgets.
- Theme construction lives in `AppTheme` instead of the root widget so later accessibility and visual variants have one configuration boundary.
- Flutter's generated ARB localization is used with Indonesian and English resources. The device locale is honored automatically; tests inject a locale when validating exact copy.
- Portrait mode is enforced twice: `SystemChrome` protects the running Flutter view, while Android and iOS manifests prevent platform-level landscape presentation during startup and lifecycle changes.

## HK-002 building prototype decisions

Date: 2026-10-11

- The Flame camera retains its 360×360 fixed design resolution. Four 170×132 rooms fit in a 2×2 grid with the locked upper floor above the two occupied P0 rooms.
- Rooms 03 and 04 are presentation-only locked placeholders for this ticket. They are not added to persisted simulation state, avoiding premature four-room economy, unlock, or migration behavior before HK-003/HK-010.
- Each `RoomComponent` owns a stable room ID and funnels `TapCallbacks.onTapUp` through one `select()` path. This keeps pointer handling inside Flame while the selected-room sheet remains Flutter-owned.
- Selecting a locked placeholder opens a read-only localized sheet containing its room ID. Unlock controls and costs remain deferred to HK-010.

## HK-003 domain foundation decisions

Date: 2026-10-11

- `GameState` remains composed of simple value objects, but now defensively copies its ghost and room inputs into unmodifiable lists. Callers cannot mutate current or previous state through retained list references.
- Domain changes enter through sealed commands and a pure Dart `GameStateController`. It applies deterministic rules, advances its revision only for a real transition, and returns whether a command changed state.
- The existing Flutter `GameController` remains the application adapter for `ChangeNotifier` and persistence. It delegates state transitions to the pure controller, then notifies and saves only when dispatch succeeds.
- Existing P0 complaint costs, happiness effects, and the stable resolution ID moved into `GameBalance`; this is organization of established behavior, not a balance change.
- Equality/value-generation packages were not added. Identity-preserving no-ops plus immutable state are sufficient for the current command surface; structural equality can be reconsidered if later state tooling requires it.

## HK-004 persistence decisions

Date: 2026-10-13

- Save loading returns one of three explicit outcomes: not found, loaded, or rejected. Rejections distinguish corrupt data from a well-formed save using an unsupported schema version.
- `GameState.fromJson` validates that `schemaVersion` is an integer before dispatching to the version-1 decoder. Unknown integer versions throw `UnsupportedSaveVersion`; missing or malformed versions are corrupt input.
- A rejected SharedPreferences payload remains at its original key and is also copied to a stable backup key before the app falls back. This avoids silently destroying forward-version or diagnostically useful corrupt data.
- The application controller exposes the rejection reason, seeds a playable state, and does not write during recovery initialization. A later real player command may create a fresh current-version primary save while the rejected backup remains available.
- No speculative migration was added because version 1 is the only released schema. Future versions must add an explicit decoder/migration branch rather than weakening current validation.

## HK-005 debug runtime decisions

Date: 2026-10-13

- The debug HUD is compiled into debug builds only via `kDebugMode`. It uses concise developer-facing English labels rather than expanding player localization scope.
- Chaos starts at the specified provisional value of 40 and active simulation seconds start at zero. HK-005 manual ticks advance only this persisted counter; real fixed-step economy, chaos intervals, and offline behavior remain deferred.
- Adding persisted chaos and active seconds advances the save schema to version 2. Version-1 saves migrate explicitly with chaos 40 and zero active seconds, preserving all prior wallet, ghost, room, and complaint fields.
- `GameClock` and `SeededRandomSource` are injectable application-runtime dependencies. Production uses system time and seed `20261011`; tests inject fixed time/seed, and reset rewinds the random source.
- Debug reset dispatches through the same pure command controller and save path as other changes. It restores the seeded state and persists it rather than mutating UI-only values.
