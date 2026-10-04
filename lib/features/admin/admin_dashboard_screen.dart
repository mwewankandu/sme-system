import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final usersAsync = ref.watch(allUserProfilesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Platform-wide statistics',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // ── Stats Cards ──────────────────────────────────────────
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading stats: $e'),
            data: (stats) => Column(
              children: [
                // Row 1
                Row(
                  children: [
                    _StatCard(
                      label: 'Total Businesses',
                      value: stats.totalBusinesses.toString(),
                      icon: Icons.store,
                      color: const Color(0xFF1E40AF),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Active',
                      value: stats.activeBusinesses.toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF16A34A),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Row 2
                Row(
                  children: [
                    _StatCard(
                      label: 'Suspended',
                      value: stats.disabledBusinesses.toString(),
                      icon: Icons.block,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Total Transactions',
                      value: stats.totalTransactions.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Revenue full-width card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payments,
                            color: Color(0xFF16A34A),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Platform Revenue',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'ZMW ${stats.totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Recent Registrations ─────────────────────────────────
          const Text(
            'Recently Registered Businesses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (users) {
              final recent = users.take(5).toList();
              if (recent.isEmpty) {
                return const Text('No registered businesses yet.');
              }
              return Column(
                children: recent
                    .map((u) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF1E40AF).withOpacity(0.1),
                            child: Text(
                              u.businessName.isNotEmpty
                                  ? u.businessName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Color(0xFF1E40AF),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(u.businessName),
                          subtitle: Text(u.email),
                          trailing: u.isDisabled
                              ? const Chip(
                                  label: Text('Suspended',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                  backgroundColor: Colors.red,
                                )
                              : const Chip(
                                  label: Text('Active',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                  backgroundColor: Color(0xFF16A34A),
                                ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Stat card widget ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
