import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/loading_widget.dart';
import '../auth/login_page.dart';

class PetugasProfilePage extends StatefulWidget {
  final bool isNested;
  const PetugasProfilePage({super.key, this.isNested = false});

  @override
  State<PetugasProfilePage> createState() => _PetugasProfilePageState();
}

class _PetugasProfilePageState extends State<PetugasProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final petugasId = await StorageService.getUserId();
      if (petugasId != null) {
        final res = await ApiService.getPetugasProfile(petugasId);
        if (res['status'] == true) {
          setState(() {
            profileData = res['data'];
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun petugas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    if (profileData == null) {
      if (widget.isNested) {
        return const Scaffold(
          body: Center(child: Text('Profil tidak ditemukan.')),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Petugas')),
        body: const Center(child: Text('Profil tidak ditemukan.')),
      );
    }

    final nama = profileData!['nama'] ?? '-';
    final kodePetugas = profileData!['kode_petugas'] ?? '-';
    final email = profileData!['email'] ?? '-';
    final noHp = profileData!['no_hp'] ?? '-';
    final kecamatan = profileData!['kecamatan'] ?? '-';
    final role = profileData!['role'] ?? 'lapangan';
    final status = profileData!['status'] ?? 'aktif';
    final deviceId = profileData!['device_id'] ?? 'Belum Terhubung';
    final deviceName = profileData!['device_name'] ?? '-';

    final Widget bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Head Profile Card
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.support_agent,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  nama,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'KODE PETUGAS: $kodePetugas',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Profile detail list
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Informasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildProfileItem(Icons.email_outlined, 'Email', email),
                  _buildProfileItem(Icons.phone_outlined, 'Nomor HP', noHp),
                  _buildProfileItem(Icons.map_outlined, 'Kecamatan Tugas', kecamatan),
                  _buildProfileItem(Icons.work_outline, 'Role / Jabatan', role.toString().toUpperCase()),
                  _buildProfileItem(Icons.toggle_on_outlined, 'Status Akun', status.toString().toUpperCase()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Device Lock Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kunci Perangkat (Device Lock)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildProfileItem(Icons.phonelink_lock, 'Device ID', deviceId),
                  _buildProfileItem(Icons.phone_android, 'Device Name', deviceName),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
        title: const Text('Profil Petugas'),
      ),
      body: bodyContent,
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
