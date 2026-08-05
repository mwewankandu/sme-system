import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'reports_provider.dart';

class BestSellersScreen extends ConsumerWidget {
  const BestSellersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestSellersAsync = ref.watch(bestSellingProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Selling Products'),
      ),
      body: bestSellersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No sales data yet',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('Record some sales to see best sellers',
                      style:
                          TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // Max quantity for bar scaling
          final maxQty = products.first.totalQuantitySold;
          final totalRevenue = products.fold(
              0.0, (sum, p) => sum + p.totalRevenue);
          final totalQty = products.fold(
              0, (sum, p) => sum + p.totalQuantitySold);

          return Column(
            children: [
              // Summary
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _stat('Products Sold',
                        '${products.length} types', AppColors.primary),
                    const SizedBox(width: 24),
                    _stat('Total Units', '$totalQty units',
                        AppColors.secondary),
                    const SizedBox(width: 24),
                    _stat('Total Revenue',
                        'ZMW ${totalRevenue.toStringAsFixed(2)}',
                        AppColors.textPrimary),
                  ],
                ),
              ),
              const Divider(height: 1),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final percent =
                        product.totalQuantitySold / maxQty;

                    // Medal colors for top 3
                    final Color rankColor = switch (index) {
                      0 => const Color(0xFFFFD700), // Gold
                      1 => const Color(0xFFC0C0C0), // Silver
                      2 => const Color(0xFFCD7F32), // Bronze
                      _ => AppColors.textSecondary,
                    };

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Rank badge
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color:
                                        rankColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: rankColor == AppColors.textSecondary
                                            ? AppColors.textSecondary
                                            : rankColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'ZMW ${product.totalRevenue.toStringAsFixed(2)} revenue',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Units sold badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${product.totalQuantitySold}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Text(
                                        'units',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 8,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.08),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  index == 0
                                      ? const Color(0xFFFFD700)
                                      : index == 1
                                          ? const Color(0xFFC0C0C0)
                                          : index == 2
                                              ? const Color(0xFFCD7F32)
                                              : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(percent * 100).toStringAsFixed(1)}% of top seller',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}