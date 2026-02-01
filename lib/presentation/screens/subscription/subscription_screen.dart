import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zan/config/di/purchase_providers.dart';
import 'package:zan/data/datasources/local/purchase_service.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;
  String? _selectedProductId;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _selectedProductId = PurchaseService.annualProductId;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final purchaseService = ref.read(purchaseServiceProvider);
    final products = await purchaseService.getProducts();
    if (mounted) {
      setState(() => _products = products);
    }
  }

  String _priceForProduct(String productId) {
    final product = _products.where((p) => p.id == productId).firstOrNull;
    return product?.price ?? '---';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPremiumUser = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.zanPremium),
      ),
      body: isPremiumUser
          ? _buildAlreadyPremium(context, l10n, theme)
          : _buildPaywall(context, l10n, theme),
    );
  }

  Widget _buildAlreadyPremium(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.premiumActive,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.premiumActiveDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywall(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero section
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.zanPremium,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.premiumDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Feature list
            _PremiumFeatureCard(
              icon: Icons.all_inclusive,
              title: l10n.premiumFeatureUnlimitedTitle,
              subtitle: l10n.premiumFeatureUnlimitedDesc,
            ),
            _PremiumFeatureCard(
              icon: Icons.smart_toy_outlined,
              title: l10n.premiumFeatureAiTitle,
              subtitle: l10n.premiumFeatureAiDesc,
            ),
            _PremiumFeatureCard(
              icon: Icons.currency_exchange,
              title: l10n.premiumFeatureMultiCurrencyTitle,
              subtitle: l10n.premiumFeatureMultiCurrencyDesc,
            ),
            _PremiumFeatureCard(
              icon: Icons.history,
              title: l10n.premiumFeatureFullHistoryTitle,
              subtitle: l10n.premiumFeatureFullHistoryDesc,
            ),
            _PremiumFeatureCard(
              icon: Icons.file_download_outlined,
              title: l10n.premiumFeatureExportTitle,
              subtitle: l10n.premiumFeatureExportDesc,
            ),
            const SizedBox(height: 24),
            // Plan selection
            _PlanCard(
              selected: _selectedProductId == PurchaseService.annualProductId,
              title: l10n.annualPlan,
              price: _priceForProduct(PurchaseService.annualProductId),
              perMonth: '',
              badge: l10n.bestValue,
              onTap: () => setState(() {
                _selectedProductId = PurchaseService.annualProductId;
              }),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              selected: _selectedProductId == PurchaseService.monthlyProductId,
              title: l10n.monthlyPlan,
              price: _priceForProduct(PurchaseService.monthlyProductId),
              perMonth: '',
              onTap: () => setState(() {
                _selectedProductId = PurchaseService.monthlyProductId;
              }),
            ),
            const SizedBox(height: 24),
            // Purchase button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _purchase,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.subscribe),
              ),
            ),
            const SizedBox(height: 12),
            // Restore purchases
            TextButton(
              onPressed: _isLoading ? null : _restorePurchases,
              child: Text(l10n.restorePurchases),
            ),
            const SizedBox(height: 8),
            // Legal links
            Text(
              l10n.subscriptionTerms,
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

  Future<void> _purchase() async {
    if (_selectedProductId == null) return;
    setState(() => _isLoading = true);

    final useCase = ref.read(purchaseSubscriptionUseCaseProvider);
    final result = await useCase.call(_selectedProductId!);

    if (mounted) {
      setState(() => _isLoading = false);
      result.when(
        success: (success) {
          if (success) {
            ref.invalidate(subscriptionProvider);
            ref.invalidate(usageQuotaProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).purchaseSuccess)),
            );
          }
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
      );
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    final useCase = ref.read(restorePurchasesUseCaseProvider);
    final result = await useCase.call();

    if (mounted) {
      setState(() => _isLoading = false);
      result.when(
        success: (restored) {
          if (restored) {
            ref.invalidate(subscriptionProvider);
            ref.invalidate(usageQuotaProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).restoreSuccess)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).noSubscriptionFound)),
            );
          }
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
      );
    }
  }
}

class _PremiumFeatureCard extends StatelessWidget {
  const _PremiumFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.perMonth,
    required this.onTap,
    this.badge,
  });

  final bool selected;
  final String title;
  final String price;
  final String perMonth;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    perMonth,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
