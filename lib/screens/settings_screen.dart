import 'package:flutter/material.dart';
import '../widgets/liquid_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _outbreakNotifications = true;
  bool _maintenanceAlerts = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LiquidBackgroundMesh(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              // User Profile Section
              LiquidGlassCard(
                padding: const EdgeInsets.all(20),
                variant: LiquidGlassVariant.prism,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administrator',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'admin@nephtrap.com',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Device Location
              Text(
                'Konfigurasi Perangkat',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              LiquidGlassCard(
                padding: EdgeInsets.zero,
                variant: LiquidGlassVariant.frosted,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Lokasi Pemasangan'),
                      subtitle: const Text('Kandang Ayam Area B'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ListTile(
                      leading: const Icon(Icons.wifi_rounded),
                      title: const Text('Koneksi Perangkat'),
                      subtitle: const Text('Terhubung (Device #01)'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications
              Text(
                'Notifikasi',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              LiquidGlassCard(
                padding: EdgeInsets.zero,
                variant: LiquidGlassVariant.frosted,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _outbreakNotifications,
                      onChanged: (val) => setState(() => _outbreakNotifications = val),
                      title: const Text('Peringatan Wabah'),
                      subtitle: const Text('Notifikasi tren penetasan lalat'),
                      secondary: const Icon(Icons.warning_amber_rounded),
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    SwitchListTile(
                      value: _maintenanceAlerts,
                      onChanged: (val) => setState(() => _maintenanceAlerts = val),
                      title: const Text('Pengingat Pemeliharaan'),
                      subtitle: const Text('Baterai lemah & kotak penuh'),
                      secondary: const Icon(Icons.build_circle_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Logout Button
              LiquidGlassCard(
                padding: EdgeInsets.zero,
                variant: LiquidGlassVariant.clear,
                child: ListTile(
                  leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                  title: Text(
                    'Keluar Akun',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Navigate back to Login and clear stack
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
