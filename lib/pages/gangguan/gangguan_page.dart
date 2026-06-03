import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/api_config.dart';
import '../../models/gangguan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'detail_gangguan_page.dart';

class GangguanPage extends StatefulWidget {
  const GangguanPage({super.key});

  @override
  State<GangguanPage> createState() => _GangguanPageState();
}

class _GangguanPageState extends State<GangguanPage> {
  bool _isLoading = true;
  List<GangguanModel> _gangguanList = [];
  String _userKecamatan = '';

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

      // 1. Get user profile to get kecamatan
      final profileRes = await ApiService.getProfile(userId);
      if (profileRes['status'] == true) {
        _userKecamatan = profileRes['data']['kecamatan'] ?? '';
      }

      if (_userKecamatan.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Get gangguan list by kecamatan
      final gangguanRes = await ApiService.getGangguan(_userKecamatan);
      if (gangguanRes['status'] == true) {
        final List data = gangguanRes['data'];
        setState(() {
          _gangguanList = data.map((e) => GangguanModel.fromJson(e)).toList();
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
        title: const Text('Info Gangguan Air'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _userKecamatan.isEmpty
              ? EmptyState(
                  icon: Icons.location_off,
                  title: 'Kecamatan tidak ditemukan',
                  message: 'Silakan update profil Anda terlebih dahulu',
                  onRetry: _loadData,
                )
              : _gangguanList.isEmpty
                  ? EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'Tidak ada gangguan',
                      message: 'Aliran air di kecamatan $_userKecamatan terpantau normal',
                      onRetry: _loadData,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _gangguanList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final gangguan = _gangguanList[index];
                          return _buildGangguanCard(gangguan);
                        },
                      ),
                    ),
    );
  }

  Widget _buildGangguanCard(GangguanModel gangguan) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailGangguanPage(gangguan: gangguan),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (gangguan.foto != null && gangguan.foto!.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final String? hostUrl = ApiConfig.baseUrl.replaceAll('/api', '');
                  final String imagePath = gangguan.foto!.startsWith('http')
                      ? gangguan.foto!
                      : "$hostUrl/storage/${gangguan.foto}";
                  return Image.network(
                    imagePath,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  );
                }
              ),
            ] else
              Container(
                height: 100,
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.water_drop, size: 50, color: AppColors.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          gangguan.judul,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gangguan.isAktif ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gangguan.statusLabel,
                          style: TextStyle(
                            color: gangguan.isAktif ? Colors.red.shade800 : Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gangguan.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(gangguan.tanggalMulai) ?? '-',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}