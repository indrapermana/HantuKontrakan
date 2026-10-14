import 'dart:async';

import 'package:flutter/material.dart';

const gamePanelNight = Color(0xFF111631);
const gamePanelWood = Color(0xFF3A251F);
const gamePanelWoodLight = Color(0xFF79513C);
const gamePanelParchment = Color(0xFFFFE9B8);
const gamePanelGold = Color(0xFFFFC84A);
const gamePanelGreen = Color(0xFF25A95C);

class GameDialog extends StatelessWidget {
  const GameDialog({
    required this.title,
    required this.child,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
    this.maxWidth = 520,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.vertical - 48;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: availableHeight.clamp(160.0, media.size.height * 0.86),
        ),
        child: GamePanelFrame(
          title: title,
          icon: icon,
          footer: primaryAction == null && secondaryAction == null
              ? null
              : Row(
                  children: [
                    if (secondaryAction != null)
                      Expanded(child: secondaryAction!),
                    if (secondaryAction != null && primaryAction != null)
                      const SizedBox(width: 10),
                    if (primaryAction != null) Expanded(child: primaryAction!),
                  ],
                ),
          child: child,
        ),
      ),
    );
  }
}

class GameBottomSheetFrame extends StatelessWidget {
  const GameBottomSheetFrame({
    required this.title,
    required this.child,
    this.icon,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: GamePanelFrame(title: title, icon: icon, child: child),
    ),
  );
}

class GamePanelFrame extends StatelessWidget {
  const GamePanelFrame({
    required this.title,
    required this.child,
    this.icon,
    this.footer,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Material(
    color: gamePanelNight,
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gamePanelWoodLight, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: gamePanelWood,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(icon, color: gamePanelGold, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: gamePanelParchment,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 2, color: gamePanelWoodLight),
            const SizedBox(height: 14),
            Flexible(child: child),
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ],
        ),
      ),
    ),
  );
}

class GameChoiceCard extends StatelessWidget {
  const GameChoiceCard({
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.leading,
    this.enabled = true,
    this.primary = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final Widget? leading;
  final bool enabled;
  final bool primary;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    child: Card(
      color: primary ? gamePanelWood : gamePanelNight.withValues(alpha: 0.72),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primary ? gamePanelGold : gamePanelWoodLight,
          width: primary ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: enabled ? gamePanelParchment : Colors.white38,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: enabled ? Colors.white70 : Colors.white30,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? gamePanelGold : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class GamePrimaryButton extends StatefulWidget {
  const GamePrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final FutureOr<void> Function()? onPressed;
  final IconData? icon;

  @override
  State<GamePrimaryButton> createState() => _GamePrimaryButtonState();
}

class _GamePrimaryButtonState extends State<GamePrimaryButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: widget.onPressed == null || _busy ? null : _run,
    style: FilledButton.styleFrom(
      backgroundColor: gamePanelGreen,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    icon: _busy
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(widget.icon ?? Icons.check_rounded),
    label: Text(widget.label, textAlign: TextAlign.center),
  );
}

class GameSecondaryButton extends StatelessWidget {
  const GameSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: gamePanelParchment,
      minimumSize: const Size.fromHeight(48),
      side: const BorderSide(color: gamePanelWoodLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}
