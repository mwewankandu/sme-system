import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../features/inventory/inventory_provider.dart';
import 'notification_service.dart';

// Tracks which products we've already notified about
// so we don't spam notifications on every rebuild
final _notifiedProductsProvider =
    StateProvider<Set<String>>((ref) => {});

final lowStockMonitorProvider = Provider<void>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);

  productsAsync.whenData((products) {
    final lowStockProducts =
        products.where((p) => p.isLowStock).toList();

    if (lowStockProducts.isEmpty) return;

    final notified = ref.read(_notifiedProductsProvider);
    final newLowStock = lowStockProducts
        .where((p) => !notified.contains(p.id))
        .toList();

    if (newLowStock.isEmpty) return;

    // Update notified set
    ref.read(_notifiedProductsProvider.notifier).state = {
      ...notified,
      ...newLowStock.map((p) => p.id),
    };

    final service = NotificationService();

    if (newLowStock.length == 1) {
      final product = newLowStock.first;
      service.showLowStockNotification(
        productName: product.name,
        currentStock: product.stockQuantity,
        threshold: product.lowStockThreshold,
      );
    } else {
      service.showMultipleLowStockNotification(
          newLowStock.length);
    }
  });
});