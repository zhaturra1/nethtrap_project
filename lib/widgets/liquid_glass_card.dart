import 'dart:ui';
import 'package:flutter/material.dart';

/// Variants inspired by ogtirth/liquidglass-oss
enum LiquidGlassVariant { clear, frosted, dark, prism, dome }

/// Preset parameters translating liquidglass-oss optical physics to Flutter properties.
class LiquidGlassSettings {
  final double blur;
  final double opacity;
  final double borderAlpha;
  final double borderWidth;
  final Color tintColor;
  final double specularAlpha;
  final List<BoxShadow> shadows;

  const LiquidGlassSettings({
    required this.blur,
    required this.opacity,
    required this.borderAlpha,
    required this.borderWidth,
    required this.tintColor,
    required this.specularAlpha,
    required this.shadows,
  });
}

class LiquidGlassPresets {
  static const Map<LiquidGlassVariant, LiquidGlassSettings> presets = {
    LiquidGlassVariant.clear: LiquidGlassSettings(
      blur: 10.0,
      opacity: 0.20,
      borderAlpha: 0.70,
      borderWidth: 1.5,
      tintColor: Color(0xFFFFFFFF),
      specularAlpha: 0.40,
      shadows: [
        BoxShadow(color: Color(0x0F1B5E20), blurRadius: 20, offset: Offset(0, 6)),
      ],
    ),
    LiquidGlassVariant.frosted: LiquidGlassSettings(
      blur: 20.0,
      opacity: 0.35, // Translucent for true frosted liquid glass
      borderAlpha: 0.85,
      borderWidth: 1.8,
      tintColor: Color(0xFFFFFFFF),
      specularAlpha: 0.50,
      shadows: [
        BoxShadow(color: Color(0x121B5E20), blurRadius: 24, offset: Offset(0, 8)),
      ],
    ),
    LiquidGlassVariant.dark: LiquidGlassSettings(
      blur: 20.0,
      opacity: 0.75,
      borderAlpha: 0.30,
      borderWidth: 1.2,
      tintColor: Color(0xFF0D1F16),
      specularAlpha: 0.20,
      shadows: [
        BoxShadow(color: Color(0x33000000), blurRadius: 32, offset: Offset(0, 10)),
      ],
    ),
    LiquidGlassVariant.prism: LiquidGlassSettings(
      blur: 16.0,
      opacity: 0.30,
      borderAlpha: 0.90,
      borderWidth: 2.0,
      tintColor: Color(0xFFE8F5E9),
      specularAlpha: 0.75,
      shadows: [
        BoxShadow(color: Color(0x1A2E7D32), blurRadius: 24, offset: Offset(0, 8)),
      ],
    ),
    LiquidGlassVariant.dome: LiquidGlassSettings(
      blur: 18.0,
      opacity: 0.40,
      borderAlpha: 0.80,
      borderWidth: 2.2,
      tintColor: Color(0xFFFFFFFF),
      specularAlpha: 0.60,
      shadows: [
        BoxShadow(color: Color(0x181B5E20), blurRadius: 30, offset: Offset(0, 10)),
      ],
    ),
  };
}

/// A WebGL/physics-inspired Liquid Glass component based on ogtirth/liquidglass-oss.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final LiquidGlassVariant variant;
  final Color? customBorderColor;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.variant = LiquidGlassVariant.frosted,
    this.customBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final settings = LiquidGlassPresets.presets[variant]!;

    return Container(
      width: double.infinity, // Ensures full width expansion matching space!
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: settings.shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: settings.blur,
            sigmaY: settings.blur,
          ),
          child: Stack(
            children: [
              // Liquid Glass Base Glossy Gradient Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      settings.tintColor.withValues(alpha: settings.opacity + 0.10),
                      settings.tintColor.withValues(alpha: settings.opacity - 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: customBorderColor ??
                        Colors.white.withValues(alpha: settings.borderAlpha),
                    width: settings.borderWidth,
                  ),
                ),
                child: child,
              ),

              // Specular Lens Highlight (Glossy Rim Reflections)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 2.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: settings.specularAlpha),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A fluid background mesh with dynamic organic color blobs, giving liquid glass cards something vivid to blur!
class LiquidBackgroundMesh extends StatelessWidget {
  final Widget child;

  const LiquidBackgroundMesh({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base background
        Positioned.fill(
          child: Container(
            color: const Color(0xFFEDF7ED), // Clean soft eco green base
          ),
        ),

        // Fluid Blob 1 - Top Center/Left (Rich Kantung Semar Green)
        Positioned(
          top: 40,
          left: -40,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2E7D32).withValues(alpha: 0.45),
                  const Color(0xFF4CAF50).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Fluid Blob 2 - Center (Lime / Emerald Wave)
        Positioned(
          top: size.height * 0.35,
          right: -60,
          child: Container(
            width: size.width * 0.85,
            height: size.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF81C784).withValues(alpha: 0.50),
                  const Color(0xFF66BB6A).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Fluid Blob 3 - Bottom Left (Soft Bio Sun Amber)
        Positioned(
          bottom: 20,
          left: -50,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFA5D6A7).withValues(alpha: 0.45),
                  const Color(0xFFFFF176).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content on top of liquid mesh
        Positioned.fill(child: child),
      ],
    );
  }
}
