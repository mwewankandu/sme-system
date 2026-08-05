import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'reports_provider.dart';

class DailySalesScreen extends ConsumerWidget {
  const DailySalesScreen({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _dayOfWeek(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailySalesAsync = ref.watch(dailySalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Sales History'),
      ),
      body: dailySalesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (days) {
          if (days.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No sales history yet',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // Overall stats
          final totalRevenue =
              days.fold(0.0, (sum, d) => sum + d.totalRevenue);
          final totalTransactions =
              days.fold(0, (sum, d) => sum + d.transactionCount);
          final avgDaily = totalRevenue / days.length;
          final bestDay = days.reduce(
              (a, b) => a.totalRevenue > b.totalRevenue ? a : b);

          return Column(
            children: [
              // Overall summary
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            'Total Days',
                            '${days.length} days',
                            Icons.calendar_month_outlined,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            'Total Revenue',
                            'ZMW ${totalRevenue.toStringAsFixed(2)}',
                            Icons.payments_outlined,
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            'Daily Average',
                            'ZMW ${avgDaily.toStringAsFixed(2)}',
                            Icons.trending_up_outlined,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            'Total Transactions',
                            '$totalTransactions sales',
                            Icons.receipt_outlined,
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Best day highlight
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.secondary,
                            Color(0xFF15803D)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Best Day',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11),
                                ),
                                Text(
                                  _formatDate(bestDay.date),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'ZMW ${bestDay.totalRevenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Daily list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isBestDay =
                        day.date == bestDay.date;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isBestDay
                            ? const BorderSide(
                                color: AppColors.secondary,
                                width: 1.5)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _formatDate(day.date),
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 15,
                                            color:
                                                AppColors.textPrimary,
                                          ),
                                        ),
                                        if (isBestDay) ...[
                                          const SizedBox(width: 6),
                                          const Text('🏆',
                                              style: TextStyle(
                                                  fontSize: 14)),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      _dayOfWeek(day.date),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'ZMW ${day.totalRevenue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${day.transactionCount} transaction${day.transactionCount != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Payment breakdown
                            Row(
                              children: [
                                if (day.cashRevenue > 0)
                                  _paymentChip(
                                    'Cash: ZMW ${day.cashRevenue.toStringAsFixed(2)}',
                                    AppColors.secondary,
                                  ),
                                if (day.mobileMoneyRevenue > 0)
                                  _paymentChip(
                                    'Mobile: ZMW ${day.mobileMoneyRevenue.toStringAsFixed(2)}',
                                    AppColors.primary,
                                  ),
                                if (day.creditRevenue > 0)
                                  _paymentChip(
                                    'Credit: ZMW ${day.creditRevenue.toStringAsFixed(2)}',
                                    AppColors.danger,
                                  ),
                              ],
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

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary)),
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}