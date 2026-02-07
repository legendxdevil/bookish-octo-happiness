import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_cubit.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/custom_text_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is ApiKeyValidated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isValid
                      ? 'API key validated successfully'
                      : 'Invalid API key',
                ),
                backgroundColor: state.isValid
                    ? colorScheme.secondary
                    : colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SettingsBloc>().add(LoadSettings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SettingsLoaded) {
            _apiKeyController.text = state.settings.geminiApiKey ?? '';

            return ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // AI Settings Section
                _SectionHeader(title: 'AI Configuration'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: state.isApiKeyValid
                                    ? colorScheme.secondaryContainer
                                    : colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.key,
                                color: state.isApiKeyValid
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gemini API Key',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    state.isApiKeyValid
                                        ? 'Configured'
                                        : 'Not configured',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: state.isApiKeyValid
                                          ? colorScheme.secondary
                                          : colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter your Gemini API key to enable AI features. Your key is stored securely on your device.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _apiKeyController,
                          hint: 'Enter your Gemini API key',
                          prefixIcon: LucideIcons.key,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final key = _apiKeyController.text.trim();
                                  if (key.isNotEmpty) {
                                    context.read<SettingsBloc>().add(
                                      ValidateApiKey(apiKey: key),
                                    );
                                  }
                                },
                                icon: const Icon(LucideIcons.check, size: 18),
                                label: const Text('Validate'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final key = _apiKeyController.text.trim();
                                  if (key.isNotEmpty) {
                                    context.read<SettingsBloc>().add(
                                      UpdateApiKey(apiKey: key),
                                    );
                                  }
                                },
                                icon: const Icon(LucideIcons.save, size: 18),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 24),

                // Appearance Section
                _SectionHeader(title: 'Appearance'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.moon,
                      title: 'Theme',
                      subtitle: state.settings.themeMode == 'dark'
                          ? 'Dark'
                          : state.settings.themeMode == 'system'
                              ? 'System'
                              : 'Light',
                      onTap: () => _showThemePicker(context, state.settings.themeMode),
                    ),
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    _SettingsTile(
                      icon: LucideIcons.dollarSign,
                      title: 'Currency',
                      subtitle: state.settings.currency,
                      onTap: () => _showCurrencyPicker(context, state.settings.currency),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideX(),
                const SizedBox(height: 24),

                // Preferences Section
                _SectionHeader(title: 'Preferences'),
                _SettingsCard(
                  children: [
                    _SettingsSwitchTile(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: 'Receive spending alerts and tips',
                      value: state.settings.notificationsEnabled,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          UpdateNotifications(enabled: value),
                        );
                      },
                    ),
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    _SettingsSwitchTile(
                      icon: LucideIcons.sparkles,
                      title: 'AI Tips',
                      subtitle: 'Show AI tips on dashboard',
                      value: state.settings.aiTipsEnabled,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          UpdateAiTips(enabled: value),
                        );
                      },
                    ),
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    _SettingsSwitchTile(
                      icon: LucideIcons.eyeOff,
                      title: 'Privacy Mode',
                      subtitle: 'Hide sensitive financial data',
                      value: state.settings.privacyMode,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          UpdatePrivacyMode(enabled: value),
                        );
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(),
                const SizedBox(height: 24),

                // Data Section
                _SectionHeader(title: 'Data'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.download,
                      title: 'Export Data',
                      subtitle: 'Download your data as JSON',
                      onTap: () {
                        context.read<SettingsBloc>().add(ExportData());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data exported successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    _SettingsTile(
                      icon: LucideIcons.upload,
                      title: 'Import Data',
                      subtitle: 'Restore from backup',
                      onTap: () {
                        // TODO: Implement data import
                      },
                    ),
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    _SettingsTile(
                      icon: LucideIcons.trash2,
                      title: 'Clear All Data',
                      subtitle: 'Delete all local data',
                      textColor: colorScheme.error,
                      iconColor: colorScheme.error,
                      onTap: () => _showClearDataDialog(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideX(),
                const SizedBox(height: 24),

                // Account Section
                _SectionHeader(title: 'Account'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      subtitle: 'Log out of your account',
                      textColor: colorScheme.error,
                      iconColor: colorScheme.error,
                      onTap: () => _showSignOutDialog(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideX(),
                const SizedBox(height: 40),

                // App Info
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context, String currentTheme) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              title: const Text('Light'),
              trailing: currentTheme == 'light'
                  ? Icon(LucideIcons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                context.read<SettingsBloc>().add(
                  const UpdateThemeMode(themeMode: 'light'),
                );
                context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              trailing: currentTheme == 'dark'
                  ? Icon(LucideIcons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                context.read<SettingsBloc>().add(
                  const UpdateThemeMode(themeMode: 'dark'),
                );
                context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System'),
              trailing: currentTheme == 'system'
                  ? Icon(LucideIcons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                context.read<SettingsBloc>().add(
                  const UpdateThemeMode(themeMode: 'system'),
                );
                context.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, String currentCurrency) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...AppConstants.currencies.map((currency) => ListTile(
                  title: Text(currency),
                  trailing: currentCurrency == currency
                      ? Icon(LucideIcons.check, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      UpdateCurrency(currency: currency),
                    );
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions, goals, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(ClearAllData());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
