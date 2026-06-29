import 'package:flutter/material.dart';
import '../widgets/liquid_glass_card.dart';

/// A glassmorphism-inspired card showing three micro-climate readings
/// side-by-side: temperature, humidity, and atmospheric pressure.
class ClimateCard extends StatelessWidget {
  final double temp;
  final int humidity;
  final int pressure;

  const ClimateCard({
    super.key,
    required this.temp,
    required this.humidity,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          _ClimateItem(
            icon: Icons.thermostat_rounded,
            iconColor: const Color(0xFFFF7043), // warm orange
            value: '${temp.toStringAsFixed(1)}',
            unit: '°C',
          ),
          _divider(theme),
          _ClimateItem(
            icon: Icons.water_drop_rounded,
            iconColor: const Color(0xFF42A5F5), // water blue
            value: '$humidity',
            unit: '%',
          ),
          _divider(theme),
          _ClimateItem(
            icon: Icons.cloud_rounded,
            iconColor: const Color(0xFF78909C), // blue-grey
            value: '$pressure',
            unit: 'hPa',
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      height: 48,
      width: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.12),
    );
  }
}

// ── Individual climate metric ────────────────────────────────────────────────

class _ClimateItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;

  const _ClimateItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with soft coloured circle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 12),

          // Value
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),

          // Unit label
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
