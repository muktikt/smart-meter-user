import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_helper.dart';
import '../../widgets/loading_widget.dart';

class PetugasPengaduanDetailPage extends StatefulWidget {
  final int pengaduanId;

  const PetugasPengaduanDetailPage({
    super.key,
    required this.pengaduanId,
  });

  @override
  State<PetugasPengaduanDetailPage> createState() => _PetugasPengaduanDetailPageState();
}

class _PetugasPengaduanDetailPageState extends State<PetugasPengaduanDetailPage> {
  bool isLoading = true;
  bool isActionLoading = false;
  Map<String, dynamic>? dataPengaduan;
  int petugasId = 0;

  final TextEditingController catatanController = TextEditingController();
  File? _fotoBukti;

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
      final res = await ApiService.getPetugasPengaduanDetail(widget.pengaduanId);
      if (res['status'] == true) {
        setState(() {
          dataPengaduan = res['data'];
          catatanController.text = dataPengaduan!['catatan_petugas'] ?? '';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      AppHelper.showError(context, 'Gagal memuat detail pengaduan.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickFotoBukti() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _fotoBukti = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _fotoBukti = File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    final catatan = catatanController.text.trim();
    if (status == 'selesai' && catatan.isEmpty) {
      AppHelper.showError(context, 'Catatan penyelesaian wajib diisi untuk status Selesai.');
      return;
    }
    if (status == 'selesai' && _fotoBukti == null) {
      AppHelper.showError(context, 'Foto bukti penyelesaian wajib diunggah untuk status Selesai.');
      return;
    }

    final confirm = await AppHelper.showConfirmDialog(
      context: context,
      title: 'Update Status Pengaduan',
      content: 'Apakah Anda yakin ingin mengubah status pengaduan menjadi ${status.toUpperCase()}?',
    );

    if (confirm) {
      setState(() => isActionLoading = true);
      try {
        final res = await ApiService.updatePengaduanStatus(
          pengaduanId: widget.pengaduanId,
          petugasId: petugasId,
          status: status,
          catatanPetugas: catatan.isNotEmpty ? catatan : null,
          fotoBukti: _fotoBukti,
        );

        if (res['status'] == true) {
          if (!mounted) return;
          AppHelper.showSuccess(context, 'Status pengaduan berhasil diperbarui!');
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          AppHelper.showError(context, res['message'] ?? 'Gagal memperbarui status.');
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
    if (isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    if (dataPengaduan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pengaduan')),
        body: const Center(child: Text('Data tidak ditemukan.')),
      );
    }

    final user = dataPengaduan!['user'] ?? {};
    final userName = user['nama'] ?? 'Pelanggan';
    final noPelanggan = user['no_pelanggan'] ?? '-';
    final noHp = user['no_hp'] ?? '-';
    final kecamatan = user['kecamatan'] ?? '-';
    final alamat = user['alamat'] ?? '-';
    final kategori = dataPengaduan!['kategori'] ?? 'Lainnya';
    final deskripsi = dataPengaduan!['deskripsi'] ?? '';
    final status = dataPengaduan!['status'] ?? 'pending';
    final foto = dataPengaduan!['foto'];

    // Resolve image URL
    final String? hostUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final String imagePath = foto != null
        ? "$hostUrl/storage/$foto"
        : "";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      kategori,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (imagePath.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imagePath,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Deskripsi keluhan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Keluhan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        Text(
                          deskripsi,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Data Pelanggan Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Pelanggan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildDetailRow('Nama Pelanggan', userName),
                        _buildDetailRow('No. Pelanggan', noPelanggan),
                        _buildDetailRow('Nomor HP', noHp),
                        _buildDetailRow('Kecamatan', kecamatan),
                        _buildDetailRow('Alamat', alamat),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Foto Bukti Penyelesaian
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foto Bukti Penyelesaian',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        if (status.toLowerCase() == 'selesai' && dataPengaduan!['foto_bukti'] != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              "$hostUrl/storage/${dataPengaduan!['foto_bukti']}",
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ] else if (status.toLowerCase() == 'selesai') ...[
                          const Text(
                            'Tidak ada foto bukti.',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ] else ...[
                          InkWell(
                            onTap: _pickFotoBukti,
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: _fotoBukti != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(_fotoBukti!, fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: InkWell(
                                            onTap: () => setState(() => _fotoBukti = null),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Tap untuk mengambil foto bukti', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Catatan Penyelesaian
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tindak Lanjut Petugas',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        if (status.toLowerCase() == 'selesai')
                          Text(
                            dataPengaduan!['catatan_petugas'] ?? 'Tidak ada catatan.',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          )
                        else
                          TextField(
                            controller: catatanController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Tulis tindakan penanganan atau solusi di sini...',
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Panel
          if (status.toLowerCase() != 'selesai')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: isActionLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          if (status.toLowerCase() == 'pending')
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus('proses'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text('Proses Keluhan', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )
                          else if (status.toLowerCase() == 'proses')
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus('selesai'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Selesaikan Keluhan', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
