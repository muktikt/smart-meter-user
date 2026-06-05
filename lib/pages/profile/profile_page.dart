import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../auth/splash_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  /// When true, the page is embedded inside a BottomNavigationBar tab
  /// and will not show its own AppBar/Scaffold.
  final bool isNested;

  const ProfilePage({super.key, this.isNested = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      if (userId != null) {
        final res = await ApiService.getProfile(userId);
        if (res['status'] == true) {
          setState(() {
            _profileData = res['data'];
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await StorageService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();

    if (_profileData == null) {
      return EmptyState(
        icon: Icons.person_off,
        title: 'Gagal memuat profil',
        message: 'Silakan coba lagi nanti',
        onRetry: _loadProfile,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profileData!['nama'] ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No. Pelanggan: ${_profileData!['no_pelanggan'] ?? '-'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoItem('Email', _profileData!['email'] ?? '-'),
          _buildInfoItem('No. HP', _profileData!['no_hp'] ?? '-'),
          _buildInfoItem('Alamat', _profileData!['alamat'] ?? '-'),
          _buildInfoItem('Kecamatan', _profileData!['kecamatan'] ?? '-'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(profileData: _profileData!),
                ),
              );
              if (result == true) {
                _loadProfile();
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
          ),
          const SizedBox(height: 16),

          // Logout button — prominent and always visible
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When nested inside BottomNavigationBar, skip the Scaffold/AppBar
    if (widget.isNested) {
      return _buildBody();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}