import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/utils/currency_formatter.dart';
import 'package:zan/core/utils/transaction_type_helper.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/account_provider.dart';
import 'package:zan/presentation/providers/transaction_form_provider.dart';

class TransactionInputScreen extends ConsumerStatefulWidget {
  const TransactionInputScreen({super.key, this.transactionId});
  final String? transactionId;

  @override
  ConsumerState<TransactionInputScreen> createState() =>
      _TransactionInputScreenState();
}

class _TransactionInputScreenState extends ConsumerState<TransactionInputScreen>
    with SingleTickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  String _amountText = '0';
  late final TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final type = TransactionType.values[_tabController.index];
    ref.read(transactionFormNotifierProvider.notifier).setTransactionType(type);
  }

  Future<void> _loadExistingTransaction() async {
    if (widget.transactionId == null || _initialized) return;
    _initialized = true;

    final repo = ref.read(transactionRepositoryProvider);
    final result = await repo.getTransaction(widget.transactionId!);
    final accounts = await ref.read(accountListProvider.future);

    result.when(
      success: (transaction) {
        final notifier = ref.read(transactionFormNotifierProvider.notifier);
        notifier.loadFromTransaction(transaction, accounts);

        final formState = ref.read(transactionFormNotifierProvider);
        _amountText = formState.amount > 0 ? formState.amount.toString() : '0';
        _descriptionController.text = formState.description ?? '';
        _noteController.text = formState.note ?? '';

        if (mounted) {
          setState(() {});
          _tabController.animateTo(formState.transactionType.index);
        }
      },
      failure: (_) {},
    );
  }

  void _onKeypadTap(String key) {
    setState(() {
      if (key == 'C') {
        _amountText = '0';
      } else if (key == '⌫') {
        if (_amountText.length > 1) {
          _amountText = _amountText.substring(0, _amountText.length - 1);
        } else {
          _amountText = '0';
        }
      } else {
        if (_amountText == '0') {
          _amountText = key;
        } else {
          _amountText += key;
        }
      }
    });
    ref.read(transactionFormNotifierProvider.notifier).setAmount(
          int.tryParse(_amountText) ?? 0,
        );
  }

  Future<void> _selectAccountForField({required int field}) async {
    final formState = ref.read(transactionFormNotifierProvider);
    final config = formState.transactionType.accountFieldConfig;
    final allowedTypes =
        field == 1 ? config.field1AllowedTypes : config.field2AllowedTypes;

    final accounts = await ref.read(accountListProvider.future);
    final filtered =
        accounts.where((a) => allowedTypes.contains(a.type)).toList();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final title = field == 1
        ? formState.transactionType.field1Label(l10n)
        : formState.transactionType.field2Label(l10n);

    final selected = await showModalBottomSheet<Account>(
      context: context,
      builder: (context) => _AccountSelectorSheet(
        accounts: filtered,
        title: title,
      ),
    );

    if (selected != null) {
      final notifier = ref.read(transactionFormNotifierProvider.notifier);
      // Determine whether this field maps to debit or credit
      final isDebit =
          (field == 1 && config.field1IsDebit) ||
          (field == 2 && !config.field1IsDebit);
      if (isDebit) {
        notifier.setDebitAccount(selected.id);
      } else {
        notifier.setCreditAccount(selected.id);
      }
    }
  }

  Future<void> _selectDate() async {
    final formState = ref.read(transactionFormNotifierProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ref.read(transactionFormNotifierProvider.notifier).setDate(picked);
    }
  }

  Future<void> _save() async {
    final notifier = ref.read(transactionFormNotifierProvider.notifier);
    notifier.setDescription(
      _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );
    notifier.setNote(
      _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
    );

    final success = await notifier.save(existingId: widget.transactionId);
    if (success && mounted) {
      context.pop(true);
    }
  }

  /// Resolve the account ID displayed in a field, considering the mapping direction.
  String? _accountIdForField(TransactionFormState formState, int field) {
    final config = formState.transactionType.accountFieldConfig;
    final isDebit =
        (field == 1 && config.field1IsDebit) ||
        (field == 2 && !config.field1IsDebit);
    return isDebit ? formState.debitAccountId : formState.creditAccountId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(transactionFormNotifierProvider);
    final accountsAsync = ref.watch(accountListProvider);

    // Load existing transaction on first build
    if (widget.transactionId != null && !_initialized) {
      _loadExistingTransaction();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newTransaction),
        actions: [
          TextButton(
            onPressed: formState.isValid && !formState.isLoading ? _save : null,
            child: Text(l10n.save),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: TransactionType.values
              .map((t) => Tab(text: t.label(l10n)))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          // Amount display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Text(
              CurrencyFormatter.format(int.tryParse(_amountText) ?? 0),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Account selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _AccountButton(
                    label: formState.transactionType.field1Label(l10n),
                    accountId: _accountIdForField(formState, 1),
                    accounts: accountsAsync.valueOrNull ?? [],
                    onTap: () => _selectAccountForField(field: 1),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: _AccountButton(
                    label: formState.transactionType.field2Label(l10n),
                    accountId: _accountIdForField(formState, 2),
                    accounts: accountsAsync.valueOrNull ?? [],
                    onTap: () => _selectAccountForField(field: 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Date selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                formState.date != null
                    ? '${formState.date!.year}/${formState.date!.month}/${formState.date!.day}'
                    : l10n.date,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: l10n.description,
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const Spacer(),
          // Error
          if (formState.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                formState.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          // Numpad
          _NumericKeypad(onTap: _onKeypadTap),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({
    required this.label,
    required this.accountId,
    required this.accounts,
    required this.onTap,
  });

  final String label;
  final String? accountId;
  final List<Account> accounts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final account = accountId != null
        ? accounts.where((a) => a.id == accountId).firstOrNull
        : null;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            account?.name ?? '---',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AccountSelectorSheet extends StatelessWidget {
  const _AccountSelectorSheet({
    required this.accounts,
    required this.title,
  });

  final List<Account> accounts;
  final String title;

  @override
  Widget build(BuildContext context) {
    final grouped = <AccountType, List<Account>>{};
    for (final account in accounts) {
      grouped.putIfAbsent(account.type, () => []).add(account);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: grouped.entries.expand((entry) {
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        entry.key.name.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                    ...entry.value.map(
                      (account) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            int.parse(
                                account.color.replaceFirst('#', '0xFF')),
                          ),
                          radius: 16,
                          child: const Icon(Icons.account_balance_wallet,
                              size: 16, color: Colors.white),
                        ),
                        title: Text(account.name),
                        onTap: () => Navigator.pop(context, account),
                      ),
                    ),
                  ];
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['C', '0', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextButton(
                    onPressed: () => onTap(key),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      key,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
