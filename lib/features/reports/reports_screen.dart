import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'reports_provider.dart';
import 'widgets/summary_card.dart';
import 'widgets/recent_transactions.dart';
import 'best_sellers_screen.dart';
import 'daily_sales_screen.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Dashboard'),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's highlight
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Revenue",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ZMW ${summary.todayRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${summary.todayTransactions} transaction${summary.todayTransactions != 1 ? 's' : ''} today',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Revenue cards
              const Text('Revenue Overview',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'This Week',
                      value:
                          'ZMW ${summary.weekRevenue.toStringAsFixed(2)}',
                      icon: Icons.calendar_view_week_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'This Month',
                      value:
                          'ZMW ${summary.monthRevenue.toStringAsFixed(2)}',
                      icon: Icons.calendar_month_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Business stats
              const Text('Business Overview',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  SummaryCard(
                    label: 'Total Products',
                    value: '${summary.totalProducts}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    subtitle: '${summary.lowStockCount} low stock',
                  ),
                  SummaryCard(
                    label: 'Total Customers',
                    value: '${summary.totalCustomers}',
                    icon: Icons.people_outline,
                    color: AppColors.secondary,
                  ),
                  SummaryCard(
                    label: 'Credit Owed',
                    value:
                        'ZMW ${summary.totalCreditOwed.toStringAsFixed(2)}',
                    icon: Icons.credit_card_outlined,
                    color: AppColors.danger,
                    subtitle: 'Across all customers',
                  ),
                  SummaryCard(
                    label: 'Mobile Money',
                    value:
                        'ZMW ${(summary.revenueByPaymentMethod['mobileMoney'] ?? 0).toStringAsFixed(2)}',
                    icon: Icons.phone_android_outlined,
                    color: AppColors.warning,
                    subtitle: 'This month',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payment breakdown
              const Text('This Month by Payment Method',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _paymentBar(
                        'Cash',
                        summary.revenueByPaymentMethod['cash'] ?? 0,
                        summary.monthRevenue,
                        AppColors.secondary,
                      ),
                      const SizedBox(height: 12),
                      _paymentBar(
                        'Mobile Money',
                        summary.revenueByPaymentMethod['mobileMoney'] ?? 0,
                        summary.monthRevenue,
                        AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _paymentBar(
                        'Credit',
                        summary.revenueByPaymentMethod['credit'] ?? 0,
                        summary.monthRevenue,
                        AppColors.danger,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Best sellers shortcut
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('Best Selling Products',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary)),
    TextButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const BestSellersScreen(),
        ),
      ),
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: const Text('See All'),
    ),
  ],
),
const SizedBox(height: 8),

// Top 3 preview
...() {
  final bestAsync = ref.watch(bestSellingProductsProvider);
  return bestAsync.when(
    loading: () => [const LinearProgressIndicator()],
    error: (e, _) => [],
    data: (products) {
      final top3 = products.take(3).toList();
      if (top3.isEmpty) {
        return [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No sales data yet',
                    style:
                        TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          )
        ];
      }
      return top3.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;
        final medals = ['🥇', '🥈', '🥉'];
        return Card(
          child: ListTile(
            leading: Text(medals[index],
                style: const TextStyle(fontSize: 24)),
            title: Text(product.productName,
                style:
                    const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                'ZMW ${product.totalRevenue.toStringAsFixed(2)} revenue'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${product.totalQuantitySold} units',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ),
        );
      }).toList();
    },
  );
}(),

const SizedBox(height: 16),

              // Recent transactions
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('Recent Transactions',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary)),
    TextButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DailySalesScreen(),
        ),
      ),
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: const Text('Daily History'),
    ),
  ],
),
              const Text('Recent Transactions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Card(
                child: RecentTransactionsList(
                  transactions: summary.recentTransactions,
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentBar(
      String label, double amount, double total, Color color) {
    final percent = total > 0 ? (amount / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            Text(
              'ZMW ${amount.toStringAsFixed(2)} (${(percent * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}