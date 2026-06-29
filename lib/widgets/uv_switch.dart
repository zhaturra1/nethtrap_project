import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../widgets/liquid_glass_card.dart';

/// Material 3 segmented button allowing the user to toggle the UV lamp
/// between AUTO, MANUAL ON, and MANUAL OFF modes.
///
/// Each change is written to Firebase immediately.
class UvSwitch extends StatelessWidget {
  final String currentMode; // "AUTO" | "MANUAL_ON" | "MANUAL_OFF"

  const UvSwitch({super.key, required this.currentMode});

  // Maps user-facing labels ↔ Firebase values.
  static const _modes = <String, String>{
    'AUTO': 'AUTO',
    'ON': 'MANUAL_ON',
    'OFF': 'MANUAL_OFF',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine which segment is currently selected.
    final selectedLabel = _modes.entries
        .firstWhere(
          (e) => e.value == currentMode,
          orElse: () => const MapEntry('AUTO', 'AUTO'),
        )
        .key;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _lampColor(currentMode).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  size: 22,
                  color: _lampColor(currentMode),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UV Lamp',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusLabel(currentMode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _lampColor(currentMode),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Segmented control ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.comfortable,
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              segments: _modes.keys.map((label) {
                return ButtonSegment<String>(
                  value: label,
                  label: Text(label),
                );
              }).toList(),
              selected: {selectedLabel},
              onSelectionChanged: (selection) {
                final firebaseValue = _modes[selection.first]!;
                FirebaseService().updateUvLamp(firebaseValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _lampColor(String mode) {
    switch (mode) {
      case 'MANUAL_ON':
        return const Color(0xFFFFCA28); // amber
      case 'MANUAL_OFF':
        return const Color(0xFF78909C); // grey
      default: // AUTO
        return const Color(0xFF2E7D32); // Hijau Kantung Semar
    }
  }

  String _statusLabel(String mode) {
    switch (mode) {
      case 'MANUAL_ON':
        return 'Forced ON';
      case 'MANUAL_OFF':
        return 'Forced OFF';
      default:
        return 'Automatic';
    }
  }
}
