import 'package:flutter/material.dart';
import '../widgets/liquid_glass_card.dart';

/// Bottom status bar showing battery level and trap-box condition.
///
/// The battery icon adapts to the current charge percentage, and the
/// trap-box chip turns green (SAFE) or red (ALERT) based on its state.
class StatusIndicator extends StatelessWidget {
  final int batteryLevel;
  final String trapBox;

  const StatusIndicator({
    super.key,
    required this.batteryLevel,
    required this.trapBox,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Row(
        children: [
          // ── Battery ───────────────────────────────────────────────────
          Expanded(child: _BatteryTile(level: batteryLevel)),

          // Vertical divider
          Container(
            height: 40,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),

          // ── Trap box ──────────────────────────────────────────────────
          Expanded(child: _TrapBoxTile(status: trapBox)),
        ],
      ),
    );
  }
}

// ── Battery sub-widget ───────────────────────────────────────────────────────

class _BatteryTile extends StatelessWidget {
  final int level;
  const _BatteryTile({required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _batteryColor(level);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_batteryIcon(level), size: 22, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$level%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              'Battery',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _batteryIcon(int level) {
    if (level >= 95) return Icons.battery_full_rounded;
    if (level >= 80) return Icons.battery_6_bar_rounded;
    if (level >= 60) return Icons.battery_5_bar_rounded;
    if (level >= 40) return Icons.battery_3_bar_rounded;
    if (level >= 20) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Color _batteryColor(int level) {
    if (level >= 60) return const Color(0xFF2E7D32); // Hijau Kantung Semar
    if (level >= 30) return const Color(0xFFF57F17); // Kuning Jeruk Warning
    return const Color(0xFFEF5350); // Red alert
  }
}

// ── Trap box sub-widget ──────────────────────────────────────────────────────

class _TrapBoxTile extends StatelessWidget {
  final String status;
  const _TrapBoxTile({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSafe = status.toUpperCase() == 'SAFE';
    final isWarning = status.toUpperCase().contains('WARN') ||
        status.toUpperCase().contains('MAINT') ||
        status.toUpperCase().contains('BAIT');
    final color = isSafe
        ? const Color(0xFF2E7D32) // Hijau Kantung Semar
        : (isWarning
            ? const Color(0xFFF57F17) // Kuning Jeruk Warning
            : const Color(0xFFEF5350));

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inventory_2_rounded,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              'Trap Box',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
