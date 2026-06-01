import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../models/tagihan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/currency_format.dart';

import '../auth/login_page.dart';
import '../tagihan/tagihan_page.dart';
import '../meter/upload_meter_page.dart';
import '../meter/meter_history_page.dart';
import '../pengaduan/pengaduan_page.dart';
import '../gangguan/gangguan_page.dart';
import '../notifikasi/notifikasi_page.dart';
import '../profile/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String nama = '';
  String noPelanggan = '';
  int? userId;

  bool isLoading = true;

  TagihanModel? tagihanTerbaru;

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
      final response = await ApiService.getTagihan(userId!);

      if (response['status'] == true && response['data'] != null) {
        final List data = response['data'];

        if (data.isNotEmpty) {
          tagihanTerbaru = TagihanModel.fromJson(data.first);
        }
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await StorageService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // PERBAIKAN: hapus method rupiah() lokal, pakai CurrencyFormat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Smart Meter'),
        actions: [
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
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
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

                        _menuCard(
                          icon: Icons.person_outline,
                          title: 'Profil',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tagihan.periode,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          // PERBAIKAN: pakai CurrencyFormat.rupiah() bukan rupiah() lokal
          Text(
            CurrencyFormat.rupiah(tagihan.totalTagihan),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tagihan.pemakaian} m³',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: tagihan.isLunas
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tagihan.statusLabel,
                  style: TextStyle(
                    color: tagihan.isLunas
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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