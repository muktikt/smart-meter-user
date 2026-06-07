import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class PetugasGangguanPage extends StatefulWidget {
  final bool isNested;
  const PetugasGangguanPage({super.key, this.isNested = false});

  @override
  State<PetugasGangguanPage> createState() => _PetugasGangguanPageState();
}

class _PetugasGangguanPageState extends State<PetugasGangguanPage> {
  bool isLoading = true;
  List<dynamic> listGangguan = [];

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
        final res = await ApiService.getPetugasGangguan(petugasId);
        if (res['status'] == true) {
          setState(() {
            listGangguan = res['data'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    final Widget bodyContent = isLoading
        ? const LoadingWidget()
        : listGangguan.isEmpty
            ? EmptyState(
                icon: Icons.water_drop_outlined,
                title: 'Aliran air normal',
                message: 'Tidak ada info gangguan air aktif di kecamatan Anda.',
                onRetry: _loadData,
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listGangguan.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = listGangguan[index];
                      final judul = item['judul'] ?? 'Gangguan Aliran Air';
                      final deskripsi = item['deskripsi'] ?? '';
                      final kecamatan = item['kecamatan'] ?? '-';
                      final tglMulai = item['tanggal_mulai'] ?? '-';
                      final estimasi = item['estimasi_selesai'] ?? '-';
                      final status = item['status'] ?? 'aktif';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      judul,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                deskripsi,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('Wilayah (Kecamatan)', kecamatan),
                              _buildInfoRow('Mulai Gangguan', tglMulai),
                              _buildInfoRow('Estimasi Selesai', estimasi),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );

    if (widget.isNested) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gangguan Air Aktif'),
      ),
      body: bodyContent,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
