import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../inventory/inventory_provider.dart';
import '../sales/sales_provider.dart';
import '../customers/customer_provider.dart';
import '../../models/transaction.dart';

// Summary data class
class DashboardSummary {
  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int todayTransactions;
  final int lowStockCount;
  final int totalProducts;
  final int totalCustomers;
  final double totalCreditOwed;
  final List<SaleTransaction> recentTransactions;
  final Map<String, double> revenueByPaymentMethod;

  DashboardSummary({
    required this.todayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.todayTransactions,
    required this.lowStockCount,
    required this.totalProducts,
    required this.totalCustomers,
    required this.totalCreditOwed,
    required this.recentTransactions,
    required this.revenueByPaymentMethod,
  });
}

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final productsAsync = ref.watch(productsStreamProvider);
  final customersAsync = ref.watch(customersStreamProvider);

  if (transactionsAsync.isLoading ||
      productsAsync.isLoading ||
      customersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (transactionsAsync.hasError) {
    return AsyncValue.error(
        transactionsAsync.error!, transactionsAsync.stackTrace!);
  }

  final transactions = transactionsAsync.value ?? [];
  final products = productsAsync.value ?? [];
  final customers = customersAsync.value ?? [];

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);

  final todayTx =
      transactions.where((t) => t.createdAt.isAfter(todayStart)).toList();
  final weekTx =
      transactions.where((t) => t.createdAt.isAfter(weekStart)).toList();
  final monthTx =
      transactions.where((t) => t.createdAt.isAfter(monthStart)).toList();

  // Revenue by payment method
  final Map<String, double> byMethod = {
    'cash': 0,
    'credit': 0,
    'mobileMoney': 0,
  };
  for (final t in monthTx) {
    byMethod[t.paymentMethod.name] =
        (byMethod[t.paymentMethod.name] ?? 0) + t.totalAmount;
  }

  return AsyncValue.data(DashboardSummary(
    todayRevenue:
        todayTx.fold(0.0, (sum, t) => sum + t.totalAmount),
    weekRevenue:
        weekTx.fold(0.0, (sum, t) => sum + t.totalAmount),
    monthRevenue:
        monthTx.fold(0.0, (sum, t) => sum + t.totalAmount),
    todayTransactions: todayTx.length,
    lowStockCount: products.where((p) => p.isLowStock).length,
    totalProducts: products.length,
    totalCustomers: customers.length,
    totalCreditOwed:
        customers.fold(0.0, (sum, c) => sum + c.creditBalance),
    recentTransactions: transactions.take(10).toList(),
    revenueByPaymentMethod: byMethod,
  ));
});
// Date range state
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

final dateRangeProvider = StateProvider<DateRange>((ref) {
  final now = DateTime.now();
  return DateRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
  );
});

// Filtered transactions based on selected date range
final filteredTransactionsProvider =
    Provider<AsyncValue<List<SaleTransaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return transactionsAsync.whenData((transactions) {
    return transactions.where((t) {
      return t.createdAt.isAfter(
              dateRange.start.subtract(const Duration(seconds: 1))) &&
          t.createdAt.isAfter(dateRange.start) == false
              ? false
              : t.createdAt
                  .isBefore(dateRange.end.add(const Duration(seconds: 1)));
    }).toList();
  });
});

// Cleaner filtered provider
final transactionsByDateProvider =
    Provider<AsyncValue<List<SaleTransaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return transactionsAsync.whenData((transactions) {
    return transactions.where((t) {
      final afterStart = t.createdAt.isAfter(
          dateRange.start.subtract(const Duration(seconds: 1)));
      final beforeEnd = t.createdAt
          .isBefore(dateRange.end.add(const Duration(seconds: 1)));
      return afterStart && beforeEnd;
    }).toList();
  });
});
class BestSellingProduct {
  final String productId;
  final String productName;
  final int totalQuantitySold;
  final double totalRevenue;

  BestSellingProduct({
    required this.productId,
    required this.productName,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });
}

final bestSellingProductsProvider =
    Provider<AsyncValue<List<BestSellingProduct>>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);

  return transactionsAsync.whenData((transactions) {
    final Map<String, BestSellingProduct> productMap = {};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        if (productMap.containsKey(item.productId)) {
          final existing = productMap[item.productId]!;
          productMap[item.productId] = BestSellingProduct(
            productId: item.productId,
            productName: item.productName,
            totalQuantitySold:
                existing.totalQuantitySold + item.quantity,
            totalRevenue: existing.totalRevenue + item.subtotal,
          );
        } else {
          productMap[item.productId] = BestSellingProduct(
            productId: item.productId,
            productName: item.productName,
            totalQuantitySold: item.quantity,
            totalRevenue: item.subtotal,
          );
        }
      }
    }

    final sorted = productMap.values.toList()
      ..sort((a, b) =>
          b.totalQuantitySold.compareTo(a.totalQuantitySold));

    return sorted;
  });
});
class DailySales {
  final DateTime date;
  final double totalRevenue;
  final int transactionCount;
  final double cashRevenue;
  final double creditRevenue;
  final double mobileMoneyRevenue;

  DailySales({
    required this.date,
    required this.totalRevenue,
    required this.transactionCount,
    required this.cashRevenue,
    required this.creditRevenue,
    required this.mobileMoneyRevenue,
  });
}

final dailySalesProvider =
    Provider<AsyncValue<List<DailySales>>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);

  return transactionsAsync.whenData((transactions) {
    final Map<String, DailySales> dailyMap = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day,
      );
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final existing = dailyMap[key];
      dailyMap[key] = DailySales(
        date: date,
        totalRevenue:
            (existing?.totalRevenue ?? 0) + transaction.totalAmount,
        transactionCount: (existing?.transactionCount ?? 0) + 1,
        cashRevenue: (existing?.cashRevenue ?? 0) +
            (transaction.paymentMethod == PaymentMethod.cash
                ? transaction.totalAmount
                : 0),
        creditRevenue: (existing?.creditRevenue ?? 0) +
            (transaction.paymentMethod == PaymentMethod.credit
                ? transaction.totalAmount
                : 0),
        mobileMoneyRevenue: (existing?.mobileMoneyRevenue ?? 0) +
            (transaction.paymentMethod == PaymentMethod.mobileMoney
                ? transaction.totalAmount
                : 0),
      );
    }

    final sorted = dailyMap.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted;
  });
});