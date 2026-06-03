import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/api_config.dart';
import '../../models/meter_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class MeterHistoryPage extends StatefulWidget {
  const MeterHistoryPage({super.key});

  @override
  State<MeterHistoryPage> createState() => _MeterHistoryPageState();
}

class _MeterHistoryPageState extends State<MeterHistoryPage> {
  bool _isLoading = true;
  List<MeterModel> _meterList = [];

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

      final res = await ApiService.getMeterHistory(userId);
      if (res['status'] == true) {
        final List data = res['data'];
        setState(() {
          _meterList = data.map((e) => MeterModel.fromJson(e)).toList();
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
        title: const Text('Riwayat Meter'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _meterList.isEmpty
              ? EmptyState(
                  icon: Icons.history,
                  title: 'Belum ada riwayat',
                  message: 'Data baca meter mandiri Anda akan muncul di sini',
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _meterList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final meter = _meterList[index];
                      return _buildMeterCard(meter);
                    },
                  ),
                ),
    );
  }

  Widget _buildMeterCard(MeterModel meter) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${meter.bulan} ${meter.tahun}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getValidasiColor(meter.validasiPetugas).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meter.validasiPetugas.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getValidasiColor(meter.validasiPetugas),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (meter.fotoMeter != null && meter.fotoMeter!.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final String? hostUrl = ApiConfig.baseUrl.replaceAll('/api', '');
                      final String imagePath = meter.fotoMeter!.startsWith('http')
                          ? meter.fotoMeter!
                          : "$hostUrl/storage/${meter.fotoMeter}";
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imagePath,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        ),
                      );
                    }
                  ),
                ] else
                  _buildImagePlaceholder(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoRow('Meter Lama', '${meter.meterLama} m³'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Meter Baru', '${meter.meterBaru} m³'),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Pemakaian',
                        '${meter.pemakaian} m³',
                        isBold: true,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Akurasi OCR',
                        '${meter.ocrPersen}%',
                        color: _getOcrColor(meter.ocrPersen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (meter.isAnomali)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anomali: ${meter.catatanAnomali ?? "Pemakaian tidak wajar"}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getValidasiColor(String validasi) {
    switch (validasi.toLowerCase()) {
      case 'valid':
        return Colors.green;
      case 'invalid':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getOcrColor(int persen) {
    if (persen >= 90) return Colors.green;
    if (persen >= 70) return Colors.orange;
    return Colors.red;
  }
}