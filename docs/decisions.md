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

## HK-010 room upgrades, unlocks, and furniture decisions

Date: 2026-10-13

- All four rooms now belong to persisted simulation state. Rooms 01/02 seed unlocked; rooms 03/04 seed locked at their established cutaway coordinates. Flame renders `RoomState.unlocked` rather than treating every vacancy as locked.
- Player level is persisted as the deterministic input to room gates, initially level 1. HK-010 does not add XP or level progression; that remains HK-022.
- Room 03 costs 400 coins and requires level 3; room 04 costs 800 coins and requires level 5. Unlock commands require both conditions, spend atomically, and are no-ops for unknown or already unlocked rooms.
- Comfort, silence, mystical affinity, and durability use levels 0–2. Upgrades cost 100 coins from level 0 and 200 from level 1; level 2, insufficient funds, and locked rooms are no-ops.
- Upgrade-to-preference mapping is comfort → `decorated`, silence → `quiet`, mystical affinity → `mystical`, and durability → `sturdy`. The resulting level feeds HK-008's existing room preference scores and caps.
- Each room has exactly one primary and one decoration furniture slot. Equipping validates the stable furniture definition and slot, replaces only that slot, and rebuilds the room's derived furniture tags atomically.
- The plan's twelve placeholder furniture items are split evenly across the two slots. Primary: bed/quiet, reinforced shelf/sturdy, fan/quiet, dresser/decorated, door/sturdy, lamp/shiny. Decoration: plant/plant, lantern/mystical, curtain/quiet, rug/decorated, wall charm/mystical, shiny trinket/shiny.
- Furniture is currently freely selectable because shop ownership and purchase prices are later economy/content scope. HK-010 establishes slot validation and happiness effects without inventing a premature purchase system.
- Save schema advances to version 5 for player level, unlock state, upgrades, and furniture IDs. Version-4 and older saves retain their existing rooms as unlocked and gain rooms 03/04 as locked defaults.

## HK-011 deterministic rent accrual decisions

Date: 2026-10-13

- Rent uses integer microcoins (`1 coin = 1,000,000 microcoins`) throughout. Happiness, room, and chaos multipliers are integer percentages, so no floating-point arithmetic enters simulation state.
- Per-minute rates implement the plan exactly: happiness multipliers 40/75/100/150%, room multiplier `100 + 5 × comfortLevel`%, and chaos multipliers 100/115/125% at 0/30/70 thresholds.
- Tuyul's happiness-60 ability adds exactly 15% of base rent after the multiplied rate. The bonus is not multiplied by happiness, room comfort, or chaos.
- Elapsed seconds are converted with a persisted remainder modulo 60. Accrual computes `(oldRemainder + ratePerMinute × elapsedSeconds) ~/ 60` and carries the modulus, making arbitrary elapsed-time chunking exactly equivalent.
- `AdvanceSimulation(seconds)` is the typed application/domain entry point and rejects non-positive elapsed time as an identity-preserving no-op. The existing debug one-second control calls this same path; Flame frame callbacks never mutate rent.
- HK-011 accumulates claimable microcoins but does not transfer them to the wallet. Atomic collection/idempotency belongs to HK-012, and lifecycle/offline scheduling belongs to HK-013.
- Save schema advances to version 6 for pending rent microcoins and the sub-microcoin time remainder. Version-5 and older saves migrate both values to zero.

## HK-012 atomic rent collection decisions

Date: 2026-10-13

- `CollectAllRent(claimId)` pays only `pendingRentMicrocoins ~/ 1,000,000` into the wallet. The remaining sub-coin microcoins and HK-011's modulo-60 accrual remainder are preserved exactly.
- A successful payout updates wallet, pending rent, and the completed-claim set in one immutable transition. Empty claim IDs, previously completed IDs, and balances below one whole coin are identity-preserving no-ops.
- Claims below one coin are not recorded. This allows the caller to retry the same request after more rent accrues without losing the future payout.
- Completed claim IDs are persisted as immutable state. Replay remains a no-op after save/reload rather than relying on an in-memory UI guard.
- The application controller generates claim IDs from the injected clock, current revision, and a local sequence unless a stable ID is supplied by a test or retrying caller. Domain correctness does not depend on the generator.
- The Flutter Collect All control displays floored whole coins and is disabled at zero. It never displays or discards fractional microcoins.
- Save schema advances to version 7 for completed rent claim IDs. Version-6 and older saves migrate with an empty completed set.

## HK-013 offline earnings decisions

Date: 2026-10-13

- Backgrounding snapshots the current `RentSystem.totalRentPerMinuteMicrocoins` value, so room, happiness, chaos, and Tuyul's base-rent bonus are frozen for that absence. Later state changes cannot rewrite the earned rate retroactively.
- Offline elapsed time is calculated from integer epoch milliseconds and clamped to 0–240 minutes. Earnings use integer microcoins at 50%, preserving partial-minute precision without floating-point drift.
- Offline earnings are added to pending rent rather than directly to the wallet, preserving HK-012's explicit Collect All transaction.
- Resume atomically adds the capped earnings, clears the rate snapshot, and stores the observed resume timestamp. Clearing the snapshot makes repeated resume/load calls identity-preserving even when time advances again.
- A clock rollback clamps elapsed time to zero but still consumes the snapshot. This prevents a rolled-back timestamp from being retried later for income.
- Repeated background notifications do not replace an existing snapshot or timestamp. Flutter lifecycle handling snapshots on hidden/paused/detached and consumes on resumed; initialization also consumes a persisted snapshot for cold launches.
- Lifecycle pause/resume operations are serialized through the application controller so asynchronous persistence writes retain event order during rapid background/foreground transitions.
- No incidents, chaos changes, reputation changes, repairs, departures, or active-only abilities run through the offline path.
- Save schema advances to version 8 for the nullable offline rate snapshot and last-accrual timestamp. Version-7 and older saves migrate with no pending offline absence.

## HK-014 ghost ability decisions

Date: 2026-10-13

- Pocong and Kuntilanak use persisted per-instance 600-active-second cooldowns. At each completed interval, the current happiness threshold is checked; success grants 30 wallet coins or 1 reputation respectively, while failure grants nothing and begins the next interval.
- Periodic cooldowns advance only for ghosts assigned to rooms and only through `AdvanceSimulation`. Large elapsed updates can complete multiple intervals and produce the same result as one-second chunks.
- Reputation is introduced at the plan's initial value 60 and clamped to 100. Broader reputation event rules remain HK-016 scope.
- Tuyul's happiness-60 continuous 15% base-rent bonus remains in `RentSystem`; it has no artificial cooldown. Genderuwo's happiness-60 ability is exposed as a pure 75%-of-base repair-cost query for HK-020 to consume later.
- Offline resume does not call the ability system. It credits only snapshotted rent, leaving active seconds, periodic cooldowns, wallet rewards, and reputation unchanged.
- Save schema advances to version 9 for reputation and the immutable cooldown map. Version-8 and older saves migrate with reputation 60 and lazily initialized full periodic cooldowns.

## HK-015 balance and serialization regression decisions

Date: 2026-10-13

- The plan's worked happiness example is treated as a locked balance contract: quiet level 2 contributes +15, a suitable bed contributes +10, and Genderuwo contributes +10, producing Pocong happiness 85; adding Tuyul changes compatibility to -5 and total happiness to 70.
- `furnitureTagMatchHappiness` changes from the provisional +5 to +10 so the implemented balance matches that documented contract. Furniture contribution remains clamped to the existing [-10,+10] range, preventing stacked preferred tags from exceeding the plan cap.
- HK-015 centralizes cross-system examples in one regression file while retaining the narrower ticket-level tests. Covered contracts include happiness, 18.1125 rent, upgrade/unlock prices, offline earnings, and deterministic post-serialization behavior.
- Serialization regression uses JSON encode/decode rather than only an in-memory map. It populates every current v9 economy field and verifies that both rent advancement and collection produce identical subsequent state before and after restoration.
- No save schema change is needed because the corrected furniture value is a balance constant rather than persisted state.

## HK-016 chaos, reputation, and modifier-expiry decisions

Date: 2026-10-13

- Chaos updates whenever cumulative active simulation crosses a 600-second boundary using the plan formula: current chaos plus occupied ghost contributions minus 4, clamped to 0–100. Vacant/unassigned ghosts do not contribute.
- Reputation remains passive except for documented abilities or explicit event deltas. The shared event-delta rule clamps both chaos and reputation to 0–100; incident identity/replay protection remains HK-017/HK-019 scope.
- Temporary happiness modifiers expire by cumulative active simulation time, choosing the plan's simplest deterministic option. New complaint modifiers last 600 active seconds; pause/offline resume does not move the expiry timestamp.
- Expiry is stored as an absolute active-second timestamp per ghost. A null timestamp preserves legacy or deliberately non-expiring modifiers without treating wall-clock time as simulation time.
- Active advancement is segmented at the next chaos tick, periodic-ability trigger, or modifier expiry. Rent uses the pre-boundary state, then due modifiers expire, abilities evaluate, and chaos updates for subsequent time. This keeps large elapsed updates equivalent to one-second chunks across changing happiness and chaos bands.
- Save schema advances to version 10 for event modifier expiry timestamps. Version-9 and older saves migrate existing modifiers with no automatic expiry.
- The debug HUD now includes persisted reputation alongside coins, chaos, active time, and pending rent.

## HK-017 deterministic incident scheduler decisions

Date: 2026-10-13

- Unscripted eligibility is evaluated only at cumulative 60-active-second boundaries inside `AdvanceSimulation`. Incident time is therefore chunk independent and is never advanced by the offline earnings path.
- Chance uses integer basis points: `min(3500, 400 + 20 × chaos)` out of 10,000. This preserves the documented 12% chance at chaos 40 and 20% at chaos 80 without floating-point simulation state.
- The incident RNG is an injectable pure-Dart source whose 32-bit state is persisted. The production linear-congruential implementation and test sources consume that state explicitly, so save/reload and elapsed-time chunking continue the same sequence.
- A pending incident blocks all later checks without consuming RNG. Resolution requires the current incident ID plus a non-empty unique resolution ID, clears the pending incident atomically, records its active-second timestamp, and is an identity-preserving no-op when replayed.
- The three-minute post-resolution cooldown and the maximum of three unscripted incidents in a rolling ten-active-minute window use persisted active-second timestamps. A timestamp exactly ten minutes old has left the rolling window.
- A two-ID recent history is persisted. When more than one definition is eligible, the immediately previous incident is removed from selection to avoid back-to-back repetition; a sole eligible definition remains selectable.
- HK-017 includes only four metadata-only scheduler entries needed to exercise general, resident, happiness, and chaos gates. Localized dialogue, the complete ten-incident catalog, choices, effects, and Flutter presentation remain HK-018/HK-019.
- `unscriptedIncidentsEnabled` is persisted and defaults to true for the currently tutorial-free game and migrated saves. HK-021 will disable it during the opening tutorial and use scripted incidents that bypass this scheduler.
- At boundaries shared with a chaos tick, chaos updates first and the incident chance uses the resulting chaos value. This matches the rule that incident risk follows current chaos.
- Save schema advances to version 11 for pending incident identity, cooldown/cap/history timestamps, completed resolution IDs, the scheduler-enabled flag, and RNG state. Version-10 and older saves migrate to an empty scheduler with the canonical seed.

## HK-018 localized incident content decisions

Date: 2026-10-13

- The ten planned concepts are immutable pure-Dart content definitions. Each has stable incident/choice IDs, Indonesian and English title/dialogue/choice/response text, 2 choices, explicit preconditions, and a 180–300 active-second cooldown.
- HK-018 declares outcomes but does not apply them. HK-019 will consume the exact `IncidentEffects` values, validate affordability, apply happiness/coin/chaos/reputation atomically, and present previews/outcomes in Flutter.
- Happiness effects target every resident of the listed ghost kind when HK-019 applies them. Four-kind entries mean all resident ghost kinds, not ghosts that have not been unlocked or placed.
- Preconditions remain state-derived: Pocong requires happiness at most 39; Kuntilanak karaoke requires happiness at least 80; Genderuwo furniture damage requires durability level 0 in Genderuwo's room; Pak RT requires chaos 70; content creator/night market require level 2; ronda requires reputation 40; occupancy-gated events require at least one resident.
- The catalog validates unique IDs, complete bilingual text, 2–3 choices, and cooldowns of at least the global 180-second minimum. Scheduler cooldown uses the resolved incident's authored cooldown while retaining that global floor.
- Exact choice effects are locked by a snapshot-style unit test. In `coins / happiness / chaos / reputation` order they are:

| Incident / choice | Exact effects |
| --- | --- |
| Pocong / reinforce floor | `-40 / Pocong +15 / -2 / 0` |
| Pocong / set exercise hours | `0 / Pocong +8 / -4 / +1` |
| Tuyul / buy sandals | `-20 / Tuyul +12 / -2 / 0` |
| Tuyul / search rooms | `0 / Tuyul +5, Pocong -3 / +2 / 0` |
| Pak RT / community fund | `-60 / 0 / -10 / +6` |
| Pak RT / join patrol | `0 / 0 / -6 / +4` |
| Outage / emergency lights | `-25 / all +5 / -3 / 0` |
| Outage / wait | `0 / all -5 / +2 / 0` |
| Karaoke / soundproofing | `-50 / Kuntilanak +10 / -3 / +2` |
| Karaoke / encore | `0 / Kuntilanak +15 / +5 / -2` |
| Genderuwo / carpenter | `-80 / Genderuwo +10 / -2 / +2` |
| Genderuwo / help repair | `-20 / Genderuwo -5 / -1 / +1` |
| Ronda / coffee | `-30 / 0 / -4 / +6` |
| Ronda / hide ghosts | `0 / all -4 / -2 / +1` |
| Creator / filming | `+50 / all -3 / +4 / -2` |
| Creator / guided tour | `+30 / all +3 / +2 / +5` |
| Clothesline / replace | `-35 / 0 / -3 / +4` |
| Clothesline / follow pegs | `0 / Tuyul +5 / +2 / +2` |
| Night market / stall | `+40 / all +5 / +5 / +2` |
| Night market / quiet hours | `-10 / 0 / -4 / +3` |

- No save-schema change is required because the authored catalog is static content and the HK-017 save already persists stable incident IDs.
## HK-025 analytics decisions

Date: 2026-10-14

- Analytics is denied by default and persisted locally as explicit consent. Application hooks may emit only exact allowlisted gameplay schemas through an injected adapter; no provider SDK is installed, adapter failures cannot affect saves/gameplay, and the privacy/settings UX remains HK-028 scope.
