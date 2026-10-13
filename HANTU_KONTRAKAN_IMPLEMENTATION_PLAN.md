# Hantu Kontrakan — Game Design & Implementation Plan

**Version:** 1.0 (implementation handoff)  
**Date:** 2026-10-11  
**Status:** Proposed MVP specification; balance and art are provisional  
**Stack:** Flutter + Flame, Dart, Drift/SQLite, Riverpod (recommended)  
**Platforms:** Android first, iOS next  
**Orientation:** Portrait  
**Languages:** Indonesian (primary), English  

> **Codex instructions:** Read this document before writing code. Implement in milestone order, beginning with the vertical slice. Inspect the repository and `git status`/`git diff` first; preserve existing work, avoid unrelated refactoring, implement tests with each milestone, and do not mark tasks complete without running appropriate checks. This is a game specification, not a report of already implemented features.

## 1. Executive summary

**Tagline:** “Yang ngontrak bukan manusia, yang ribut malah tetangga.”

Hantu Kontrakan is a cute, comedic, Indonesian-folklore-inspired 2D side-view cutaway rental-property management game. Players inherit a spooky kontrakan, place ghost tenants into rooms, manage their happiness and relationships, respond to neighborhood complaints, earn rent, and expand the property.

**Design pillars:**
1. Ghosts have distinct personalities and directional neighbor compatibility.
2. Active decisions about room placement and events matter more than idle collection.
3. Indonesian culture and neighborhood humor inform mechanics, not just graphics.
4. Offline-first casual sessions (target 3–8 minutes) and fair optional monetization.

**MVP:** One two-floor building with four rooms (two unlocked initially), four ghosts, twelve furniture assets, 10 branching events, room upgrades, rent + capped offline earnings, reputation, chaos, player progression to level 10, tutorial, local saves, Indonesian/English text, one optional rewarded ad placement. Cosmetics/IAP are **post-MVP**, despite being part of the long-term business model.

## 2. Product boundaries and non-goals

- Solo developer-friendly: no multiplayer, PvP, social backend, cloud save, procedural world, complex pathfinding, or real-time network requirements in MVP.
- No compulsory ad at launch. Ads never block progression; no pay-to-win boosts.
- Players must not permanently lose ghosts, incur ongoing negative events, or lose property when offline.
- No real-world Indonesian rupiah in the in-game economy: use **Koin Arwah**. Real money appears only in platform billing UI later.
- Target frame rate 60 FPS where feasible; simulation correctness must not depend on rendering frame rate.
- Folklore characters are light-hearted reinterpretations; avoid mocking real religions, sacred practices, or living communities.

## 3. Player experience and gameplay loop

### 3.1 Main loop

1. Inspect rooms and active incidents.
2. Accept/assign ghost tenants to rooms (or rearrange them).
3. Improve comfort, silence, mystical affinity, and durability with upgrades/furniture.
4. React to complaints and choose tradeoffs (coins, happiness, chaos, reputation).
5. Collect accumulated rent and occasional ability rewards.
6. Unlock additional rooms, characters, progression levels, and missions.
7. Return later for capped offline earnings and new active-session events.

**Session goals:** A small reward or feedback every 30–90 seconds; meaningful decisions every 3–8 minutes; long-term unlocks spanning days.

### 3.2 First-session tutorial sequence

1. Narrative: player inherits an apparently abandoned kontrakan; Pocong is occupying a room rent-free.
2. Introduce Koin Arwah and prepare first room.
3. Place Pocong and collect first rent.
4. Introduce Kuntilanak/second room and basic room preferences.
5. Script a Pak RT or noisy-neighbor complaint.
6. Present 2–3 choices with clear consequences; apply exactly once.
7. Show a locked room and the next mission; let player continue without tutorial lockout.

**Target first-session journey:** roughly 10–12 minutes to understand room placement, rent, and one incident. Tutorial skip may be added after initial testing.

## 4. Building, rooms, and adjacency

### 4.1 Building layout

Portrait two-story 2×2 cutaway grid:

```text
             Floor 2
      +-------------+-------------+
      | Room 03     | Room 04     |
      | LOCKED      | LOCKED      |
      +-------------+-------------+
             Floor 1
      +-------------+-------------+
      | Room 01     | Room 02     |
      | Pocong      | Kuntilanak  |
      +-------------+-------------+
          Courtyard / street
```

- Room positions: R01=(0,0), R02=(1,0), R03=(0,1), R04=(1,1).
- **Adjacent** means Manhattan distance 1 (share a wall/floor/ceiling); diagonals do not count.
- One ghost per room, one primary furniture slot, one decoration slot.
- Player can tap a room to open its details, upgrade it, place furniture, or assign/move/swap tenants.
- Tenant moves/swaps are validated and atomic; no ghost can occupy two rooms.

### 4.2 Room attributes and upgrades

| Attribute | Gameplay impact | Levels |
|---|---|---|
| Comfort | +5% room rent per level; compatible room/furniture can also raise happiness | 0–2 |
| Silence | Mitigates noise and related complaints; can satisfy a quiet-room preference | 0–2 |
| Mystical affinity | Supports mystical room preferences and special events | 0–2 |
| Durability | Reduces frequency/cost of repairs; helps large ghosts | 0–2 |

Upgrade cost for an attribute at current level `L`: `100 * 2^L` (L=0 → 100 coins; L=1 → 200; at L=2 upgrade disabled).

Room unlocks: R01 free initially; R02 free via tutorial; R03 costs 400 and requires level 3; R04 costs 800 and requires level 5. Room unlock and level costs are **tuning constants**.

Furniture (MVP: 12 items) uses tags and optional modifiers (`quiet`, `plant`, `mystical`, `sturdy`, `shiny`, etc.). Explicitly cap room/furniture happiness modifiers as defined below. Cosmetics must not create an unintended pay advantage.

## 5. Ghost definitions and behavior

Four initial ghost species:

| Field | Pocong | Kuntilanak | Tuyul | Genderuwo |
|---|---|---|---|---|
| Character archetype | Restless jumper | Dramatic neighbor | Mischievous collector | Gentle giant |
| Base rent/min | 10 | 14 | 12 | 18 |
| Unlock level | 1 | 2 | 3 | 5 |
| Chaos contribution per active 10-min tick | +3 | +2 | +6 | -1 |
| Preferred room tags | `quiet` | `plant`, `decorated` | `mystical`, `shiny` | `sturdy` |
| Positive neighbor | Genderuwo | Pocong | Kuntilanak | Pocong |
| Disliked neighbor | Tuyul | Genderuwo | Pocong | Tuyul |
| Ability | Find 30 coins every 10 active minutes if happiness ≥80 | +1 reputation every 10 active minutes if happiness ≥80 | Additional 15% **base** rent while happiness ≥60 | 25% repair discount while happiness ≥60 |

**MVP animations per ghost:** idle, happy, upset/angry, special action (4–8 frames each where feasible). Visual idle loops can be simple placeholder animations in the vertical slice.

### 5.1 Directional compatibility matrix

**Row** = affected resident; **column** = neighboring ghost. Values are additive happiness points. Missing/nonadjacent ghosts contribute zero.

| Resident ↓ / Neighbor → | Pocong | Kuntilanak | Tuyul | Genderuwo |
|---|---:|---:|---:|---:|
| Pocong | — | +5 | -15 | +10 |
| Kuntilanak | +10 | — | +5 | -10 |
| Tuyul | -5 | +10 | — | -15 |
| Genderuwo | +10 | -5 | -10 | — |

Sum modifiers from adjacent occupied rooms, then clamp compatibility to **[-20,+15]**. Symmetry is not assumed.

### 5.2 Happiness

`H = clamp(50 + R + F + C + E, 0, 100)`

- `R`: room preference match/mismatch, clamp [-20,+20].
- `F`: furniture match/mismatch, clamp [-10,+10].
- `C`: directional neighboring ghost compatibility, clamp [-20,+15].
- `E`: temporary event modifier, clamp [-20,+20].
- Display happiness as rounded integer; calculation should be deterministic.
- Recompute target happiness after room, furniture, neighbor, or active-event changes.
- Animating HUD happiness between values is visual-only; state stores the calculated value.

**Example:** Pocong base 50 + quiet-room bonus 15 + suitable bed 10 + Genderuwo neighbor 10 = 85. If Tuyul also becomes adjacent, neighbor total is -5 and happiness becomes 70.

| Happiness | State | Rent multiplier |
|---|---|---:|
| 80–100 | Happy | 1.50 |
| 60–79 | Comfortable | 1.00 |
| 40–59 | Unhappy | 0.75 |
| 0–39 | Angry | 0.40 |

**Important implementation note:** Define concrete mapping of tags/upgrade levels to `R` and `F` in a balancing constants file. The ranges above are normative caps; precise per-item scores are provisional and must be selected before closing HK-008. Do not sprinkle magic constants through widgets.

## 6. Simulation and game economy

### 6.1 Rent formula

For each tenant `g`:

`rentPerMinute_g = baseRent_g * happinessMultiplier_g * roomMultiplier_g * chaosMultiplier + abilityRentBonus_g`

- `roomMultiplier = 1 + 0.05 * room.comfortLevel` (max 1.10).
- `chaosMultiplier = 1.00` for chaos 0–29, `1.15` for 30–69, `1.25` for 70–100.
- Tuyul adds `0.15 * baseRent` per minute if happiness≥60, **not multiplied** by other rent multipliers.
- All other abilities are periodic rewards/modifiers, not continuous extra rent.
- Accumulate rent with decimal/fixed-point precision (recommended integer microcoins); floor only when showing/claiming whole coins to avoid rounding drift. Persist fractional remainder.
- `Collect All` moves claimable whole coins into wallet in one atomic transaction; repeat requests must be idempotent.

**Example:** Pocong with happiness 85, Comfort 1, chaos 42: `10 × 1.5 × 1.05 × 1.15 = 18.1125 coins/min`.

### 6.2 Simulation clocks and offline rules

- Use a deterministic simulation based on elapsed time, not Flame frame rate.
- While foregrounded and playing, execute a 1-second fixed simulation step or equivalent accumulated-time update.
- On backgrounding, save state; while away, **do not** generate incidents, chaos increments, reputation losses, repairs, tenant departures, or periodic active-only ability rewards.
- Offline duration = `clamp(actualElapsedMinutes, 0, 240)`; negative time yields zero.
- Offline claimable earnings = `snapshotTotalRentPerMinute * offlineMinutes * 0.50`.
- Store a **rate snapshot** at pause/save; offline income uses this snapshot, including Tuyul's rent bonus. On resume, add offline earnings exactly once and update last accrual timestamp atomically.
- A player can return any time; the four-hour cap is a single elapsed absence cap, not repeated on each restore/load.
- Detect obvious clock rollbacks, but acknowledge fully offline client time cannot be cheat-proof. Avoid real-money competitive time mechanics.

### 6.3 Chaos and reputation

- Both are integer values in range 0–100, persisted.
- Initial suggested values: Chaos 40; Reputation 60; move these to constants.
- Every **ten minutes of cumulative active simulation**, update chaos:
  `chaos = clamp(chaos + sum(occupiedGhost.chaosPerTenMinutes) - 4, 0, 100)`.
- Event decisions may instantly alter chaos and reputation; apply once, with explicit bounds.
- Reputation gains/unlocks should never be based on passive ticking except documented ghost abilities. Never lower reputation while offline.
- Moderate chaos increases rent but incident risk; higher chaos produces more income but more trouble.

### 6.4 Incidents

- Tutorial incidents are scripted and bypass random checks.
- Following tutorial, check eligibility once per **60 active seconds**.
- Only one unresolved incident at a time.
- At least **3 active minutes after resolving** one incident before another may spawn.
- At most **3 unscripted incidents per rolling 10 active minutes** (track timestamps, not an unreliable session reset).
- Chance on an eligible check: `p = min(0.35, 0.04 + 0.002 * chaos)`; at chaos 40 → 12%; at 80 → 20%.
- Select only incidents whose required tenants/rooms/levels exist, using an injectable seeded RNG for tests. Prevent repetitive identical incidents with a short history window if needed.
- Choices display upfront deterministic changes (or accurately bounded/range previews when randomness is intentionally introduced).
- Once resolved, an event cannot be replayed or award benefits twice; persist pending event and resolution ID.

**Ten initial incident concepts:**
1. Pocong's Midnight Exercise (Pocong unhappy)
2. Tuyul's Missing Sandals (Tuyul resident)
3. Pak RT Complaint (high chaos)
4. Electricity Outage (general)
5. Kuntilanak Karaoke (Kuntilanak happy)
6. Genderuwo Breaks Furniture (low durability)
7. Neighborhood Security Patrol / Ronda Malam
8. Paranormal Content Creator Visits
9. Mysterious Stolen Clothesline
10. Night Market Next Door

Author each incident in data with ID, title/dialogue `id`/`en`, preconditions, 2–3 choices, exact coin/happiness/chaos/reputation effects, cooldown, and post-choice response text.

### 6.5 Player progression, missions, rewards

- Ten introductory levels. Define XP rewards and thresholds in data, not hardcoded UI logic.
- Level 2: Kuntilanak; 3: Tuyul + room 3 eligibility; 5: Genderuwo + room 4 eligibility.
- Missions: 10 tutorial/early game goals (place tenant, collect rent, upgrade comfort, resolve incident, improve happiness, unlock room, etc.).
- Completing missions grants coins or small amounts of **Kristal Mistis** (premium cosmetic currency, earnable through normal play).
- Reputation unlocks options and dialogues but is **not spendable**.
- Do not make key mechanics dependent on Kristal Mistis during MVP.

### 6.6 Design economy validation

At each tuning pass, compute:
- Time to unlock rooms 3 and 4 with expected early-game play patterns.
- Coin sources (rent/abilities/missions) vs sinks (upgrades/repairs/unlocks).
- Whether leaving game idle is more lucrative than playing actively.
- Whether high-chaos strategy dominates without meaningful downside.
- Whether the best room assignment is always obvious and permanent.

**Balance goals:** New players can reach several meaningful actions in their first 10–12 minutes; the first upgrade should not require long idle waiting. Test, don't assume.

## 7. UI and UX wireframes

### 7.1 Main game (portrait)

```text
+--------------------------------------+
| HANTU KONTRAKAN        [Pause] [Gear] |
| Coins: 1250  Chaos: 42  Rep: 75      |
+------------------+-------------------+
| Room 03 LOCKED   | Room 04 LOCKED    |
| Unlock 400       | Unlock 800        |
+------------------+-------------------+
| Room 01          | Room 02           |
| [Pocong anim.]   | [Kunti anim.]     |
| Happiness 85     | Happiness 65      |
| +18.1/min        | +14/min           |
+------------------+-------------------+
| Courtyard + night sky / neighborhood |
+--------------------------------------+
| Collect All: 290 coins    [COLLECT]  |
+--------------------------------------+
| [Rooms] [Ghosts] [Events] [Shop]     |
+--------------------------------------+
```

- Main game world: Flame side-view, rendered behind Flutter HUD.
- Room tap: room details bottom sheet.
- Ghost tap: ghost profile bottom sheet.
- Complaint bubble: open pending event screen/modal.
- Avoid tiny targets; target accessible tap regions and readable portrait sizing.

### 7.2 Room details bottom sheet

```text
KAMAR 01                         [X]
Tenant: Pocong      Happiness: 85
[Live room preview / furniture slots]
Comfort       ●●○
Silence       ●○○
Mystical      ○○○
Durability    ●○○
[Upgrade] [Furniture]
[Move / Swap Tenant]
```

### 7.3 Ghost profile sheet

```text
[Pocong illustration]  POCONG
“The Restless Jumper” | Happy 85
Base rent: 10 / min
Likes: quiet rooms | Dislikes: Tuyul
Ability: Lost Coins every 10 active min
[Move to another room]
```

### 7.4 Incident modal

```text
INCIDENT: SANDAL SIAPA YANG HILANG?
[Illustration]
Pak RT says sandals are disappearing...
[Replace sandals: -100 coins, +trust]
[Ask Tuyul to return them: -10 happiness]
[Blame the cat: -8 reputation]
[Show outcome after choice]
```

### 7.5 Other screens

- Start/pause/settings with audio, language, credits, privacy and consent settings.
- Ghost roster/unlock progress.
- Mission list and notifications.
- Shop entry initially shows only earnable furniture/cosmetics; digital IAP feature-gated until post-MVP.
- Offline earnings summary once per return, with optional later ad offer.

## 8. Art and audio production plan

**Art direction:** friendly pixel art with spooky atmospheric lighting, saturated night blues/purples, warm window lanterns, expressive chibi ghosts. References are conceptual; produce original assets before shipping.

MVP asset checklist:
- One 2-story cutaway building; walls/floors/roof; street/courtyard/night skyline; locked-room overlays.
- 4 room backgrounds + room/furniture slot sprites.
- 4 ghosts × idle/happy/angry/ability animations (about 4–8 frames each; placeholder animations acceptable for vertical slice).
- 12 furniture items including bed, plant, lantern, reinforced shelf, curtain, rug, wall charm, shiny trinket, fan, dresser, door, lamp.
- HUD icons: coins, chaos, reputation, happiness; incident thought bubble; collection particles; upgrade/repair effects.
- 1 looping background music track, 1 short incident sting, ~10 SFX (coin, upgrade, ghost reaction, complaint, unlock, repair, ability, tap, etc.).

**Asset conventions:** snake_case names; explicit sprite sheet dimensions and frame rates; license/origin documentation; import into `assets/images/...` and `assets/audio/...`.

## 9. Recommended technical architecture

### 9.1 Layer responsibilities

- **Flutter presentation:** HUD, dialogs, bottom sheets, inventory, settings, localization, app routing.
- **Flame rendering:** `GameWidget`, `HantuGame`, `World`, camera, building/room components, ghost animation, hit-testing, effects.
- **Pure Dart domain simulation:** state and rules for rent, happiness, compatibility, chaos, incidents, upgrades, progression. No Flutter or Flame imports in this layer.
- **Controller/application services:** validate/dispatch commands; emit state; coordinate saves, foreground lifecycle, ad reward requests.
- **Persistence:** Drift/SQLite local saves, migrations, transactional claims. Simpler local persistence can be used for vertical slice if consistent with the planned migration.
- **Platform services:** `google_mobile_ads` for optional rewarded ads, app-store billing for later cosmetics, analytics/crash reporting optionally and with appropriate consent.

**Recommendation:** Riverpod for dependency injection/state management; fixed-step Dart simulation at 1 Hz; Flame rendering independent of simulation.

### 9.2 Suggested repository structure

```text
lib/
  main.dart
  app/{app.dart,routing/,theme/,localization/}
  game/
    hantu_game.dart
    world/{kontrakan_world.dart,building_component.dart}
    components/{room_component.dart,ghost_component.dart,furniture_component.dart}
    effects/
  simulation/
    models/{ghost_definition.dart,ghost_instance.dart,room_state.dart,game_state.dart}
    systems/{happiness_system.dart,compatibility_system.dart,economy_system.dart,
             chaos_system.dart,incident_system.dart,progression_system.dart}
    content/{ghosts.json,incidents.json,furniture.json,progression.json}
    constants/game_balance.dart
  application/{game_controller.dart,commands/,game_clock.dart}
  features/{rooms/,ghosts/,events/,missions/,shop/,settings/}
  services/{save_service.dart,ads_service.dart,purchase_service.dart,analytics_service.dart}
  shared/widgets/
assets/{images/,audio/,data/}
test/{simulation/,application/,widgets/}
integration_test/
```

### 9.3 Data contracts

```dart
class GhostDefinition {
  final String id;
  final String nameKey;
  final int baseRentPerMinute;
  final int unlockLevel;
  final int chaosPerTenMinutes;
  final String abilityId;
  final List<String> preferredRoomTags;
  final Map<String, int> neighborModifiers;
}

class GhostInstance {
  final String instanceId;
  final String definitionId;
  final String? roomId;
  final int happiness;
  final int loyalty;
}

class RoomState {
  final String id;
  final bool unlocked;
  final String? occupantId;
  final Map<String, int> upgrades;
  final List<String> furnitureIds;
}

class GameState {
  final int schemaVersion;
  final int walletCoins;
  final int pendingRentMicrocoins;
  final int mysticalCrystals;
  final int reputation;
  final int chaos;
  final int playerLevel;
  final int xp;
  final List<GhostInstance> ghosts;
  final List<RoomState> rooms;
  final DateTime lastAccrualAt;
  // Include active incident, incident history, cooldowns, tutorial, and ability timers.
}
```

Implement immutable, serializable types with explicit migrations. Treat example Dart above as a contract sketch, not copy-paste compile-ready code.

### 9.4 Commands

- `PlaceGhost(ghostId, roomId)`
- `MoveGhost(ghostId, roomId)` (atomic swap when explicitly confirmed)
- `UnlockRoom(roomId)`
- `UpgradeRoom(roomId, attribute)`
- `EquipFurniture(roomId, furnitureId, slot)`
- `CollectAllRent(claimId)`
- `ResolveIncident(incidentId, choiceId, resolutionId)`
- `ClaimMissionReward(missionId)`
- `ApplyRewardedAdBonus(claimId, rewardEvidence)` (later)

Commands must validate state and be idempotent when replay could create duplicated income/rewards.

### 9.5 Seed data example

```json
{
  "id": "ghost_pocong",
  "name": {"id": "Pocong", "en": "Pocong"},
  "baseRentPerMinute": 10,
  "unlockLevel": 1,
  "chaosPerTenMinutes": 3,
  "preferredRoomTags": ["quiet"],
  "neighborModifiers": {
    "ghost_kuntilanak": 5,
    "ghost_tuyul": -15,
    "ghost_genderuwo": 10
  },
  "ability": {
    "type": "bonus_coins",
    "intervalSeconds": 600,
    "minimumHappiness": 80,
    "amount": 30,
    "activeOnly": true
  },
  "sprites": {
    "idle": "ghosts/pocong/idle.png",
    "happy": "ghosts/pocong/happy.png",
    "angry": "ghosts/pocong/angry.png"
  }
}
```

## 10. Monetization plan

### 10.1 MVP: one opt-in rewarded-ad placement

**Offer:** Watch a rewarded ad to double one pending Collect All payout (maximum 3 successful bonuses per local calendar day).

Safety/fairness rules:
1. Before loading the ad, snapshot claimable whole coins and create a unique `claimId`.
2. Base claim is always available without an ad; ads never gate collecting.
3. On ad successful earned-reward callback, grant the additional snapshotted amount *once*.
4. If ad unavailable/cancelled, give base claim normally and don't grant ad bonus.
5. Persist claim/reward state transactionally to guard against duplicate callbacks/restarts.
6. Test with ad test units only; respect privacy/consent and platform policies.

**Clarification:** The UI must not first grant the full base and then re-claim the same pending amount. Model the bonus and base award as one claim transaction with a separately idempotent optional bonus.

### 10.2 Post-MVP: cosmetics/IAP

Possible test prices (not validated market data): Retro Kontrakan Rp15k, Malam Jumat Rp19k, Rumah Sultan Rp29k, Ghost Fashion Rp25k. Store cosmetics should not change happiness/income balance. Future expansion packs might contain new locales and side stories, without removing core playability.

### 10.3 Analytics events

`app_open`, `tutorial_started`, `tutorial_completed`, `ghost_placed`, `room_upgraded`, `room_unlocked`, `rent_collected`, `incident_started`, `incident_choice_selected`, `incident_resolved`, `offline_earnings_claimed`, `ad_offer_shown`, `ad_started`, `ad_reward_earned`, `ad_failed`, and later `purchase_started`/`purchase_completed`.

Target validation metrics (hypotheses, not factual benchmarks): tutorial completion >75%, D1 retention ≥30%, D7 ≥10%, typical session 5–8 minutes, ≥20% of eligible players opt into rewarded ads, crash-free sessions >99%.

## 11. MVP milestone backlog (30 tickets)

Complete each ticket with tests and explicit acceptance criteria. Use these stable IDs in issues and commits.

### Milestone M1 — Foundation & building prototype

- [x] **HK-001** Initialize Flutter/Flame app, portrait lock, routing, theme, localization scaffolding. **Accept:** boots on Android; no landscape reflow.
- [x] **HK-002** Create `HantuGame`, camera/world, 2×2 cutaway building, tappable room components. **Accept:** tap each room opens selected room ID.
- [x] **HK-003** Pure Dart immutable game state, commands, controller, balance constants. **Accept:** tests construct and update state without Flutter/Flame.
- [x] **HK-004** Save/load with schema versioning and safe fallback for corrupt saves. **Accept:** changes survive termination/relaunch; unsupported versions handled deliberately.
- [x] **HK-005** Debug HUD and deterministic test clock/seed. **Accept:** dev can inspect coins, chaos, happiness, tick and reset state.

### Milestone M2 — Ghosts and room management

- [x] **HK-006** Four ghost definitions and idle/happy/angry/special animations (placeholders acceptable). **Accept:** state drives displayed animation.
- [x] **HK-007** Tenant placement, moves, swaps and vacancy validation. **Accept:** occupancy is always one-to-one; invalid swaps are no-ops.
- [x] **HK-008** Happiness, room preferences, directional neighbor compatibility. **Accept:** Pocong + Tuyul adjacent gives Pocong -15 compatibility before clamps.
- [x] **HK-009** Room and ghost detail sheets with state-driven content. **Accept:** correct profile, room, happiness, and available actions.
- [x] **HK-010** Upgrade attributes, room unlock gates/costs, furniture slots. **Accept:** no negative wallet; max upgrade and locked actions disabled.

### Milestone M3 — Economy & offline earnings

- [x] **HK-011** Precise, deterministic rent accrual. **Accept:** output independent of FPS and elapsed-time chunk sizes.
- [ ] **HK-012** Collect All with atomic/idempotent payout. **Accept:** duplicated claim never grants twice.
- [ ] **HK-013** Offline snapshot and 4-hour/50% cap. **Accept:** repeated resume does not double-credit, negative timestamps yield zero.
- [ ] **HK-014** Four unique ghost abilities with persisted cooldowns. **Accept:** active-only abilities do not trigger offline.
- [ ] **HK-015** Balance and serialization regression tests. **Accept:** documented worked examples pass.

### Milestone M4 — Chaos, incidents & comedy

- [ ] **HK-016** Chaos and reputation systems and event modifier expiries. **Accept:** clamped 0–100, active-only chaos tick.
- [ ] **HK-017** Seeded incident scheduler, gating, cooldowns, rolling cap. **Accept:** no overlapping incidents, deterministic test sequences.
- [ ] **HK-018** Author 10 localized incidents and valid branching outcomes. **Accept:** every option has deterministic documented effects.
- [ ] **HK-019** Incident UI, consequence preview and resolved screen. **Accept:** choice commits once, duplicate taps ignored.
- [ ] **HK-020** Repair/durability costs and persistence. **Accept:** repairs apply right discounts and don't repeat.

### Milestone M5 — Tutorial & progression

- [ ] **HK-021** Opening story, tutorial steps, scripted incident. **Accept:** new player can place ghost, collect rent, resolve event.
- [ ] **HK-022** Levels 1–10 and unlock definitions. **Accept:** level gates deterministic and reload-safe.
- [ ] **HK-023** Ten beginner missions and one-time reward claims. **Accept:** no duplicate reward.
- [ ] **HK-024** Localize all content into Indonesian and English. **Accept:** language toggle updates UI/dialogue with no missing keys.
- [ ] **HK-025** Gameplay analytics hooks, optional/consent-aware. **Accept:** events identified and no sensitive personal data in payloads.

### Milestone M6 — Polish, ads, beta

- [ ] **HK-026** SFX/music with mute and volume settings. **Accept:** background/resume audio works and settings persist.
- [ ] **HK-027** Rewarded ad integration behind platform adapter, test units, safe claims. **Accept:** ad callbacks grant bonus exactly once and failure never blocks collecting.
- [ ] **HK-028** Consent/privacy settings, error logging, crash-reporting integration when configured. **Accept:** offline game playable if external services fail.
- [ ] **HK-029** Unit/widget/integration/lifecycle/device regression testing and performance pass. **Accept:** agreed target devices responsive; no high-severity known save/economy issues.
- [ ] **HK-030** App icon, screenshots, localization, privacy policy, Android closed test build. **Accept:** store material and functioning closed beta package prepared.

### Milestone ordering/dependencies

`M1 foundation → M2 tenant logic → M3 economy + M4 incidents (may overlap) → M5 tutorial → M6 polish/ads/beta`.

**Estimated solo part-time planning:** M1 1–2 weeks, M2 2 weeks, M3 1–2 weeks, M4 2 weeks, M5 1–2 weeks, M6 2–3 weeks. Rough total: **9–13 weeks**, highly dependent on art, time availability, and test scope.

## 12. First playable vertical slice (P0)

**Purpose:** Validate the core fun before creating the full economy or investing heavily in art.

- [x] **P0-01** Initialize working portrait Flutter + Flame screen; use placeholder cutaway visuals.
- [x] **P0-02** Render two horizontally adjacent rooms and tappable room/ghost components.
- [x] **P0-03** Instantiate Pocong and Tuyul with seeded states.
- [x] **P0-04** Pure Dart happiness + directional compatibility calculation.
- [x] **P0-05** Show happiness/room details; allow moving/switching tenants where valid.
- [x] **P0-06** Script one complaint: Pocong is annoyed by Tuyul.
- [x] **P0-07** Present 2–3 choices; visibly update coins and/or happiness after resolution.
- [x] **P0-08** Save/reload slice state and write deterministic unit tests.

**P0 acceptance demonstration:** Open app → inspect two occupied rooms → observe Pocong's compatibility penalty → open and resolve complaint → see numeric state and animation update → restart and confirm persisted outcome. No ads, shop, network service, or final artwork needed.

## 13. Testing plan

### 13.1 Unit tests

- Compatibility is directional; only Manhattan-adjacent ghosts contribute; values clamp correctly.
- Happiness totals/thresholds correct; room and furniture modifiers capped.
- Rent formula correct for all four bands, chaos bands, Comfort levels, and Tuyul bonus.
- Deterministic rate accrual yields same result when simulated as 120×1 sec versus 1×120 sec.
- Unlock/upgrade costs and wallet bounds validated.
- 10-minute chaos ticks and integer clamps correct; no offline chaos accrual.
- Incident choice applies effects only once, conditions checked, scheduler cooldown enforced.

### 13.2 Persistence and lifecycle tests

- Cold launch, save, kill app, reload returns same room/ghost/wallet state.
- Offline 2 hours at 40 coins/min yields 2,400 coins at 50%; 5 hours earns only 4-hour cap = 4,800.
- Resume twice without time advance earns nothing on second resume.
- Clock rollback yields zero additional offline income.
- Older save migrations and corrupted saves handled without crash or silent destructive reset.
- Interrupt app during purchase/event/collect; no half-applied transaction.

### 13.3 UI/integration tests

- Tutorial works without network.
- Room selection and moving ghosts correctly update UI.
- Every incident option accessible and shows outcome.
- Indonesian and English content fits portrait screen.
- Rewarded ads: load failure/cancel/success/duplicate earned callback.
- Android physical devices: performance, resume/lock screen, sound interruptions, storage constraints.

## 14. Release and iteration

**Closed beta release gate:** tutorial playable; deterministic economy, no save corruption, no duplicate claims, event text localized, sensible performance on target Android phones, privacy/store requirements covered, no known severe gameplay blockers.

**Post-launch possibilities:**
- Version 1.1: Tenant stories, two additional ghosts, friendship/rivalry arcs.
- Version 1.2: Second building section, special room furniture, new decorating strategies.
- Version 1.3: Haunted Nusantara locations and regional supernatural folklore stories.
- Version 1.4: Optional asynchronous leaderboards/sharing only if player demand warrants backend costs.

## 15. Technical and design decisions to resolve during implementation

These are intentionally **not** invented as fixed final rules. Record decisions in `docs/decisions.md`:

1. Exact `R` and `F` happiness mapping for each room tag, upgrade, and furniture object (respect documented caps).
2. Exact cost and effects for 12 furniture items and 10 incident choice outcomes.
3. Experience thresholds and mission rewards for levels 1–10.
4. Save/persistence migration approach and whether using Drift from P0 is worth initial setup.
5. Long-session pacing and how often a ghost can initiate identical events.
6. Precise monetization callback state machine and app-store-compliant consent UX.
7. Actual target device baseline and graphics performance limits.
8. UI proportions, localization lengths, accessibility and reduced motion.
9. Whether event happiness modifiers expire by active time or explicit resolution (choose one consistently).

Default to the simplest deterministic/testable choice and document it. Never quietly change specified rent/compatibility formulas while implementing.

## 16. Codex continuation workflow

**For a new repository:**
1. Initialize Flutter project and Flame dependency; confirm Android build.
2. Create folders reflecting the architecture, balancing constants, seed data, and core domain models.
3. Implement P0 in small commits; add test coverage before moving to M1–M6.
4. At the end of each task, run `flutter analyze` and appropriate `flutter test` commands (or report environment limitations).
5. Update checkboxes in this Markdown only after verifying the relevant acceptance criteria.
6. Log decisions, known issues, and next tasks in `docs/implementation_progress.md`.

**For an existing repository:** First run `git status`, `git diff`, inspect `pubspec.yaml` and existing app architecture. Integrate with the established structure where appropriate; do not overwrite uncommitted work or regenerate completed assets. Pause a failing task in a coherent, documented state instead of declaring it done.

### Copy/paste first prompt for Codex

```text
Read HANTU_KONTRAKAN_IMPLEMENTATION_PLAN.md in full and treat it as the source of truth.
First inspect the current repository: git status, git diff, Flutter/Flame dependencies, and existing architecture. Preserve existing modifications and avoid unrelated refactors.
Implement ONLY the P0 vertical slice (P0-01 through P0-08), with Flutter + Flame for the cutaway world, pure Dart for deterministic game rules, and Flutter for panels/dialogs.
Use placeholder artwork, implement save/reload and unit tests, and do not add ads, IAP, cloud services, or the full four-room economy yet.
Run formatting, flutter analyze, and relevant tests. Report which P0 items passed with evidence, what remains, and what files changed. Document assumptions in docs/decisions.md and progress in docs/implementation_progress.md.
Do not continue into M1/M2 until the P0 acceptance demo works.
```

### Subsequent Codex prompt template

```text
Continue from current repository state. Inspect git status and git diff first; do not redo completed work.
Read HANTU_KONTRAKAN_IMPLEMENTATION_PLAN.md and docs/implementation_progress.md.
Implement only the next unfinished milestone/ticket, following its acceptance criteria. Keep simulation independent from Flame rendering, add tests, and update implementation progress when verified.
Finish by running flutter analyze and relevant flutter tests. Summarize changed files, test results, decisions and remaining work.
```

---

**Success criterion:** The game is worth expanding when players find the ghost relationship/incident decisions entertaining *without needing rewarded ads, excessive waiting, or elaborate animations*. Validate that with P0 before scaling production.
