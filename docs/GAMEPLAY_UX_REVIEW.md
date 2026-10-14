# Hantu Kontrakan Gameplay and UX Review

Date: 14 October 2026  
Status: product-direction proposal; implementation not yet started

## Executive assessment

The current build proves the deterministic simulation, save safety, localization,
ads boundary, and basic four-room interaction. It does not yet present or pace
those systems like a commercially competitive mobile tycoon game.

The main-screen problem is not primarily asset quality. The application shell is
visually stronger than the game world: a standard app bar, raw text counters,
large empty bands, and stacked administrative buttons surround a small fixed
game viewport. Rent, incidents, complaints, missions, and upgrades therefore
feel like forms outside the kontrakan instead of activities happening inside it.

The five-minute boredom is also structural. The game currently has ten linear,
one-time missions; four rooms; free instant furniture changes; one global rent
balance; sparse incidents; and no recurring goal board, collection discovery,
daily progression, meaningful crystal sink, or long-term expansion. A UI reskin
alone cannot solve this.

Recommendation: do not ship HK-030 to a monetized closed beta yet. Insert a
focused retention and presentation milestone before closed-track packaging.

## Evidence from the current build

### Main-screen hierarchy

- The kontrakan occupies only the middle portion of the portrait screen.
- The app title consumes premium space on every visit even though it is not an
  action or status.
- Settings, language, and missions have unrelated icon treatments.
- Coins, crystals, and one ghost's happiness are unframed strings rather than a
  coherent status HUD.
- Locked-room labels and happiness text are painted over environment art,
  weakening atmosphere and readability.
- Rent, rewarded rent, incidents, and complaints are full-width buttons below
  the world. They compete equally even though their urgency differs.
- Black/empty bands visually separate the game from its controls.

### Panels and dialogs

- Missions use a generic `AlertDialog` and expose all ten goals at once.
- Room details are a long text-and-row bottom sheet. Upgrade levels, furniture,
  happiness causes, tenant identity, and repair state have almost equal weight.
- Actions use stock Material buttons and icons, so the panels look like an
  internal management tool rather than part of the game's fiction.
- Outcomes rely heavily on text and snackbars instead of visible world changes,
  anticipation, animation, particles, and sound.

### Five-minute action economy

- The mission catalog is a single prerequisite chain. It teaches mechanics but
  does not create repeat sessions after the ten claims are complete.
- Mission XP is the primary progression path; after the authored chain, level
  motivation and guidance collapse.
- Furniture can be swapped immediately and has no acquisition, cost, rarity,
  crafting, or collection loop.
- Crystals are awarded but do not currently support a meaningful player choice.
- Rent is accumulated globally and claimed globally, so rooms do not create
  distinct collection moments or visual anticipation.
- Incidents are useful authored choices but are probabilistic and too sparse to
  support a 10–30 minute session by themselves.
- Ghost abilities mostly resolve passively on ten-minute intervals, with limited
  player setup or presentation.

### Audio

- The only music loop is approximately 19.2 seconds and plays as one static
  layer. Even with a clean loop, its repetition becomes obvious during the
  intended 10–30 minute session.
- Six short effects cover core commands but there is no ambient kontrakan layer,
  ghost vocal set, room interaction family, UI interaction family, success
  flourish, low-coin/error feedback, or incident-specific comedy sting.
- Music does not respond to night ambience, chaos, an active incident, a reward,
  or a newly unlocked floor.

## Target experience

The player fantasy is: **manage a lively supernatural kontrakan, understand its
odd tenants, improve the property, and turn neighborhood chaos into a thriving
business.** Every primary action should visibly affect the building or a ghost.

Design pillars:

1. **The kontrakan is the interface.** The world is full screen; rent, needs,
   repairs, upgrades, and incidents appear at their source.
2. **There is always one useful next action.** A player should never leave a
   panel wondering what to do or wait without a short goal.
3. **Progress is visible.** Furniture, lighting, room quality, tenant behavior,
   and the exterior improve on screen—not only as numbers.
4. **Horror is charming, not generic.** Indonesian night ambience and folklore
   personality provide identity; comedy reactions release the tension.
5. **Monetization accelerates delight.** Spending may save time, extend
   customization, or unlock optional collections, but it must not repair boring
   core play or block rent collection.

## Proposed full-screen gameplay UX

The direction concept is stored at
`docs/gameplay_ux_redesign_concept.png`. It is a composition target, not a
production screenshot or a source of final controls.

### Persistent screen

- Remove the standard app bar and repeated game title.
- Render an aspect-aware, edge-to-edge kontrakan world behind all HUD elements.
- Use a compact top HUD: player level/XP, coins, crystals, and settings.
- Show coin bubbles above rooms when meaningful rent is ready. Tapping a bubble
  collects that room; a compact floating button collects all available rooms.
- Show repairs, tenant requests, and incidents as anchored world markers with
  urgency-specific color and motion.
- Keep rewarded collection out of the default main-screen hierarchy. Offer it
  after a normal collection as a small, optional reward moment.
- Use a themed bottom navigation bar with four destinations: Kontrakan,
  Missions, Ghosts, and Shop. Badges communicate action, never decoration.
- Show one compact chapter-goal card above navigation; it collapses after the
  player understands the objective.

### Panels

- Use a shared illustrated panel system: dark wood frame, warm paper surface,
  rounded inner content, strong title art, close affordance, and one highlighted
  primary action.
- Room panel: room preview, income/minute, occupant happiness, three illustrated
  upgrade tracks, furniture slots, and the single best recommended improvement.
- Ghost panel: expressive portrait, mood, likes/dislikes, current need, ability
  timer, relationship, and room-fit comparison.
- Mission panel: three active goals, visible progress, reward chest, and the next
  chapter beat. Completed history is secondary.
- Incident panel: character portrait and speech bubble first, two visually
  distinct decisions second, exact costs/effects previewed before confirmation.

### Feedback and accessibility

- Coin arcs fly from the room to the HUD; the balance counts up rather than
  jumping silently.
- Upgrades visibly alter room props or lighting and trigger tenant reactions.
- Use scale, glow, particles, and sound as a coordinated feedback bundle.
- Maintain 48 logical-pixel touch targets, sufficient contrast, reduced-motion
  support, color-independent status indicators, and localized dynamic type.

## Repeatable gameplay design

### Cadence model

| Horizon | Player activity | Target payoff |
| --- | --- | --- |
| 10–30 seconds | Tap ready rooms, answer a tenant need, inspect a marker | Immediate animation, coins, personality |
| 2–5 minutes | Complete a goal, buy an upgrade, furnish a room | Visible property improvement |
| 10–20 minutes | Finish a chapter chain, resolve incidents, optimize tenants | Unlock, story beat, collection reward |
| 2–8 hours | Return for accumulated rent and refreshed requests | Meaningful return without punishment |
| Daily | Three rotating tasks and one bonus chest | Predictable habit and crystal value |
| Weekly | Themed neighborhood story/event | New cosmetic, ghost memory, or building feature |

The game should support a satisfying short check-in while still offering 10–30
minutes of meaningful play when the player chooses to stay. It should not create
fake work solely to inflate session length.

### Mission architecture

Replace the one-list presentation with three layers:

1. **Chapter goals:** authored onboarding and narrative progression. Keep the
   existing ten missions as Chapter 1, but present only the current goal and the
   next preview.
2. **Daily contracts:** three deterministic, reroll-limited goals chosen from
   actions the player has unlocked, such as collect from rooms, raise happiness,
   resolve a request, spend coins on property, or use a compatible furnishing.
3. **Tenant requests:** short character-specific tasks anchored to the tenant,
   with comic dialogue and a visible room outcome.

Mission rules must avoid impossible goals, ad requirements, and goals that ask
players to undo good layouts. Progress and refresh state must be saved.

### Rent collection

- Track claimable rent per room while retaining deterministic fixed-point math.
- Each occupied room displays a coin bubble only after a readable threshold.
- Tapping a room bubble collects it instantly; the collect-all button becomes
  prominent when multiple rooms are ready.
- Normal collection always completes first. Afterwards, an optional rewarded
  offer may boost the just-collected amount, preserving the existing safe claim
  semantics.
- Offline return uses one concise summary with room contributions, then sends
  coins into the HUD. Avoid a blocking sequence of dialogs.

### Sinks and decisions

- Give furniture acquisition a coin cost and a visible catalog progression.
- Add room visual tiers so each upgrade changes art, rent, and tenant response.
- Reserve crystals for clearly valuable optional choices such as premium
  cosmetics, a limited daily-contract reroll, or convenience—not basic play.
- Add a small ghost scrapbook/collection with unlocked reactions and stories.
- Do not add IAP until the free economy produces satisfying decisions and
  retention tests show players voluntarily return.

### Content requirement

Four rooms and four ghosts are enough for a vertical slice, not a durable
commercial progression game. Before broad monetization, plan at least:

- three visually distinct property stages or locations;
- more tenant identities and tenant-specific requests;
- visible room upgrade tiers and furniture ownership;
- recurring goal templates with authored localization;
- chapter incidents and collection rewards beyond the current tutorial chain.

This can be delivered incrementally; it should not be disguised as UI polish.

## Property portfolio: what happens after four occupied rooms

The four-room kontrakan is the first chapter and the onboarding property. Full
occupancy must unlock a new management phase rather than represent completion.

An occupied property continues to offer optimization through visible room tiers,
tenant compatibility, requests, repairs, furniture sets, relationship stories,
income targets, and incidents. Players may keep, move, or replace tenants as new
applicants become available; occupancy is a strategic configuration, not a
permanent checkbox.

Long-term progression uses a property portfolio:

1. **Kontrakan Melati:** four rooms; onboarding and basic tenant management.
2. **Kontrakan Gang Buntu:** a larger property introducing neighborhood and
   security pressure.
3. **Kost Bekas Rumah Sakit:** maintenance, stronger incidents, and specialized
   rooms.
4. **Villa Pantai Selatan:** premium supernatural tenants, environmental events,
   and higher-risk rewards.

Names after the first property are working concepts, not locked production copy.
Each new location needs a distinct visual identity and at least one new decision
system. Earlier properties continue earning, receiving occasional requests, and
supporting portfolio goals; players can revisit them at any time.

The expansion loop is:

`fill rooms → improve tenants and rooms → complete property chapter → unlock a
new property → manage the portfolio → pursue collections, stories, and rotating
goals`.

Avoid a destructive prestige reset. Renovation or property-star systems may add
new visual tiers and bonuses, but owned content and paid value must remain
durable. At least one second playable property/progression stage is required
before a monetized beta can demonstrate this promise honestly.

## Audio direction

Replace the single flat loop with an audio system that can remain pleasant for
20 minutes:

- one 60–120 second main night theme using light gamelan/percussion colors,
  plucked strings, warm bass, and playful supernatural motifs;
- a subtle environment loop: insects, distant neighborhood life, wind, wood,
  pipes, and occasional roof or gate details;
- an optional tension stem introduced only during incidents/high chaos;
- short comedy resolution stings and unlock/upgrade flourishes;
- 3–5 tiny vocal/reaction cues per ghost, used sparingly;
- coherent UI taps, purchase, unavailable, mission complete, and reward sounds.

All layers need seamless loops, loudness normalization, lifecycle pause/resume,
separate music/effect controls, and randomized timing for ambient one-shots. The
existing 19.2-second prototype and service abstraction can remain as fallback
while production music is composed or licensed. Procedural placeholder tones
would not meet the requested premium bar.

## Proposed implementation order

This redesign should precede the final HK-030 closed beta:

1. **HK-030-A / UX-R1 — Full-screen world shell:** edge-to-edge camera, compact HUD,
   navigation, anchored room markers, and removal of main-screen admin buttons.
2. **HK-030-B / UX-R2 — Themed interaction system:** shared panels plus redesigned room,
   ghost, mission, incident, offline-return, and result flows.
3. **HK-030-C / UX-R3 — In-world rent:** deterministic per-room balances, coin bubbles,
   collect-all, animation, and safe rewarded post-collection offer.
4. **HK-030-D / UX-R4 — Session goals:** chapter presentation, saved daily contracts,
   tenant requests, progress feedback, and reward chest.
5. **HK-030-E / UX-R5 — Visible progression/content:** owned furniture economy,
   room visual tiers, crystal sinks, ghost scrapbook, portfolio foundations, a
   second playable property/progression stage, and enough content for repeat testing.
6. **HK-030-F / UX-R6 — Audio identity and game feel:** adaptive music/ambience, expanded
   SFX, particles, haptics where appropriate, and accessibility toggles.
7. Run a fresh onboarding, 30-minute session, day-return, economy, lifecycle,
   and device-performance validation before resuming HK-030 store submission.

Keep simulation rules pure Dart, rendering in Flame, panels/navigation in
Flutter, and presentation feedback outside deterministic state transitions.

## Validation targets

Before monetization or closed beta acceptance, validate with real players:

- the next useful action is understood without explanation within five seconds;
- first room interaction occurs within 20 seconds of entering gameplay;
- first visible improvement occurs within three minutes;
- the first session supports 10–15 minutes without forced waiting;
- a returning player has at least three meaningful actions within one minute;
- no player must watch an ad to collect earned rent or advance a core mission;
- players can explain what coins, crystals, happiness, reputation, and chaos do;
- panels pass compact/large Android viewport and accessibility checks;
- device tests show stable frame pacing with full-screen art and particles;
- qualitative testing describes the presentation as cohesive and game-like,
  rather than as a Flutter application or prototype.

Analytics should support these questions, but local playtest observation and
interviews remain necessary. Do not infer retention readiness from test-suite
success or store screenshots.

