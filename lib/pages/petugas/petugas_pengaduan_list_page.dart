import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'petugas_pengaduan_detail_page.dart';

class PetugasPengaduanListPage extends StatefulWidget {
  const PetugasPengaduanListPage({super.key});

  @override
  State<PetugasPengaduanListPage> createState() => _PetugasPengaduanListPageState();
}

class _PetugasPengaduanListPageState extends State<PetugasPengaduanListPage> {
  bool isLoading = true;
  List<dynamic> listPengaduan = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final petugasId = await StorageService.getUserId();
      if (petugasId != null) {
        final res = await ApiService.getPetugasPengaduan(petugasId);
        if (res['status'] == true) {
          setState(() {
            listPengaduan = res['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Pengaduan'),
      ),
      body: isLoading
          ? const LoadingWidget()
          : listPengaduan.isEmpty
              ? EmptyState(
                  icon: Icons.rate_review,
                  title: 'Tidak ada pengaduan',
                  message: 'Pengaduan dari pelanggan di kecamatan Anda belum ada.',
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listPengaduan.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = listPengaduan[index];
                      final user = item['user'] ?? {};
                      final userName = user['nama'] ?? 'Pelanggan';
                      final kategori = item['kategori'] ?? 'Lainnya';
                      final deskripsi = item['deskripsi'] ?? '';
                      final status = item['status'] ?? 'pending';
                      final dateString = item['created_at'];

                      // Format date simply
                      String displayDate = '-';
                      if (dateString != null) {
                        try {
                          final date = DateTime.parse(dateString);
                          displayDate = '${date.day}/${date.month}/${date.year}';
                        } catch (_) {
                          displayDate = dateString;
                        }
                      }

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  kategori,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                deskripsi,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pelanggan: $userName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetugasPengaduanDetailPage(pengaduanId: item['id']),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _loadData();
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
