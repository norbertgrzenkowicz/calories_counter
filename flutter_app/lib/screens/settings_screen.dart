import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'export_data_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.neonGreen,
        foregroundColor: AppTheme.darkBackground,
      ),
      backgroundColor: AppTheme.darkBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Data Management',
            children: [
              _buildSettingsTile(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download your weight history and meal data',
                onTap: () => _navigateToExportData(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Account',
            children: [
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Profile Settings',
                subtitle: 'Manage your profile information',
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Support',
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingsTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.neonGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _navigateToExportData(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportDataScreen()),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        backgroundColor: AppTheme.neonGreen,
      ),
    );
  }
}