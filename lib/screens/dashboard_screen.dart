import 'package:flutter/material.dart';

import '../models/telemetry_model.dart';
import '../services/firebase_service.dart';
import '../widgets/climate_card.dart';
import '../widgets/hero_counter.dart';
import '../widgets/status_indicator.dart';
import '../widgets/uv_switch.dart';

/// The single main screen of NephTrap.
///
/// Wraps every widget inside a [StreamBuilder] that listens to the Firebase
/// device stream, automatically rebuilding the UI whenever new data arrives.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.pest_control_rounded,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'NephTrap',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          // Demo mode badge
          if (FirebaseService().isDemoMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'DEMO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFFFA726),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          // Live indicator dot
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF66BB6A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF66BB6A),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: StreamBuilder<DeviceData>(
        stream: FirebaseService().deviceStream,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to device…'),
                ],
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connection Error',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          // Data state
          final data = snapshot.data ?? DeviceData.empty();
          final telemetry = data.telemetry;
          final status = data.status;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              children: [
                // Hero counter
                HeroCounter(flyCount: telemetry.flyCount),
                const SizedBox(height: 20),

                // Micro-climate card
                ClimateCard(
                  temp: telemetry.temp,
                  humidity: telemetry.humidity,
                  pressure: telemetry.pressure,
                ),
                const SizedBox(height: 20),

                // UV lamp control
                UvSwitch(currentMode: status.uvLamp),
                const SizedBox(height: 20),

                // Bottom status bar
                StatusIndicator(
                  batteryLevel: status.batteryLevel,
                  trapBox: status.trapBox,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
