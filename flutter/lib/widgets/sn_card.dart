import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';

/// A standard StudyNest surface card with accent border support.
class SnCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const SnCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;
    final br = borderRadius ?? BorderRadius.circular(18);

    return Material(
      color:        t.surface,
      borderRadius: br,
      child: InkWell(
        onTap:        onTap,
        borderRadius: br,
        splashColor:  t.accent.withValues(alpha: 0.08),
        child: Container(
          padding:     padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: br,
            border: Border.all(color: t.line),
            boxShadow: [
              BoxShadow(
                color:       t.accent.withValues(alpha: 0.06),
                blurRadius:  10,
                offset:      const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Doc icon tile — rounded square with professional icon.
class DocIconTile extends ConsumerWidget {
  final IconData icon;
  final double size;

  const DocIconTile({super.key, required this.icon, this.size = 42});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        color:        t.surface2,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: t.accent),
    );
  }
}

/// File format badge - shows file type with icon and label
class FileFormatBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const FileFormatBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filled pill chip (accent or surface2).
class SnChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? activeColor;
  final VoidCallback? onTap;

  const SnChip({
    super.key,
    required this.label,
    this.active = false,
    this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active
        ? (activeColor ?? scheme.primary)
        : scheme.surfaceContainerHighest;
    final fg = active ? Colors.white : scheme.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      fg,
            fontSize:   12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Heart favorite button.
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final Color accentColor;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed:   onTap,
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? accentColor : accentColor.withValues(alpha: 0.35),
        size:  22,
      ),
      tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
    );
  }
}

/// Section header row with optional action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w800,
            fontFamily: 'Fraunces',
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color:      scheme.primary,
                fontSize:   12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
