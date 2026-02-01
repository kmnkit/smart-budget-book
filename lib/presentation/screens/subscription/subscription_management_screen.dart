import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';

class SubscriptionManagementScreen extends ConsumerWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final quotaAsync = ref.watch(usageQuotaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionManagement),
      ),
      body: subscriptionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(l10n.errorOccurred)),
        data: (subscription) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current plan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      subscription.tier == SubscriptionTier.premium
                          ? Icons.workspace_premium
                          : Icons.person_outline,
                      size: 48,
                      color: subscription.tier == SubscriptionTier.premium
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subscription.tier == SubscriptionTier.premium
                          ? l10n.zanPremium
                          : l10n.freePlan,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusText(l10n, subscription.status),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _statusColor(theme, subscription.status),
                      ),
                    ),
                    if (subscription.currentPeriodEndAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.nextRenewal}: ${_formatDate(subscription.currentPeriodEndAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (subscription.status == SubscriptionStatus.trialing &&
                        subscription.trialEndAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.trialEndsOn}: ${_formatDate(subscription.trialEndAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Usage statistics
            quotaAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (quota) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.usageThisMonth,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _UsageRow(
                        label: l10n.transactionsUsage,
                        current: quota.transactionsThisMonth,
                        limit: quota.transactionsLimit,
                      ),
                      const SizedBox(height: 12),
                      _UsageRow(
                        label: l10n.accountsUsage,
                        current: quota.accountCount,
                        limit: quota.accountsLimit,
                      ),
                      const SizedBox(height: 12),
                      _UsageRow(
                        label: l10n.aiInputsUsage,
                        current: quota.aiInputsThisMonth,
                        limit: quota.aiInputsLimit,
                      ),
                      const SizedBox(height: 12),
                      _UsageRow(
                        label: l10n.ocrScansUsage,
                        current: quota.ocrScansThisMonth,
                        limit: quota.ocrScansLimit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Manage subscription note
            Text(
              l10n.manageSubscriptionNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(AppLocalizations l10n, SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.none => l10n.statusFree,
      SubscriptionStatus.trialing => l10n.statusTrialing,
      SubscriptionStatus.active => l10n.statusActive,
      SubscriptionStatus.pastDue => l10n.statusPastDue,
      SubscriptionStatus.expired => l10n.statusExpired,
      SubscriptionStatus.canceled => l10n.statusCanceled,
    };
  }

  Color _statusColor(ThemeData theme, SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.active || SubscriptionStatus.trialing =>
        Colors.green,
      SubscriptionStatus.pastDue => Colors.orange,
      SubscriptionStatus.expired || SubscriptionStatus.canceled =>
        theme.colorScheme.error,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.label,
    required this.current,
    required this.limit,
  });

  final String label;
  final int current;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlimited = limit < 0;
    final progress = isUnlimited ? 0.0 : (limit > 0 ? current / limit : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              isUnlimited ? '$current / ∞' : '$current / $limit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: !isUnlimited && progress >= 0.9
                    ? theme.colorScheme.error
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: isUnlimited ? 0 : progress.clamp(0.0, 1.0),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: !isUnlimited && progress >= 0.9
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
        ),
      ],
    );
  }
}
