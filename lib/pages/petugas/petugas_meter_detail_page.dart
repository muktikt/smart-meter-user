import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_helper.dart';
import '../../widgets/loading_widget.dart';

class PetugasMeterDetailPage extends StatefulWidget {
  final int meterId;

  const PetugasMeterDetailPage({
    super.key,
    required this.meterId,
  });

  @override
  State<PetugasMeterDetailPage> createState() => _PetugasMeterDetailPageState();
}

class _PetugasMeterDetailPageState extends State<PetugasMeterDetailPage> {
  bool isLoading = true;
  bool isActionLoading = false;
  Map<String, dynamic>? dataMeter;
  int petugasId = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => isLoading = true);
    try {
      final pId = await StorageService.getUserId();
      if (pId != null) {
        petugasId = pId;
      }
      final res = await ApiService.getPetugasMeterDetail(widget.meterId);
      if (res['status'] == true) {
        setState(() {
          dataMeter = res['data'];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      AppHelper.showError(context, 'Gagal memuat detail meteran.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _validasi() async {
    final confirm = await AppHelper.showConfirmDialog(
      context: context,
      title: 'Validasi Meter',
      content: 'Apakah Anda yakin data foto dan pembacaan meter ini sudah sesuai?',
      confirmText: 'Validasi',
    );

    if (confirm) {
      setState(() => isActionLoading = true);
      try {
        final res = await ApiService.validasiMeter(
          meterId: widget.meterId,
          petugasId: petugasId,
        );

        if (res['status'] == true) {
          if (!mounted) return;
          AppHelper.showSuccess(context, 'Meter berhasil divalidasi!');
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          AppHelper.showError(context, res['message'] ?? 'Validasi gagal.');
        }
      } catch (e) {
        if (!mounted) return;
        AppHelper.showError(context, 'Terjadi kesalahan jaringan.');
      } finally {
        if (mounted) {
          setState(() => isActionLoading = false);
        }
      }
    }
  }

  Future<void> _anomali() async {
    final TextEditingController catatanController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Warning/Anomali', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berikan catatan alasan mengapa data meter ini anomali atau mencurigakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Misal: Foto buram, pemakaian melonjak tidak wajar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Tandai Warning'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final catatan = catatanController.text.trim();
      if (catatan.isEmpty) {
        AppHelper.showError(context, 'Catatan anomali wajib diisi.');
        return;
      }

      setState(() => isActionLoading = true);
      try {
        final res = await ApiService.warningMeter(
          meterId: widget.meterId,
          petugasId: petugasId,
          catatanAnomali: catatan,
        );

        if (res['status'] == true) {
          if (!mounted) return;
          AppHelper.showSuccess(context, 'Meter berhasil ditandai Warning.');
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          AppHelper.showError(context, res['message'] ?? 'Gagal menandai.');
        }
      } catch (e) {
        if (!mounted) return;
        AppHelper.showError(context, 'Terjadi kesalahan jaringan.');
      } finally {
        if (mounted) {
          setState(() => isActionLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    if (dataMeter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Meter')),
        body: const Center(child: Text('Data tidak ditemukan.')),
      );
    }

    final user = dataMeter!['user'] ?? {};
    final userName = user['nama'] ?? 'Pelanggan';
    final noPelanggan = user['no_pelanggan'] ?? '-';
    final kecamatan = user['kecamatan'] ?? '-';
    final alamat = user['alamat'] ?? '-';
    final meterLama = dataMeter!['meter_lama'] ?? 0;
    final meterBaru = dataMeter!['meter_baru'] ?? 0;
    final pemakaian = dataMeter!['pemakaian'] ?? 0;
    final ocrHasil = dataMeter!['hasil_ocr'] ?? '-';
    final ocrPersen = dataMeter!['ocr_persen'] ?? 0;
    final fotoMeter = dataMeter!['foto_meter'];

    // Resolve foto URL
    final String? hostUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final String imagePath = fotoMeter != null
        ? "$hostUrl/storage/$fotoMeter"
        : "https://via.placeholder.com/400x300";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Validasi Meter'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image view
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imagePath,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Icon(Icons.broken_image, size: 70, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Data Pelanggan Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Pelanggan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildDetailRow('Nama Pelanggan', userName),
                        _buildDetailRow('No. Pelanggan', noPelanggan),
                        _buildDetailRow('Kecamatan', kecamatan),
                        _buildDetailRow('Alamat Lengkap', alamat),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Data Meter Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Pembacaan Meter',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildDetailRow('Meter Bulan Lalu', '$meterLama m³'),
                        _buildDetailRow('Meter Bulan Ini', '$meterBaru m³'),
                        _buildDetailRow('Total Pemakaian', '$pemakaian m³', isPrimary: true),
                        _buildDetailRow('Hasil Pembacaan AI OCR', ocrHasil),
                        _buildDetailRow('Akurasi AI OCR', '$ocrPersen%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Panel
          if (isActionLoading)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            )
          else
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _anomali,
                          icon: const Icon(Icons.warning, color: Colors.white),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.danger),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text(
                            'Tolak / Anomali',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _validasi,
                          icon: const Icon(Icons.check),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text(
                            'Setujui (Valid)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                fontSize: isPrimary ? 14 : 13,
                color: isPrimary ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
