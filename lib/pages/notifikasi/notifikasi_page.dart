import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  bool _isLoading = true;
  List<NotificationModel> _notifikasiList = [];

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    setState(() => _isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      if (userId != null) {
        final res = await ApiService.getNotifikasi(userId);
        if (res['status'] == 'success') {
          final List data = res['data'];
          setState(() {
            _notifikasiList = data.map((e) => NotificationModel.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notif) async {
    if (notif.isRead) return;

    try {
      await ApiService.readNotifikasi(notif.id);
      _loadNotifikasi();
    } catch (e) {
      debugPrint('Failed to mark as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _notifikasiList.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_off,
                  title: 'Belum ada notifikasi',
                  message: 'Notifikasi baru akan muncul di sini',
                  onRetry: _loadNotifikasi,
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifikasi,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifikasiList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notif = _notifikasiList[index];
                      return Card(
                        color: notif.isUnread ? Colors.blue.shade50 : Colors.white,
                        child: ListTile(
                          onTap: () => _markAsRead(notif),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              _getIconForType(notif.tipe),
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            notif.judul,
                            style: TextStyle(
                              fontWeight: notif.isUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notif.pesan),
                              const SizedBox(height: 8),
                              Text(
                                _formatDate(notif.createdAt),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getIconForType(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'tagihan_baru':
        return Icons.receipt_long;
      case 'jatuh_tempo':
        return Icons.warning;
      case 'pengaduan_selesai':
        return Icons.check_circle;
      case 'gangguan_air':
        return Icons.water_drop;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}