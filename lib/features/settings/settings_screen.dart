import 'package:flutter/material.dart';

import '../../core/constants/flexvault_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routePath = '/app/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: FlexVaultColors.headerGradient,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SettingsSection(
            title: 'General',
            children: [
              _SettingsTile(
                title: 'Dark Mode',
                trailing: _SettingsSwitch(),
              ),
              _SettingsTile(
                title: 'Language',
                subtitle: 'English',
                trailing: Icon(Icons.chevron_right),
              ),
              _SettingsTile(
                title: 'Notifications',
                trailing: _SettingsSwitch(),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                title: 'Profile',
                subtitle: 'maya@flexvault.com',
                trailing: Icon(Icons.chevron_right),
              ),
              _SettingsTile(
                title: 'Two-Factor Authentication',
                trailing: _SettingsSwitch(),
              ),
              _SettingsTile(
                title: 'Client-Side Encryption',
                subtitle: 'Encrypt files before upload',
                trailing: _SettingsSwitch(),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Support',
            children: [
              _SettingsTile(
                title: 'Help Center',
                trailing: Icon(Icons.open_in_new),
              ),
              _SettingsTile(
                title: 'Contact Support',
                trailing: Icon(Icons.chat_bubble_outline),
              ),
              _SettingsTile(
                title: 'About FlexVault',
                subtitle: 'Version 1.0.0',
                trailing: Icon(Icons.info_outline),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Danger Zone',
            borderColor: FlexVaultColors.reddishBrown,
            children: [
              _SettingsTile(
                title: 'Clear Cache',
                trailing: Icon(Icons.cleaning_services_outlined),
              ),
              _SettingsTile(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account & data',
                trailing: Icon(Icons.delete_outline, color: FlexVaultColors.reddishBrown),
                titleColor: FlexVaultColors.reddishBrown,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    this.borderColor,
  });

  final String title;
  final List<Widget> children;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: FlexVaultColors.reddishBrown),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
    );
  }
}

class _SettingsSwitch extends StatefulWidget {
  const _SettingsSwitch();

  @override
  State<_SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<_SettingsSwitch> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeThumbColor: FlexVaultColors.teaGreen,
      value: value,
      onChanged: (v) => setState(() => value = v),
    );
  }
}

