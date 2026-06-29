import 'package:flutter/material.dart';
import '../widgets/liquid_glass_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LiquidBackgroundMesh(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.pest_control_rounded,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // App Title
                Text(
                  'NephTrap',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),

                // Slogan
                Text(
                  'Smart Eco-Friendly Fly Trap',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),

                // Sub-description
                Text(
                  'Pantau perangkat perangkap lalat pintarmu secara real-time dan lindungi lingkungan dengan teknologi IoT.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                ),
                const Spacer(),

                // Get Started Button inside a Glass Container
                LiquidGlassCard(
                  padding: const EdgeInsets.all(8),
                  variant: LiquidGlassVariant.clear,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      'Mulai Sekarang',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
