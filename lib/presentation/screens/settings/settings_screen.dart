import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/material.dart' as material show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/settings_provider.dart';
import 'package:zan/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Profile section
          profileAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (profile) {
              if (profile == null) return const SizedBox.shrink();
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (profile.displayName ?? 'U').substring(0, 1).toUpperCase(),
                  ),
                ),
                title: Text(profile.displayName ?? 'User'),
                subtitle: Text(profile.country == 'JP' ? '🇯🇵 Japan' : '🇰🇷 Korea'),
              );
            },
          ),
          const Divider(),
          // Theme
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            trailing: SegmentedButton<material.ThemeMode>(
              segments: [
                ButtonSegment(
                  value: material.ThemeMode.light,
                  label: Text(l10n.lightTheme),
                ),
                ButtonSegment(
                  value: material.ThemeMode.dark,
                  label: Text(l10n.darkTheme),
                ),
                ButtonSegment(
                  value: material.ThemeMode.system,
                  label: Text(l10n.systemTheme),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selected) {
                ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          // Accounts
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l10n.accounts),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RoutePaths.accountList),
          ),
          const Divider(),
          // Sign out
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              l10n.signOut,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.signOut),
                  content: Text(l10n.confirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.signOut),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(settingsNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(RoutePaths.signIn);
                }
              }
            },
          ),
          // Delete account
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(
              l10n.deleteAccount,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteAccount),
                  content: Text(l10n.deleteAccountConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement account deletion
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
