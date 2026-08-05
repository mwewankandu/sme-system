import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product.dart';
import '../inventory_provider.dart';

class RestockDialog extends ConsumerStatefulWidget {
  final Product product;

  const RestockDialog({super.key, required this.product});

  @override
  ConsumerState<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends ConsumerState<RestockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restock() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(inventoryNotifierProvider.notifier).restockProduct(
            widget.product.id,
            int.parse(_controller.text.trim()),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Restock — ${widget.product.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current stock info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.product.isLowStock
                    ? AppColors.lowStock
                    : AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.product.isLowStock
                      ? AppColors.lowStockBorder
                      : AppColors.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.product.isLowStock
                        ? Icons.warning_amber_rounded
                        : Icons.inventory_2_outlined,
                    color: widget.product.isLowStock
                        ? AppColors.warning
                        : AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current stock: ${widget.product.stockQuantity} units',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.product.isLowStock
                          ? AppColors.warning
                          : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick add buttons
            const Text('Quick Add:',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [5, 10, 20, 50].map((qty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () =>
                        _controller.text = qty.toString(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: Text('+$qty'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Manual input
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Quantity to Add',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter a quantity';
                }
                final qty = int.tryParse(v.trim());
                if (qty == null || qty <= 0) {
                  return 'Enter a valid quantity';
                }
                return null;
              },
            ),

            // New total preview
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) {
                final qty = int.tryParse(value.text.trim()) ?? 0;
                if (qty <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'New total: ${widget.product.stockQuantity + qty} units',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _restock,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary),
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Restock'),
        ),
      ],
    );
  }
}