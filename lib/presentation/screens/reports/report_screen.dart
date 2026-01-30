import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zan/core/utils/currency_formatter.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/report_provider.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthlyReportProvider);
    final breakdownAsync = ref.watch(categoryBreakdownProvider);
    final prevSummaryAsync = ref.watch(previousMonthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.monthlyReport),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month selector
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(selectedMonthProvider.notifier).state = DateTime(
                        selectedMonth.year,
                        selectedMonth.month - 1,
                      );
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${selectedMonth.year}/${selectedMonth.month.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(selectedMonthProvider.notifier).state = DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                      );
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary
          summaryAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (summary) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: l10n.monthlyIncome,
                            amount: summary.totalIncome,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _SummaryItem(
                            label: l10n.monthlyExpense,
                            amount: summary.totalExpense,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _SummaryItem(
                      label: 'Net',
                      amount: summary.netIncome,
                      color: summary.netIncome >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Previous month comparison
          prevSummaryAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (prevSummary) {
              final currentSummary = summaryAsync.valueOrNull;
              if (currentSummary == null) return const SizedBox.shrink();
              final expenseDiff = currentSummary.totalExpense - prevSummary.totalExpense;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        expenseDiff > 0 ? Icons.trending_up : Icons.trending_down,
                        color: expenseDiff > 0 ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${l10n.comparedToLastMonth}: ${expenseDiff > 0 ? '+' : ''}${CurrencyFormatter.format(expenseDiff)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Pie chart
          breakdownAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (breakdown) {
              if (breakdown.isEmpty) return const SizedBox.shrink();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoryBreakdown,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieSections(breakdown, context),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...breakdown.entries.map((entry) {
                        final total = breakdown.values.fold<int>(0, (a, b) => a + b);
                        final percentage = total > 0
                            ? (entry.value / total * 100).toStringAsFixed(1)
                            : '0';
                        return ListTile(
                          dense: true,
                          title: Text(entry.key),
                          trailing: Text(
                            '${CurrencyFormatter.format(entry.value)} ($percentage%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, int> breakdown,
    BuildContext context,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    final total = breakdown.values.fold<int>(0, (a, b) => a + b);
    var i = 0;
    return breakdown.entries.map((entry) {
      final percentage = total > 0 ? entry.value / total * 100 : 0.0;
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
