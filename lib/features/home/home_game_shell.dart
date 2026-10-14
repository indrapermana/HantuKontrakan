import 'package:flutter/material.dart';

import '../../game/assets/game_assets.dart';

const _wood = Color(0xFF3A251F);
const _woodLight = Color(0xFF694536);
const _parchment = Color(0xFFFFE9B8);
const _gold = Color(0xFFFFC84A);
const _night = Color(0xFF111631);
const _actionGreen = Color(0xFF25A95C);

class HomeGameHud extends StatelessWidget {
  const HomeGameHud({
    required this.levelLabel,
    required this.experienceProgress,
    required this.coinLabel,
    required this.crystalLabel,
    required this.happinessLabel,
    required this.settingsTooltip,
    required this.languageTooltip,
    required this.onSettings,
    required this.onLanguage,
    super.key,
  });

  final String levelLabel;
  final double experienceProgress;
  final String coinLabel;
  final String crystalLabel;
  final String happinessLabel;
  final String settingsTooltip;
  final String languageTooltip;
  final VoidCallback onSettings;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _night.withValues(alpha: 0.9),
      border: const Border(bottom: BorderSide(color: _woodLight, width: 2)),
      boxShadow: const [
        BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _LevelBadge(label: levelLabel, progress: experienceProgress),
              const SizedBox(width: 6),
              Expanded(
                child: _ResourceChip(
                  key: const Key('wallet-coins'),
                  imageAsset: GameAssets.spiritCoin,
                  label: coinLabel,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ResourceChip(
                  key: const Key('mystical-crystals'),
                  icon: Icons.diamond_rounded,
                  iconColor: const Color(0xFFB96CFF),
                  label: crystalLabel,
                ),
              ),
              const SizedBox(width: 4),
              _HudIconButton(
                key: const Key('language-button'),
                tooltip: languageTooltip,
                onPressed: onLanguage,
                icon: const Icon(Icons.language_rounded),
              ),
              _HudIconButton(
                key: const Key('settings-button'),
                tooltip: settingsTooltip,
                onPressed: onSettings,
                icon: Image.asset(
                  GameAssets.settingsIcon,
                  width: 25,
                  height: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _wood.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _woodLight),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Text(
                  happinessLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _parchment,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class WorldActionOverlay extends StatelessWidget {
  const WorldActionOverlay({
    required this.collectLabel,
    required this.canCollect,
    required this.onCollect,
    required this.complaintLabel,
    required this.hasComplaint,
    required this.onComplaint,
    required this.moreTooltip,
    required this.onMore,
    this.incidentLabel,
    this.onIncident,
    super.key,
  });

  final String collectLabel;
  final bool canCollect;
  final VoidCallback onCollect;
  final String complaintLabel;
  final bool hasComplaint;
  final VoidCallback onComplaint;
  final String moreTooltip;
  final VoidCallback onMore;
  final String? incidentLabel;
  final VoidCallback? onIncident;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        right: 12,
        bottom: 90,
        child: FilledButton.icon(
          key: const Key('collect-rent'),
          style: FilledButton.styleFrom(
            backgroundColor: _actionGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _wood.withValues(alpha: 0.82),
            disabledForegroundColor: Colors.white60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            side: const BorderSide(color: _parchment, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 8,
          ),
          onPressed: canCollect ? onCollect : null,
          icon: Image.asset(GameAssets.spiritCoin, width: 24, height: 24),
          label: Text(
            collectLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      if (hasComplaint)
        Positioned(
          left: 12,
          bottom: 146,
          child: _WorldMarker(
            key: const Key('complaint-button'),
            icon: Icons.campaign_rounded,
            label: complaintLabel,
            color: const Color(0xFFFFB33E),
            onPressed: onComplaint,
          ),
        )
      else
        Positioned(
          left: 12,
          bottom: 146,
          child: SizedBox(
            width: 1,
            height: 1,
            child: FilledButton(
              key: const Key('complaint-button'),
              onPressed: null,
              child: Text(complaintLabel),
            ),
          ),
        ),
      if (incidentLabel != null && onIncident != null)
        Positioned(
          left: 12,
          bottom: 208,
          child: _WorldMarker(
            key: const Key('incident-button'),
            icon: Icons.crisis_alert_rounded,
            label: incidentLabel!,
            color: const Color(0xFFE95858),
            onPressed: onIncident!,
          ),
        ),
      Positioned(
        right: 12,
        bottom: 148,
        child: _HudIconButton(
          key: const Key('action-center-button'),
          tooltip: moreTooltip,
          onPressed: onMore,
          icon: const Icon(Icons.auto_awesome_motion_rounded),
        ),
      ),
    ],
  );
}

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    required this.homeLabel,
    required this.missionsLabel,
    required this.ghostsLabel,
    required this.shopLabel,
    required this.onMissions,
    required this.onGhosts,
    required this.onShop,
    super.key,
  });

  final String homeLabel;
  final String missionsLabel;
  final String ghostsLabel;
  final String shopLabel;
  final VoidCallback onMissions;
  final VoidCallback onGhosts;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: _wood,
        border: Border(top: BorderSide(color: _woodLight, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              Expanded(
                child: _NavigationItem(
                  key: const Key('home-navigation'),
                  icon: Icons.home_work_rounded,
                  label: homeLabel,
                  selected: true,
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  key: const Key('missions-button'),
                  icon: Icons.assignment_turned_in_rounded,
                  label: missionsLabel,
                  showBadge: true,
                  onPressed: onMissions,
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  key: const Key('ghosts-navigation'),
                  icon: Icons.person_pin_circle_rounded,
                  label: ghostsLabel,
                  onPressed: onGhosts,
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  key: const Key('shop-navigation'),
                  icon: Icons.storefront_rounded,
                  label: shopLabel,
                  onPressed: onShop,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
    width: 62,
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
    decoration: BoxDecoration(
      color: _wood,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _woodLight, width: 2),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: _parchment,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 5,
            color: const Color(0xFF42D879),
            backgroundColor: Colors.black38,
          ),
        ),
      ],
    ),
  );
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({
    required this.label,
    this.imageAsset,
    this.icon,
    this.iconColor,
    super.key,
  });

  final String label;
  final String? imageAsset;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 42),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: _wood,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _woodLight, width: 2),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imageAsset != null)
          Image.asset(imageAsset!, width: 24, height: 24)
        else
          Icon(icon, size: 22, color: iconColor ?? _gold),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: _wood,
      foregroundColor: _parchment,
      side: const BorderSide(color: _woodLight, width: 2),
      minimumSize: const Size(42, 42),
    ),
    icon: icon,
  );
}

class _WorldMarker extends StatelessWidget {
  const _WorldMarker({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 230),
    child: FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _wood.withValues(alpha: 0.94),
        foregroundColor: Colors.white,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 7,
      ),
      icon: Icon(icon, color: color),
      label: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    ),
  );
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.showBadge = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final bool showBadge;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: label,
    child: InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: selected
            ? BoxDecoration(
                color: _woodLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold, width: 2),
              )
            : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? _gold : _parchment, size: 25),
                const SizedBox(height: 2),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected ? _gold : _parchment,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (showBadge)
              const Positioned(
                top: 7,
                right: 15,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE84D4D),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 10, height: 10),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
