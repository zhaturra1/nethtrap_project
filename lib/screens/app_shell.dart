import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../widgets/liquid_glass_card.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'report_screen.dart';

/// Root navigation shell with a Material 3 bottom NavigationBar.
///
/// Manages page switching between Dashboard, Analytics, and Report screens
/// while preserving state across tab switches via [IndexedStack].
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LiquidBackgroundMesh(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) => setState(() => _currentIndex = i),
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                indicatorColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                height: 72,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded,
                        color: Color(0xFF2E7D32)),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics_rounded,
                        color: Color(0xFF2E7D32)),
                    label: 'Analitik',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.description_outlined),
                    selectedIcon: Icon(Icons.description_rounded,
                        color: Color(0xFF2E7D32)),
                    label: 'Laporan',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
