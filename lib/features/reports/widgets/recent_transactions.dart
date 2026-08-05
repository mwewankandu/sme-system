import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/transaction.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<SaleTransaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('No transactions yet',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Column(
      children: transactions.map((t) => _TransactionTile(t)).toList(),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final SaleTransaction transaction;

  const _TransactionTile(this.transaction);

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

    final time =
        '${transaction.createdAt.hour.toString().padLeft(2, '0')}:${transaction.createdAt.minute.toString().padLeft(2, '0')}';
    final date =
        '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: methodColor.withOpacity(0.1),
            radius: 20,
            child: Icon(
              transaction.paymentMethod == PaymentMethod.cash
                  ? Icons.payments_outlined
                  : transaction.paymentMethod == PaymentMethod.credit
                      ? Icons.credit_card_outlined
                      : Icons.phone_android_outlined,
              color: methodColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.items.length} item${transaction.items.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                Text(
                  '$date at $time',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ZMW ${transaction.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  methodLabel,
                  style: TextStyle(
                      fontSize: 10,
                      color: methodColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}