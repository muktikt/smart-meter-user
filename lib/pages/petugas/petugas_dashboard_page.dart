import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../auth/login_page.dart';
import 'petugas_meter_list_page.dart';
import 'petugas_meter_history_page.dart';
import 'petugas_pengaduan_list_page.dart';
import 'petugas_gangguan_page.dart';
import 'petugas_profile_page.dart';

class PetugasDashboardPage extends StatefulWidget {
  const PetugasDashboardPage({super.key});

  @override
  State<PetugasDashboardPage> createState() => _PetugasDashboardPageState();
}

class _PetugasDashboardPageState extends State<PetugasDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const _PetugasDashboardContent(),
      const PetugasPengaduanListPage(isNested: true),
      const PetugasGangguanPage(isNested: true),
      const PetugasProfilePage(isNested: true),
    ]);
  }

  static const List<String> _titles = [
    'Dashboard Petugas',
    'Daftar Pengaduan',
    'Gangguan Air Aktif',
    'Profil Petugas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        automaticallyImplyLeading: false,
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
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              activeIcon: Icon(Icons.rate_review),
              label: 'Pengaduan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_damage_outlined),
              activeIcon: Icon(Icons.water_damage),
              label: 'Gangguan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
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
class _PetugasDashboardContent extends StatefulWidget {
  const _PetugasDashboardContent();

  @override
  State<_PetugasDashboardContent> createState() => _PetugasDashboardContentState();
}

class _PetugasDashboardContentState extends State<_PetugasDashboardContent> {
  bool isLoading = true;
  String namaPetugas = '';
  String kecamatanPetugas = '';
  int petugasId = 0;

  int pendingMeter = 0;
  int validMeter = 0;
  int anomaliMeter = 0;
  int pengaduanMasuk = 0;
  int pengaduanProses = 0;
  int pengaduanSelesai = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileAndData();
  }

  Future<void> _loadProfileAndData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final id = await StorageService.getUserId();
      final nama = await StorageService.getNama();
      final kec = await StorageService.getKecamatan();

      if (id != null) {
        petugasId = id;
        namaPetugas = nama;
        kecamatanPetugas = kec;

        final res = await ApiService.getPetugasDashboard(id);
        if (res['status'] == true) {
          final data = res['data'];
          if (mounted) {
            setState(() {
              pendingMeter = data['pending_meter'] ?? 0;
              validMeter = data['valid_meter'] ?? 0;
              anomaliMeter = data['anomali_meter'] ?? 0;
              pengaduanMasuk = data['pengaduan_masuk'] ?? 0;
              pengaduanProses = data['pengaduan_proses'] ?? 0;
              pengaduanSelesai = data['pengaduan_selesai'] ?? 0;
            });
          }
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
    return RefreshIndicator(
      onRefresh: _loadProfileAndData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        radius: 26,
                        child: Icon(Icons.support_agent, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaPetugas.isNotEmpty ? namaPetugas : 'Petugas PDAM',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Wilayah: $kecamatanPetugas',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Tugas Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 15),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Pekerjaan Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildStatCard(
                    title: 'Validasi Pending',
                    count: pendingMeter,
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetugasMeterListPage()),
                    ).then((_) => _loadProfileAndData()),
                  ),
                  _buildStatCard(
                    title: 'Meter Valid',
                    count: validMeter,
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetugasMeterHistoryPage()),
                    ),
                  ),
                  _buildStatCard(
                    title: 'Meter Anomali',
                    count: anomaliMeter,
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetugasMeterHistoryPage()),
                    ),
                  ),
                  _buildStatCard(
                    title: 'Pengaduan Masuk',
                    count: pengaduanMasuk + pengaduanProses,
                    icon: Icons.rate_review_outlined,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetugasPengaduanListPage()),
                    ).then((_) => _loadProfileAndData()),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Fitur Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 15),

              // Quick Menu List
              _buildMenuItem(
                title: 'Informasi Gangguan Air',
                subtitle: 'Pantau pipa bocor & perbaikan aktif',
                icon: Icons.water_damage_outlined,
                color: Colors.blue.shade700,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PetugasGangguanPage()),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                title: 'Riwayat Pekerjaan Saya',
                subtitle: 'Semua validasi meter yang telah diproses',
                icon: Icons.history,
                color: Colors.purple.shade600,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PetugasMeterHistoryPage()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
