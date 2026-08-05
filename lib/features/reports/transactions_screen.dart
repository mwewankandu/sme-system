import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction.dart';
import 'reports_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsByDateProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          // Date range selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Date Range',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Start date
                    Expanded(
                      child: _DateButton(
                        label: 'From',
                        date: dateRange.start,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dateRange.start,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            ref.read(dateRangeProvider.notifier).state =
                                DateRange(
                              start: DateTime(picked.year, picked.month,
                                  picked.day, 0, 0, 0),
                              end: dateRange.end,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward,
                        color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 12),
                    // End date
                    Expanded(
                      child: _DateButton(
                        label: 'To',
                        date: dateRange.end,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dateRange.end,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            ref.read(dateRangeProvider.notifier).state =
                                DateRange(
                              start: dateRange.start,
                              end: DateTime(picked.year, picked.month,
                                  picked.day, 23, 59, 59),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Quick range buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _quickRange(context, ref, 'Today', () {
                        final now = DateTime.now();
                        return DateRange(
                          start: DateTime(
                              now.year, now.month, now.day, 0, 0, 0),
                          end: DateTime(
                              now.year, now.month, now.day, 23, 59, 59),
                        );
                      }),
                      _quickRange(context, ref, 'This Week', () {
                        final now = DateTime.now();
                        final weekStart = now
                            .subtract(Duration(days: now.weekday - 1));
                        return DateRange(
                          start: DateTime(weekStart.year,
                              weekStart.month, weekStart.day, 0, 0, 0),
                          end: DateTime(
                              now.year, now.month, now.day, 23, 59, 59),
                        );
                      }),
                      _quickRange(context, ref, 'This Month', () {
                        final now = DateTime.now();
                        return DateRange(
                          start: DateTime(now.year, now.month, 1, 0, 0, 0),
                          end: DateTime(
                              now.year, now.month, now.day, 23, 59, 59),
                        );
                      }),
                      _quickRange(context, ref, 'Last Month', () {
                        final now = DateTime.now();
                        final lastMonth =
                            DateTime(now.year, now.month - 1, 1);
                        final lastDay =
                            DateTime(now.year, now.month, 0);
                        return DateRange(
                          start: DateTime(lastMonth.year,
                              lastMonth.month, 1, 0, 0, 0),
                          end: DateTime(lastDay.year, lastDay.month,
                              lastDay.day, 23, 59, 59),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results
          transactionsAsync.when(
            loading: () =>
                const Expanded(
                    child: Center(child: CircularProgressIndicator())),
            error: (e, _) =>
                Expanded(child: Center(child: Text('Error: $e'))),
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 56, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('No transactions in this period',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              // Summary for the period
              final total = transactions.fold(
                  0.0, (sum, t) => sum + t.totalAmount);
              final cashTotal = transactions
                  .where(
                      (t) => t.paymentMethod == PaymentMethod.cash)
                  .fold(0.0, (sum, t) => sum + t.totalAmount);
              final creditTotal = transactions
                  .where(
                      (t) => t.paymentMethod == PaymentMethod.credit)
                  .fold(0.0, (sum, t) => sum + t.totalAmount);
              final mobileTotal = transactions
                  .where((t) =>
                      t.paymentMethod == PaymentMethod.mobileMoney)
                  .fold(0.0, (sum, t) => sum + t.totalAmount);

              return Expanded(
                child: Column(
                  children: [
                    // Period summary
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _stat('Transactions',
                                  '${transactions.length}',
                                  AppColors.primary),
                              _stat('Total Revenue',
                                  'ZMW ${total.toStringAsFixed(2)}',
                                  AppColors.secondary),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _miniStat('Cash',
                                  'ZMW ${cashTotal.toStringAsFixed(2)}',
                                  AppColors.secondary),
                              _miniStat('Credit',
                                  'ZMW ${creditTotal.toStringAsFixed(2)}',
                                  AppColors.danger),
                              _miniStat('Mobile',
                                  'ZMW ${mobileTotal.toStringAsFixed(2)}',
                                  AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Transaction list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 24),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          return _TransactionTile(transaction: t);
                        },
                      ),
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

  Widget _quickRange(BuildContext context, WidgetRef ref, String label,
      DateRange Function() rangeFn) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: () =>
            ref.read(dateRangeProvider.notifier).state = rangeFn(),
        style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: color)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.background,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary)),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final SaleTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final methodColor = switch (transaction.paymentMethod) {
      PaymentMethod.cash => AppColors.secondary,
      PaymentMethod.credit => AppColors.danger,
      PaymentMethod.mobileMoney => AppColors.primary,
    };

    final methodLabel = switch (transaction.paymentMethod) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.credit => 'Credit',
      PaymentMethod.mobileMoney => 'Mobile Money',
    };

    final date =
        '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}';
    final time =
        '${transaction.createdAt.hour.toString().padLeft(2, '0')}:${transaction.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$date at $time',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: methodColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(methodLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: methodColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Items
            ...transaction.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.productName} × ${item.quantity}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        'ZMW ${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'ZMW ${transaction.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}