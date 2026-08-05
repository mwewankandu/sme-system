import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../sales/sales_provider.dart';

class CreditHistoryScreen extends ConsumerWidget {
  final Customer customer;

  const CreditHistoryScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync =
        ref.watch(customerTransactionsProvider(customer.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _headerStat(
                  'Outstanding Balance',
                  'ZMW ${customer.creditBalance.toStringAsFixed(2)}',
                  AppColors.lowStock,
                  AppColors.warning,
                ),
                const SizedBox(width: 24),
                _headerStat(
                  'Phone',
                  customer.phone,
                  Colors.white.withOpacity(0.15),
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              const Text('Failed to load history'),
              const SizedBox(height: 8),
              Text(
                e.toString().contains('index')
                    ? 'Please create the Firestore index.\nCheck the terminal for the link.'
                    : e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No credit purchases yet',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // Calculate totals
          final totalPurchased = transactions.fold(
              0.0, (sum, t) => sum + t.totalAmount);

          return Column(
            children: [
              // Summary
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _stat('Credit Purchases',
                        '${transactions.length}', AppColors.primary),
                    const SizedBox(width: 24),
                    _stat('Total Purchased',
                        'ZMW ${totalPurchased.toStringAsFixed(2)}',
                        AppColors.textPrimary),
                    const SizedBox(width: 24),
                    _stat('Still Owes',
                        'ZMW ${customer.creditBalance.toStringAsFixed(2)}',
                        AppColors.danger),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Transaction list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _TransactionCard(transaction: transaction);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerStat(
      String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.8))),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
        ],
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final SaleTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final date =
        '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}';
    final time =
        '${transaction.createdAt.hour.toString().padLeft(2, '0')}:${transaction.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.credit_card_outlined,
                        size: 16, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Text(
                      'Credit Purchase',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$date at $time',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(height: 16),

            // Items
            ...transaction.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} × ${item.quantity}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary),
                        ),
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

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'ZMW ${transaction.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}