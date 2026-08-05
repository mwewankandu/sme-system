import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'customer_provider.dart';
import 'widgets/customer_form_dialog.dart';
import 'widgets/record_payment_dialog.dart';
import 'credit_history_screen.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers & Credit')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customers_fab',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const CustomerFormDialog(),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Customer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (customers) {
          // Filter by search query
          final filtered = _searchQuery.isEmpty
              ? customers
              : customers
                  .where((c) =>
                      c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      c.phone.contains(_searchQuery))
                  .toList();

          final totalCredit =
              customers.fold(0.0, (sum, c) => sum + c.creditBalance);

          return Column(
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
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

              // Stats bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    _stat('Total Customers', '${customers.length}',
                        AppColors.primary),
                    const SizedBox(width: 24),
                    _stat(
                        'Total Credit Owed',
                        'ZMW ${totalCredit.toStringAsFixed(2)}',
                        AppColors.danger),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 24),
                      _stat('Results', '${filtered.length}',
                          AppColors.textSecondary),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),

              // Customer list
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
                              _searchQuery.isEmpty
                                  ? 'No customers yet'
                                  : 'No results for "$_searchQuery"',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          final hasBalance = customer.creditBalance > 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: hasBalance
                                  ? const BorderSide(
                                      color: AppColors.danger, width: 1)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      customer.name[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(customer.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        Text(customer.phone,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary)),
                                        if (hasBalance) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Owes: ZMW ${customer.creditBalance.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                color: AppColors.danger,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  Column(
                                    children: [
                                          // Credit history button
    IconButton(
      icon: const Icon(Icons.history,
          color: AppColors.primary, size: 20),
      tooltip: 'Credit History',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CreditHistoryScreen(customer: customer),
        ),
      ),
    ),
                                      if (hasBalance)
                                        IconButton(
                                          icon: const Icon(
                                              Icons.payments_outlined,
                                              color: AppColors.secondary),
                                          tooltip: 'Record Payment',
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) =>
                                                RecordPaymentDialog(
                                                    customer: customer),
                                          ),
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.primary,
                                            size: 20),
                                        tooltip: 'Edit',
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (_) => CustomerFormDialog(
                                              customer: customer),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.danger,
                                            size: 20),
                                        tooltip: 'Delete',
                                        onPressed: () => _confirmDelete(
                                            context, ref, customer.id),
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

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String customerId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
            'Are you sure? Their credit history will also be removed.'),
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
                  .read(customerNotifierProvider.notifier)
                  .deleteCustomer(customerId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}