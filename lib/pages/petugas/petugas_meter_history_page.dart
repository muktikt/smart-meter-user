import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class PetugasMeterHistoryPage extends StatefulWidget {
  const PetugasMeterHistoryPage({super.key});

  @override
  State<PetugasMeterHistoryPage> createState() => _PetugasMeterHistoryPageState();
}

class _PetugasMeterHistoryPageState extends State<PetugasMeterHistoryPage> {
  bool isLoading = true;
  List<dynamic> historyMeter = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    try {
      final petugasId = await StorageService.getUserId();
      if (petugasId != null) {
        final res = await ApiService.getPetugasMeterHistory(petugasId);
        if (res['status'] == true) {
          setState(() {
            historyMeter = res['data'] ?? [];
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
        title: const Text('Riwayat Validasi Meter'),
      ),
      body: isLoading
          ? const LoadingWidget()
          : historyMeter.isEmpty
              ? EmptyState(
                  icon: Icons.history_edu,
                  title: 'Belum ada riwayat',
                  message: 'Riwayat validasi pekerjaan Anda akan tercantum di sini.',
                  onRetry: _loadHistory,
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: historyMeter.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = historyMeter[index];
                      final user = item['user'] ?? {};
                      final userName = user['nama'] ?? 'Pelanggan';
                      final noPelanggan = user['no_pelanggan'] ?? '-';
                      final meterBaru = item['meter_baru'] ?? 0;
                      final pemakaian = item['pemakaian'] ?? 0;
                      final statusVal = item['validasi_petugas'] ?? item['status'];
                      final isAnomali = item['status_anomali'] == 'anomali';
                      final dateString = item['validated_at'] ?? item['updated_at'];

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

                      Color badgeColor = Colors.green;
                      if (statusVal == 'pending') {
                        badgeColor = Colors.orange;
                      } else if (statusVal == 'warning' || isAnomali) {
                        badgeColor = Colors.red;
                      }

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
                                      userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusVal.toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('No. Pelanggan: $noPelanggan', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Meter Baru: $meterBaru m³',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Pemakaian: $pemakaian m³',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              if (item['catatan_anomali'] != null && item['catatan_anomali'].toString().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade100),
                                  ),
                                  child: Text(
                                    'Catatan: ${item['catatan_anomali']}',
                                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
