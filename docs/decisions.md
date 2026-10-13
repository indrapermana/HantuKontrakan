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

## HK-006 ghost definitions and animation decisions

Date: 2026-10-13

- Four immutable definition records now contain the plan's base rent, unlock level, ten-minute chaos contribution, preferred tags, positive/disliked neighbors, and stable ability ID. Only Pocong and Tuyul remain instantiated; roster unlocks and placement are deferred.
- Placeholder animation selection is deterministic: special-action state overrides happiness; otherwise happiness 80+ is happy, below 40 is angry, and 40–79 uses idle. The four modes use distinct procedural motion/facial effects without adding provisional sprite assets.
- `specialActionActive` belongs to the ghost instance state and changes through a typed command. This lets simulation state drive Flame rendering and makes the debug toggle useful for visual verification.
- Persisting special-action state advances the save schema to version 3. Version-1 and version-2 saves migrate with special actions inactive; current saves round-trip the flag.
- Ability effects and cooldown execution remain deferred to HK-014. HK-006 stores only stable ability identifiers in definitions.

## HK-007 tenant placement decisions

Date: 2026-10-13

- `GameState` validates unique ghost IDs, unique room IDs, existing occupant references, and one room per ghost. This makes one-to-one occupancy an invariant at construction and save-load boundaries instead of relying only on individual commands.
- Placement and movement are separate pure-Dart rules. Placement requires an existing unassigned ghost and vacant room; movement requires an assigned ghost and valid different destination.
- An occupied destination is an identity-preserving no-op unless the command explicitly sets `allowSwap`. Authorized swaps update both rooms in one immutable transition; malformed IDs, same-room moves, and unassigned-ghost swaps are no-ops.
- The Flutter room sheet asks for a concrete destination. Occupied destinations require a separate confirmation before dispatching an authorized swap; vacant destinations move directly.
- Only rooms already present in simulation state are eligible destinations. The locked presentation-only upper rooms remain unavailable until HK-010, and HK-007 does not add the four-room economy or roster unlock behavior.
- Occupancy has not changed shape, so save schema version 3 remains valid. Previously valid saves load unchanged, while invalid duplicate or dangling occupancy is rejected through the existing corrupt-save recovery path.

## HK-008 happiness and compatibility decisions

Date: 2026-10-13

- Adjacency now uses persisted `(column, row)` coordinates and Manhattan distance 1. Horizontal and vertical shared edges count; diagonals and gaps do not. This aligns simulation with the plan's 2×2 cutaway rather than Flame pixel geometry.
- The complete directional compatibility matrix lives in the pure-Dart happiness system. Values are summed across adjacent occupied rooms and then clamped to `[-20, +15]`; symmetry is never inferred.
- Room environment tag levels and equipped-furniture tags are separate immutable values on `RoomState`. Empty values are neutral, preserving existing P0 happiness until HK-010 introduces upgrade and furniture commands.
- A level-1/level-2 room tag matching a resident preference contributes +10/+15; a configured nonpreferred room tag contributes -5/-10. The room subtotal is clamped to `[-20, +20]`.
- A furniture tag matching a preferred tag contributes +5; a configured nonpreferred furniture tag contributes -2. The furniture subtotal is clamped to `[-10, +10]`. Duplicate tags are collapsed by the set representation.
- HK-008 resolves happiness scoring at the tag-and-level boundary. HK-010 will map named room attributes and individual furniture IDs to these inputs; it must not introduce new happiness point values in widgets or commands.
- Happiness remains a deterministic derived value from base 50 plus room, furniture, compatibility, and event components, followed by a final `[0, 100]` clamp. Existing mood thresholds remain unchanged.
- Persisting row and tag inputs advances the save schema to version 4. Version 3 and older saves migrate with row 0 and empty tag sets, retaining their prior horizontal adjacency and happiness.

## HK-009 detail sheet decisions

Date: 2026-10-13

- Room and ghost taps are separate Flame callbacks. Tapping the room surface opens room details; tapping an occupied room's ghost opens that ghost's profile. Flutter continues to own both modal sheets.
- `HappinessSystem.breakdownFor` is the single pure-Dart source for the displayed base, room, furniture, neighbor, event, and total values. The total calculation and presentation cannot drift into separate formulas.
- Occupied room sheets show the tenant, localized mood, complete happiness breakdown, profile action, and move/swap action. Vacant rooms show vacancy and omit tenant-only actions; locked presentation rooms retain their read-only sheet.
- Ghost profiles read immutable definition and state data for archetype, current room, total happiness, base rent, preferred tags, disliked neighbor, and ability. Assigned ghosts expose move/swap; unassigned ghosts do not.
- Placeholder Material icons remain sufficient profile artwork for HK-009. Upgrade controls, furniture slots, unlock actions, and final illustrations stay deferred to HK-010 or later.
- New player-facing detail copy is localized in Indonesian and English. Stable content IDs remain internal and are mapped to localized ability text in the Flutter presentation layer.
