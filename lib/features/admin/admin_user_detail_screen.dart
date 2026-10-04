import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_model.dart';
import 'admin_provider.dart';

/// Shows a specific business owner's full data:
/// their products, customers, and recent transactions.
class AdminUserDetailScreen extends ConsumerStatefulWidget {
  final BusinessUserProfile user;
  const AdminUserDetailScreen({super.key, required this.user});

  @override
  ConsumerState<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState
    extends ConsumerState<AdminUserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(u.businessName,
                style: const TextStyle(fontSize: 16)),
            Text(u.email,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFF16A34A),
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Products'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProductsTab(uid: u.uid),
          _CustomersTab(uid: u.uid),
          _TransactionsTab(uid: u.uid),
        ],
      ),
    );
  }
}

// ── Products Tab ───────────────────────────────────────────────────────────
class _ProductsTab extends StatelessWidget {
  final String uid;
  const _ProductsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('products')
          .orderBy('name')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No products found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final stock = d['stockQuantity'] ?? 0;
            final threshold = d['lowStockThreshold'] ?? 5;
            final isLow = stock <= threshold;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isLow ? Colors.amber.withOpacity(0.2) : Colors.grey[100],
                child: Icon(
                  isLow ? Icons.warning : Icons.inventory_2,
                  color: isLow ? Colors.amber[700] : Colors.grey,
                  size: 20,
                ),
              ),
              title: Text(d['name'] ?? ''),
              subtitle: Text(d['category'] ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ZMW ${(d['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Stock: $stock',
                      style: TextStyle(
                          fontSize: 11,
                          color: isLow ? Colors.red : Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Customers Tab ──────────────────────────────────────────────────────────
class _CustomersTab extends StatelessWidget {
  final String uid;
  const _CustomersTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('customers')
          .orderBy('name')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No customers found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final balance = (d['creditBalance'] ?? 0.0).toDouble();
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: balance > 0
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                child: Text(
                  (d['name'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: balance > 0 ? Colors.red : Colors.green),
                ),
              ),
              title: Text(d['name'] ?? ''),
              subtitle: Text(d['phone'] ?? ''),
              trailing: balance > 0
                  ? Text(
                      'Owes ZMW ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    )
                  : const Text('No balance',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
            );
          },
        );
      },
    );
  }
}

// ── Transactions Tab ───────────────────────────────────────────────────────
class _TransactionsTab extends StatelessWidget {
  final String uid;
  const _TransactionsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No transactions found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final method = d['paymentMethod'] ?? 'cash';
            final total = (d['totalAmount'] ?? 0.0).toDouble();
            final items = (d['items'] as List?)?.length ?? 0;
            final ts = d['createdAt'] as Timestamp?;
            final date = ts != null
                ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                : '';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _methodColor(method).withOpacity(0.1),
                child: Icon(_methodIcon(method),
                    color: _methodColor(method), size: 18),
              ),
              title: Text('ZMW ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$items item(s) · $date'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _methodColor(method).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  method == 'mobileMoney' ? 'Mobile' : method.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _methodColor(method)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _methodColor(String method) {
    switch (method) {
      case 'credit':
        return Colors.red;
      case 'mobileMoney':
        return Colors.blue;
      default:
        return const Color(0xFF16A34A);
    }
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'credit':
        return Icons.credit_card;
      case 'mobileMoney':
        return Icons.phone_android;
      default:
        return Icons.payments;
    }
  }
}
