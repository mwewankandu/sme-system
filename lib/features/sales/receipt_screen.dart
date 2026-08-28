import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction.dart';
import '../../models/customer.dart';
import '../customers/customer_provider.dart';

class ReceiptScreen extends ConsumerWidget {
  final SaleTransaction transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);

    // Find customer name if credit sale
    Customer? customer;
    if (transaction.customerId != null) {
      customersAsync.whenData((customers) {
        customer = customers.firstWhere(
          (c) => c.id == transaction.customerId,
          orElse: () => Customer(
            id: '',
            name: 'Unknown',
            phone: '',
            createdAt: DateTime.now(),
          ),
        );
      });
    }

    final date = transaction.createdAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final methodLabel = switch (transaction.paymentMethod) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.credit => 'Credit',
      PaymentMethod.mobileMoney => 'Mobile Money',
    };

    final methodColor = switch (transaction.paymentMethod) {
      PaymentMethod.cash => AppColors.secondary,
      PaymentMethod.credit => AppColors.danger,
      PaymentMethod.mobileMoney => AppColors.primary,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receipt'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.white, size: 56),
                  SizedBox(height: 12),
                  Text(
                    'Sale Complete!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Transaction recorded successfully',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Receipt card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Receipt header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.store_outlined,
                            color: AppColors.primary, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'SME Business System',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dateStr  $timeStr',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ref: ${transaction.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Divider with dots
                  _DottedDivider(),

                  // Items
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Column headers
                        const Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text('Item',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppColors.textSecondary,
                                      fontWeight:
                                          FontWeight.w600)),
                            ),
                            Text('Qty',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Text('Amount',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppColors.textSecondary,
                                      fontWeight:
                                          FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Item rows
                        ...transaction.items.map((item) =>
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color:
                                              AppColors.textPrimary,
                                          fontWeight:
                                              FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    '×${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color:
                                            AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ZMW ${item.subtotal.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color:
                                              AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  _DottedDivider(),

                  // Total section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                )),
                            Text(
                              'ZMW ${transaction.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Payment method
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Method',
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        AppColors.textSecondary)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    methodColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                methodLabel,
                                style: TextStyle(
                                  color: methodColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Customer name for credit sales
                        if (transaction.customerId != null) ...[
                          const SizedBox(height: 8),
                          customersAsync.when(
                            loading: () =>
                                const SizedBox.shrink(),
                            error: (_, __) =>
                                const SizedBox.shrink(),
                            data: (customers) {
                              final c = customers.firstWhere(
                                (c) =>
                                    c.id ==
                                    transaction.customerId,
                                orElse: () => Customer(
                                  id: '',
                                  name: 'Unknown',
                                  phone: '',
                                  createdAt: DateTime.now(),
                                ),
                              );
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Customer',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors
                                              .textSecondary)),
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Thank you for your business!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Done button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Done',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Dotted divider widget
class _DottedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount =
            (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: 4,
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
        );
      },
    );
  }
}