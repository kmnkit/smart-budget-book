import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/extensions/enum_l10n_extensions.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/account_provider.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';
import 'package:zan/presentation/widgets/paywall_bottom_sheet.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.accountId});
  final String? accountId;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _noteController = TextEditingController();

  AccountType _selectedType = AccountType.asset;
  AccountCategory _selectedCategory = AccountCategory.cash;
  String _selectedColor = '#6366F1';
  String _selectedIcon = 'wallet';
  bool _isLoading = false;

  bool get isEditing => widget.accountId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadAccount();
    }
  }

  Future<void> _loadAccount() async {
    final result = await ref
        .read(accountRepositoryProvider)
        .getAccount(widget.accountId!);
    result.when(
      success: (account) {
        _nameController.text = account.name;
        _initialBalanceController.text = account.initialBalance.toString();
        _noteController.text = account.note ?? '';
        setState(() {
          _selectedType = account.type;
          _selectedCategory = account.category;
          _selectedColor = account.color;
          _selectedIcon = account.icon;
        });
      },
      failure: (_) {},
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Check account quota for new accounts
    if (!isEditing) {
      final access = ref.read(featureAccessProvider(FeatureType.createAccount));
      if (!access.allowed) {
        await PaywallBottomSheet.show(
          context,
          reason: access.reason,
          remaining: access.remaining,
          limit: access.limit,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final userId = ref.read(currentUserIdProvider) ?? '';
    final now = DateTime.now();
    final account = Account(
      id: widget.accountId ?? '',
      userId: userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      icon: _selectedIcon,
      color: _selectedColor,
      initialBalance: int.tryParse(_initialBalanceController.text) ?? 0,
      currency: 'JPY',
      displayOrder: 0,
      isArchived: false,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      createdAt: now,
      updatedAt: now,
    );

    final repo = ref.read(accountRepositoryProvider);
    final result = isEditing
        ? await repo.updateAccount(account)
        : await repo.createAccount(account);

    setState(() => _isLoading = false);

    if (!mounted) return;
    result.when(
      success: (_) {
        ref.invalidate(accountListProvider);
        ref.invalidate(allAccountListProvider);
        context.pop();
      },
      failure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
    );
  }

  Future<void> _archive() async {
    if (widget.accountId == null) return;
    setState(() => _isLoading = true);
    await ref.read(accountRepositoryProvider).archiveAccount(widget.accountId!);
    setState(() => _isLoading = false);
    if (!mounted) return;
    ref.invalidate(accountListProvider);
    ref.invalidate(allAccountListProvider);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editAccount : l10n.addAccount),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _isLoading ? null : _archive,
              icon: const Icon(Icons.archive_outlined),
              tooltip: l10n.archive,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.accountName),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              initialValue: _selectedType,
              decoration: InputDecoration(labelText: l10n.accountType),
              items: AccountType.values
                  .where((t) => t != AccountType.equity)
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label(l10n))))
                  .toList(),
              onChanged: isEditing
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() {
                          _selectedType = v;
                          _selectedCategory = AccountCategory.values
                              .firstWhere((c) => c.accountType == v);
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountCategory>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(labelText: l10n.category),
              items: AccountCategory.values
                  .where((c) => c.accountType == _selectedType)
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label(l10n))))
                  .toList(),
              onChanged: isEditing
                  ? null
                  : (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialBalanceController,
              decoration: InputDecoration(
                labelText: _selectedType == AccountType.liability
                    ? l10n.outstandingBalance
                    : l10n.initialBalance,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: l10n.note),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
