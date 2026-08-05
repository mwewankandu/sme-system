import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product.dart';
import 'restock_dialog.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: product.isLowStock ? AppColors.lowStock : AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: product.isLowStock
            ? const BorderSide(color: AppColors.lowStockBorder, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category icon
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                product.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _badge(
                        'ZMW ${product.price.toStringAsFixed(2)}',
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _badge(
                        'Stock: ${product.stockQuantity}',
                        product.isLowStock
                            ? AppColors.lowStockBorder.withOpacity(0.2)
                            : AppColors.secondary.withOpacity(0.1),
                        product.isLowStock
                            ? AppColors.warning
                            : AppColors.secondary,
                      ),
                      if (product.isLowStock) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.warning_amber_rounded,
                            size: 16, color: AppColors.warning),
                        const Text(
                          ' Low Stock',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.secondary, size: 20),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => RestockDialog(product: product),
                  ),
                  tooltip: 'Restock',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}