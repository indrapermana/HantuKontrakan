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
