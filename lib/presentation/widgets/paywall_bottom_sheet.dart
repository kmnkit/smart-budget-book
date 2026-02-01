import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/generated/l10n/app_localizations.dart';

class PaywallBottomSheet extends StatelessWidget {
  const PaywallBottomSheet({
    super.key,
    this.reason,
    this.remaining,
    this.limit,
  });

  final String? reason;
  final int? remaining;
  final int? limit;

  static Future<void> show(
    BuildContext context, {
    String? reason,
    int? remaining,
    int? limit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PaywallBottomSheet(
        reason: reason,
        remaining: remaining,
        limit: limit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Lock icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              l10n.premiumRequired,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Reason
            if (reason != null) ...[
              Text(
                reason!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            // Usage indicator
            if (remaining != null && limit != null) ...[
              Text(
                '${limit! - remaining!} / $limit',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (limit! - remaining!) / limit!,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            // Premium features list
            _FeatureRow(
              icon: Icons.all_inclusive,
              text: l10n.premiumFeatureUnlimited,
            ),
            _FeatureRow(
              icon: Icons.smart_toy_outlined,
              text: l10n.premiumFeatureAi,
            ),
            _FeatureRow(
              icon: Icons.currency_exchange,
              text: l10n.premiumFeatureMultiCurrency,
            ),
            _FeatureRow(
              icon: Icons.history,
              text: l10n.premiumFeatureFullHistory,
            ),
            const SizedBox(height: 24),
            // CTA button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.subscription);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.upgradeToPremium),
              ),
            ),
            const SizedBox(height: 8),
            // Dismiss
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.maybeLater),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
