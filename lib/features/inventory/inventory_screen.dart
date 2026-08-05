import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'inventory_provider.dart';
import 'widgets/product_card.dart';
import 'widgets/product_form_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'inventory_fab',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ProductFormDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          // Build category list dynamically from products
          final categories = [
            'All',
            ...{...products.map((p) => p.category)}.toList()..sort(),
          ];

          // Apply category filter
          final categoryFiltered = _selectedCategory == 'All'
              ? products
              : products
                  .where((p) => p.category == _selectedCategory)
                  .toList();

          // Apply search filter on top of category filter
          final filtered = _searchQuery.isEmpty
              ? categoryFiltered
              : categoryFiltered
                  .where((p) =>
                      p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      p.category
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();

          final lowStockCount =
              products.where((p) => p.isLowStock).length;

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search products or categories...',
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    // Category filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              _selectedCategory == category;
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) => setState(
                                () => _selectedCategory = category),
                            selectedColor:
                                AppColors.primary.withOpacity(0.15),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Stats bar
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          _stat('Total Products', '${products.length}',
                              AppColors.primary),
                          const SizedBox(width: 24),
                          _stat('Low Stock', '$lowStockCount',
                              AppColors.warning),
                          if (_searchQuery.isNotEmpty ||
                              _selectedCategory != 'All') ...[
                            const SizedBox(width: 24),
                            _stat('Filtered', '${filtered.length}',
                                AppColors.textSecondary),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Product list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48,
                                color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              products.isEmpty
                                  ? 'No products yet'
                                  : 'No results found',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16),
                            ),
                            if (_selectedCategory != 'All' ||
                                _searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() {
                                  _selectedCategory = 'All';
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return ProductCard(
                            product: product,
                            onEdit: () => showDialog(
                              context: context,
                              builder: (_) =>
                                  ProductFormDialog(product: product),
                            ),
                            onDelete: () => _confirmDelete(
                                context, ref, product.id),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content:
            const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger),
            onPressed: () {
              ref
                  .read(inventoryNotifierProvider.notifier)
                  .deleteProduct(productId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}