import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction.dart';
import '../inventory/inventory_provider.dart';
import '../customers/customer_provider.dart';
import 'sales_provider.dart';
import 'widgets/cart_item_tile.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  String? _selectedCustomerId;
  bool _isProcessing = false;

  Future<void> _recordSale() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product to the cart')),
      );
      return;
    }
    if (_paymentMethod == PaymentMethod.credit &&
        _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select a customer for credit sales')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await ref.read(salesNotifierProvider.notifier).recordSale(
            items: cart,
            paymentMethod: _paymentMethod,
            customerId: _selectedCustomerId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale recorded successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        setState(() {
          _paymentMethod = PaymentMethod.cash;
          _selectedCustomerId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: cartNotifier.clear,
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text('Clear',
                  style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Column(
        children: [
          // Product picker
          Container(
            height: 120,
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: productsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (products) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final outOfStock = product.stockQuantity <= 0;
                  return GestureDetector(
                    onTap: outOfStock
                        ? null
                        : () => cartNotifier.addItem(CartItem(
                              productId: product.id,
                              productName: product.name,
                              unitPrice: product.price,
                            )),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: outOfStock
                            ? Colors.grey.shade100
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: outOfStock
                              ? Colors.grey.shade300
                              : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: outOfStock
                                  ? Colors.grey
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ZMW ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: outOfStock
                                  ? Colors.grey
                                  : AppColors.primary,
                            ),
                          ),
                          if (outOfStock)
                            const Text('Out of stock',
                                style: TextStyle(
                                    fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),

          // Cart items
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text('Tap a product above to add it to the sale',
                        style:
                            TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (_, i) => CartItemTile(item: cart[i]),
                  ),
          ),

          // Bottom panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Payment method
                Row(
                  children: [
                    const Text('Payment:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    ...PaymentMethod.values.map((method) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_methodLabel(method)),
                            selected: _paymentMethod == method,
                            onSelected: (_) =>
                                setState(() => _paymentMethod = method),
                            selectedColor:
                                AppColors.primary.withOpacity(0.2),
                          ),
                        )),
                  ],
                ),

                // Customer selector (credit only)
                if (_paymentMethod == PaymentMethod.credit) ...[
                  const SizedBox(height: 8),
                  customersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (customers) => DropdownButtonFormField<String>(
                      initialValue: _selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Select Customer',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: customers
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCustomerId = val),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Total + confirm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                        Text(
                          'ZMW ${cartNotifier.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: _isProcessing ? null : _recordSale,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm Sale'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.credit:
        return 'Credit';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
    }
  }
}