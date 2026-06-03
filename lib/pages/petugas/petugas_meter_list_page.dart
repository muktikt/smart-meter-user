import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'petugas_meter_detail_page.dart';

class PetugasMeterListPage extends StatefulWidget {
  const PetugasMeterListPage({super.key});

  @override
  State<PetugasMeterListPage> createState() => _PetugasMeterListPageState();
}

class _PetugasMeterListPageState extends State<PetugasMeterListPage> {
  bool isLoading = true;
  List<dynamic> listMeter = [];

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
        final res = await ApiService.getPetugasMeter(petugasId);
        if (res['status'] == true) {
          setState(() {
            listMeter = res['data'] ?? [];
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Validasi Meter Pending'),
      ),
      body: isLoading
          ? const LoadingWidget()
          : listMeter.isEmpty
              ? EmptyState(
                  icon: Icons.checklist_rtl,
                  title: 'Semua meter sudah tervalidasi',
                  message: 'Tidak ada data meter yang perlu divalidasi saat ini.',
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listMeter.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = listMeter[index];
                      final user = item['user'] ?? {};
                      final userName = user['nama'] ?? 'Pelanggan';
                      final noPelanggan = user['no_pelanggan'] ?? '-';
                      final kecamatan = user['kecamatan'] ?? '-';
                      final meterBaru = item['meter_baru'] ?? 0;
                      final ocrPersen = item['ocr_persen'] ?? 0;

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'OCR: $ocrPersen%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('No. Pelanggan: $noPelanggan', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Kecamatan: $kecamatan', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                'Angka Meter Baru: $meterBaru m³',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetugasMeterDetailPage(meterId: item['id']),
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
