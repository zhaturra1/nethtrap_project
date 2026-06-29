import 'package:flutter/material.dart';

import '../models/history_model.dart';
import '../widgets/liquid_glass_card.dart';

/// Colour-coded alert card showing the current outbreak risk level.
///
/// - 🟢 LOW    → green, calm
/// - 🟡 MODERATE → amber, attention
/// - 🔴 HIGH   → red with pulsing animation
class OutbreakCard extends StatefulWidget {
  final OutbreakWarning warning;
  const OutbreakCard({super.key, required this.warning});

  @override
  State<OutbreakCard> createState() => _OutbreakCardState();
}

class _OutbreakCardState extends State<OutbreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.warning.level == OutbreakLevel.high) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant OutbreakCard old) {
    super.didUpdateWidget(old);
    if (widget.warning.level == OutbreakLevel.high) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = widget.warning;
    final color = _levelColor(w.level);
    final icon = _levelIcon(w.level);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          customBorderColor: color.withValues(
              alpha: w.level == OutbreakLevel.high
                  ? 0.7 * _pulseAnimation.value
                  : 0.4),
          child: child!,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _levelBadge(w.level),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color.withValues(alpha: 0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Message ───────────────────────────────────────────────────
          Text(
            w.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── Factors ───────────────────────────────────────────────────
          if (w.factors.isNotEmpty) ...[
            Text(
              'Faktor Penyebab:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            ...w.factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(color: color, fontSize: 14)),
                      Expanded(
                        child: Text(
                          f,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // ── Recommendations (only for moderate/high) ──────────────────
          if (w.level != OutbreakLevel.low) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded,
                          size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        'Rekomendasi:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...w.recommendations.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('→ ',
                                style: TextStyle(color: color, fontSize: 12)),
                            Expanded(
                              child: Text(r,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    height: 1.4,
                                  )),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _levelColor(OutbreakLevel level) {
    switch (level) {
      case OutbreakLevel.high:
        return const Color(0xFFEF5350); // Red alert
      case OutbreakLevel.moderate:
        return const Color(0xFFF57F17); // Kuning Jeruk Warning
      case OutbreakLevel.low:
        return const Color(0xFF2E7D32); // Hijau Kantung Semar
    }
  }

  IconData _levelIcon(OutbreakLevel level) {
    switch (level) {
      case OutbreakLevel.high:
        return Icons.warning_rounded;
      case OutbreakLevel.moderate:
        return Icons.info_rounded;
      case OutbreakLevel.low:
        return Icons.check_circle_rounded;
    }
  }

  String _levelBadge(OutbreakLevel level) {
    switch (level) {
      case OutbreakLevel.high:
        return 'RISIKO TINGGI';
      case OutbreakLevel.moderate:
        return 'RISIKO SEDANG';
      case OutbreakLevel.low:
        return 'RISIKO RENDAH';
    }
  }
}

