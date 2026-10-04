import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_model.dart';
import 'admin_provider.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUserProfilesProvider);

    return Column(
      children: [
        // ── Search bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by business name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),

        // ── User list ──────────────────────────────────────────────
        Expanded(
          child: usersAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (users) {
              final filtered = users.where((u) {
                if (_searchQuery.isEmpty) return true;
                return u.businessName.toLowerCase().contains(_searchQuery) ||
                    u.email.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No businesses found.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final user = filtered[i];
                  return _UserTile(user: user);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Individual user tile ───────────────────────────────────────────────────
class _UserTile extends ConsumerWidget {
  final BusinessUserProfile user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.read(adminNotifierProvider.notifier);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: user.isDisabled
            ? Colors.red.withOpacity(0.1)
            : const Color(0xFF1E40AF).withOpacity(0.1),
        child: Text(
          user.businessName.isNotEmpty
              ? user.businessName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                user.isDisabled ? Colors.red : const Color(0xFF1E40AF),
          ),
        ),
      ),
      title: Text(
        user.businessName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            'Joined: ${_formatDate(user.createdAt)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isDisabled
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF16A34A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.isDisabled ? 'Suspended' : 'Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: user.isDisabled
                    ? Colors.red
                    : const Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // More options menu
          PopupMenuButton<String>(
            onSelected: (action) =>
                _handleAction(context, ref, action, user, admin),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'view',
                child: ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('View Business Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.lock_reset),
                  title: Text('Send Password Reset'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: user.isDisabled ? 'enable' : 'disable',
                child: ListTile(
                  leading: Icon(
                    user.isDisabled ? Icons.check_circle : Icons.block,
                    color: user.isDisabled ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    user.isDisabled
                        ? 'Re-enable Account'
                        : 'Suspend Account',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Delete Account & Data',
                      style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    BusinessUserProfile user,
    AdminNotifier admin,
  ) async {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminUserDetailScreen(user: user),
          ),
        );
        break;

      case 'reset':
        await admin.sendPasswordReset(user.email);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset email sent to ${user.email}'),
            ),
          );
        }
        break;

      case 'disable':
        final confirm = await _confirmDialog(
          context,
          title: 'Suspend Account',
          message:
              'Are you sure you want to suspend ${user.businessName}? '
              'They will see a "suspended" screen when they log in.',
          confirmLabel: 'Suspend',
          confirmColor: Colors.orange,
        );
        if (confirm == true) {
          await admin.disableUser(user.uid);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${user.businessName} suspended.')),
            );
          }
        }
        break;

      case 'enable':
        await admin.enableUser(user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${user.businessName} re-enabled.')),
          );
        }
        break;

      case 'delete':
        final confirm = await _confirmDialog(
          context,
          title: 'Delete Account',
          message:
              'This will permanently delete ${user.businessName} and ALL '
              'their data — products, customers, and transactions. '
              'This cannot be undone.',
          confirmLabel: 'Delete',
          confirmColor: Colors.red,
        );
        if (confirm == true) {
          await admin.deleteUserAndData(user.uid);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('${user.businessName} deleted permanently.')),
            );
          }
        }
        break;
    }
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}
