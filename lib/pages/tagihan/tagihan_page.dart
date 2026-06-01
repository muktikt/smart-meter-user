import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../models/tagihan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/currency_format.dart';

import 'detail_tagihan_page.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  bool isLoading = true;
  List<TagihanModel> tagihanList = [];

  @override
  void initState() {
    super.initState();
    loadTagihan();
  }

  Future<void> loadTagihan() async {
    setState(() {
      isLoading = true;
    });

    final userId = await StorageService.getUserId();

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.getTagihan(userId);

      if (response['status'] == true) {
        final List data = response['data'] ?? [];

        tagihanList = data
            .map((item) => TagihanModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      showMessage('Gagal mengambil data tagihan');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        content: Text(message),
      ),
    );
  }

  Color statusColor(TagihanModel item) {
    return item.isLunas ? AppColors.success : AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Tagihan Saya'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadTagihan,
              child: tagihanList.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Belum ada tagihan',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: tagihanList.length,
                      itemBuilder: (context, index) {
                        final item = tagihanList[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailTagihanPage(
                                  tagihan: item,
                                ),
                              ),
                            ).then((_) => loadTagihan());
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.periode.isNotEmpty
                                          ? item.periode
                                          : '${item.bulan} ${item.tahun}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor(item)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        item.statusLabel,
                                        style: TextStyle(
                                          color: statusColor(item),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // PERBAIKAN: hapus cast "as int", pakai CurrencyFormat
                                Text(
                                  CurrencyFormat.rupiah(item.totalTagihan),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${item.pemakaian} m³',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),

                                    const SizedBox(width: 18),

                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.jatuhTempo ?? '-',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Lihat detail tagihan',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),

                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
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