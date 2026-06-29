import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../widgets/liquid_glass_card.dart';

class HeroCounter extends StatelessWidget {
  final int flyCount;

  const HeroCounter({super.key, required this.flyCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const primaryGreen = Color(0xFF2E7D32); // Hijau Kantung Semar

    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fly icon (Enlarged for space) ────────────────────────────
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryGreen.withValues(alpha: 0.20),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.pest_control,
              size: 54,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 18),

          // ── Label ─────────────────────────────────────────────────────
          Text(
            'FLIES TRAPPED',
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 2.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 8),

          // ── Animated count ────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              '$flyCount',
              key: ValueKey<int>(flyCount),
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 72,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Reset button ──────────────────────────────────────────────
          _ResetButton(onPressed: () => _confirmReset(context)),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Counter'),
        content: const Text(
          'Are you sure you want to reset the fly count to 0?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              FirebaseService().resetFlyCount();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Private helper widget ────────────────────────────────────────────────────

class _ResetButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ResetButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restart_alt_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Reset',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
