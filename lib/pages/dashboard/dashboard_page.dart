import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../models/tagihan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/currency_format.dart';


import '../tagihan/tagihan_page.dart';
import '../tagihan/detail_tagihan_page.dart';
import '../meter/upload_meter_page.dart';
import '../meter/meter_history_page.dart';
import '../pengaduan/pengaduan_page.dart';
import '../gangguan/gangguan_page.dart';
import '../gangguan/detail_gangguan_page.dart';
import '../../models/gangguan_model.dart';
import '../notifikasi/notifikasi_page.dart';
import '../profile/profile_page.dart';
import '../../models/meter_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const _DashboardContent(),
      const TagihanPage(isNested: true),
      const MeterHistoryPage(isNested: true),
      const ProfilePage(isNested: true),
    ]);
  }

  static const List<String> _titles = [
    'Smart Meter',
    'Tagihan',
    'Riwayat Meter',
    'Profil Saya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        automaticallyImplyLeading: false,
        actions: _currentIndex == 0
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotifikasiPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ]
            : null,
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Tagihan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// The original dashboard body, extracted into its own widget
// ──────────────────────────────────────────────────────────────
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  String nama = '';
  String noPelanggan = '';
  int? userId;

  bool isLoading = true;

  TagihanModel? tagihanTerbaru;
  MeterModel? meterTerbaru;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    userId = await StorageService.getUserId();
    nama = await StorageService.getNama();
    noPelanggan = await StorageService.getNoPelanggan();

    if (userId != null) {
      // Load Tagihan
      final response = await ApiService.getTagihan(userId!);

      if (response['status'] == true && response['data'] != null) {
        final List data = response['data'];

        if (data.isNotEmpty) {
          tagihanTerbaru = TagihanModel.fromJson(data.first);
        }
      }

      // Load Meter Baca Mandiri Terbaru
      try {
        final meterRes = await ApiService.getMeterHistory(userId!);
        if (meterRes['status'] == true && meterRes['data'] != null) {
          final List data = meterRes['data'];
          if (data.isNotEmpty) {
            meterTerbaru = MeterModel.fromJson(data.first);
          }
        }
      } catch (e) {
        debugPrint('Failed to load latest meter: $e');
      }

      // Check Active Gangguan Air
      try {
        final profileRes = await ApiService.getProfile(userId!);
        if (profileRes['status'] == true && profileRes['data'] != null) {
          final String userKecamatan = profileRes['data']['kecamatan'] ?? '';
          if (userKecamatan.isNotEmpty) {
            final gangguanRes = await ApiService.getGangguan(userKecamatan);
            if (gangguanRes['status'] == true && gangguanRes['data'] != null) {
              final List data = gangguanRes['data'];
              if (data.isNotEmpty && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showGangguanPopup(data);
                });
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to check active gangguan: $e');
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    nama.isEmpty ? 'Pelanggan' : nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'No. Pelanggan: $noPelanggan',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Tagihan Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            tagihanTerbaru == null
                ? _emptyTagihan()
                : _tagihanCard(),

            const SizedBox(height: 24),

            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _menuCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Upload Meter',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UploadMeterPage(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Tagihan',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TagihanPage(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  icon: Icons.history_outlined,
                  title: 'Riwayat Meter',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MeterHistoryPage(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  icon: Icons.support_agent_outlined,
                  title: 'Pengaduan',
                  color: AppColors.danger,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PengaduanPage(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  icon: Icons.water_damage_outlined,
                  title: 'Gangguan Air',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GangguanPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meterStatusCard() {
    if (meterTerbaru == null) return const SizedBox.shrink();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (meterTerbaru!.validasiPetugas.toLowerCase()) {
      case 'valid':
        statusColor = AppColors.success;
        statusText = 'Disetujui (Valid)';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'warning':
        statusColor = AppColors.danger;
        statusText = 'Ditolak / Anomali';
        statusIcon = Icons.error_outline;
        break;
      case 'pending':
      default:
        statusColor = AppColors.warning;
        statusText = 'Menunggu Validasi';
        statusIcon = Icons.hourglass_empty_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Status Baca Meter Mandiri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Periode: ${meterTerbaru!.bulan} ${meterTerbaru!.tahun}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Angka Meter:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                '${meterTerbaru!.meterBaru} m³',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          if (meterTerbaru!.validasiPetugas.toLowerCase() == 'warning' &&
              meterTerbaru!.catatanAnomali != null &&
              meterTerbaru!.catatanAnomali!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Catatan Petugas: ${meterTerbaru!.catatanAnomali}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showGangguanPopup(List data) {
    if (!mounted) return;

    final gangguan = data.first; // Latest active disruption
    final judul = gangguan['judul'] ?? 'Gangguan Aliran Air';
    final deskripsi = gangguan['deskripsi'] ?? '';
    final estimasi = gangguan['estimasi_selesai'] ?? 'Belum ditentukan';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              'Info Gangguan Air',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Estimasi Selesai: $estimasi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final model = GangguanModel.fromJson(gangguan);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailGangguanPage(gangguan: model),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Lihat Detail', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _emptyTagihan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Belum ada tagihan',
        style: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _tagihanCard() {
    final tagihan = tagihanTerbaru!;

    // Resolve meter status for this period
    Color? statusBannerBg;
    Color? statusBannerText;
    String? statusBannerMsg;
    IconData? statusBannerIcon;

    if (meterTerbaru != null) {
      final valStatus = meterTerbaru!.validasiPetugas.toLowerCase();
      if (valStatus == 'warning') {
        statusBannerBg = Colors.red.shade50;
        statusBannerText = Colors.red.shade700;
        statusBannerIcon = Icons.error_outline;
        statusBannerMsg = 'Ditolak: ${meterTerbaru!.catatanAnomali ?? "Foto buram atau data tidak sesuai"}';
      } else if (valStatus == 'pending' && meterTerbaru!.isAnomali) {
        statusBannerBg = Colors.amber.shade50;
        statusBannerText = Colors.amber.shade800;
        statusBannerIcon = Icons.warning_amber_rounded;
        statusBannerMsg = 'Terdeteksi Anomali (Menunggu Validasi)';
      } else if (valStatus == 'pending') {
        statusBannerBg = Colors.blue.shade50;
        statusBannerText = Colors.blue.shade700;
        statusBannerIcon = Icons.hourglass_empty;
        statusBannerMsg = 'Pembacaan meter sedang divalidasi petugas';
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Periode & Status Tagihan
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      tagihan.periode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagihan.isLunas
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tagihan.statusLabel,
                    style: TextStyle(
                      color: tagihan.isLunas ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.grey.shade100, height: 1),
          ),

          // Middle: Amount, Pemakaian & Jatuh tempo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Tagihan Anda',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormat.rupiah(tagihan.totalTagihan),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Row for Pemakaian and Jatuh Tempo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop_outlined, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${tagihan.pemakaian} m³',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.event_note, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Jatuh Tempo: ${tagihan.jatuhTempo ?? "-"}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Anomaly/Warning Status Banner (Integrated inside card)
          if (statusBannerMsg != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: statusBannerBg,
              child: Row(
                children: [
                  Icon(statusBannerIcon, color: statusBannerText, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusBannerMsg,
                      style: TextStyle(
                        color: statusBannerText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Action: Shortcut button to Pay Now (if Unpaid)
          if (tagihan.isBelumBayar)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailTagihanPage(tagihan: tagihan),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withBlue(220),
                    ],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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

  Widget _menuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}