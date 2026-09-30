import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';

/// Layar daftar notifikasi kasir.
///
/// Menampilkan notifikasi transaksi berhasil, stok menipis/habis, dan
/// pengumuman admin. Item belum dibaca ditandai; tap untuk menandai dibaca.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (provider.items.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tandai semua dibaca',
              onPressed: provider.unread > 0 ? () => provider.markAllRead() : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus semua',
              onPressed: () => _confirmClearAll(context),
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Center(child: Text(provider.error!)),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: () => provider.refresh(),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    if (provider.items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Center(child: Text('Tidak ada notifikasi')),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final notification = provider.items[index];
        return _NotificationCard(notification: notification);
      },
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    // Ambil provider sebelum async gap agar tidak memakai context setelah await
    final provider = context.read<NotificationProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text('Yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await provider.clearAll();
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  (IconData, Color) get _style {
    switch (notification.type) {
      case NotificationType.transaction:
        return (Icons.receipt_long, Colors.green);
      case NotificationType.stock:
        return (Icons.inventory, Colors.orange);
      case NotificationType.broadcast:
        return (Icons.campaign, Colors.blue);
    }
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    final unread = !notification.read;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: unread ? color.withValues(alpha: 0.06) : null,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: unread ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _timeLabel(notification.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: unread
            ? Icon(Icons.circle, size: 12, color: color)
            : const Icon(Icons.check_circle_outline,
                size: 16, color: Colors.grey),
        onTap: () {
          if (unread) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }
        },
      ),
    );
  }
}
