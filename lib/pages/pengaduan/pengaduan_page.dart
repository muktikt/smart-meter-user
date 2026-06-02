import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../models/pengaduan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'create_pengaduan_page.dart';
import 'detail_pengaduan_page.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  bool _isLoading = true;
  List<PengaduanModel> _pengaduanList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) return;

      final res = await ApiService.getPengaduanHistory(userId);
      if (res['status'] == 'success') {
        final List data = res['data'];
        setState(() {
          _pengaduanList = data.map((e) => PengaduanModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengaduan'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _pengaduanList.isEmpty
              ? EmptyState(
                  icon: Icons.support_agent,
                  title: 'Belum ada pengaduan',
                  message: 'Riwayat pengaduan Anda akan muncul di sini',
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pengaduanList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pengaduan = _pengaduanList[index];
                      return _buildPengaduanCard(pengaduan);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePengaduanPage(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Pengaduan', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPengaduanCard(PengaduanModel pengaduan) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPengaduanPage(pengaduan: pengaduan),
            ),
          );
        },
        title: Text(
          pengaduan.kategoriLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              pengaduan.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(pengaduan.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pengaduan.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pengaduan.statusLabel,
                    style: TextStyle(
                      color: _getStatusColor(pengaduan.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'proses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
