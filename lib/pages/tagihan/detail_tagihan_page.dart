import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../models/tagihan_model.dart';
import '../../utils/currency_format.dart';

class DetailTagihanPage extends StatelessWidget {
  final TagihanModel tagihan;

  const DetailTagihanPage({
    super.key,
    required this.tagihan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Detail Tagihan'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                children: [

                  Icon(
                    tagihan.isLunas
                        ? Icons.check_circle
                        : Icons.receipt_long,
                    size: 70,
                    color: tagihan.isLunas
                        ? AppColors.success
                        : AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    CurrencyFormat.rupiah(
                      tagihan.totalTagihan,
                    ),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: tagihan.isLunas
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tagihan.statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tagihan.isLunas
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _detailCard(
              title: 'Periode',
              value: tagihan.periode,
            ),

            _detailCard(
              title: 'Pemakaian',
              value: '${tagihan.pemakaian} m³',
            ),

            _detailCard(
              title: 'Tarif per m³',
              value: CurrencyFormat.rupiah(
                tagihan.tarifPerM3,
              ),
            ),

            _detailCard(
              title: 'Total Tagihan',
              value: CurrencyFormat.rupiah(
                tagihan.totalTagihan,
              ),
            ),

            _detailCard(
              title: 'Jatuh Tempo',
              value: tagihan.jatuhTempo ?? '-',
            ),

            _detailCard(
              title: 'Invoice',
              value: tagihan.invoiceNumber ?? '-',
            ),

            const SizedBox(height: 30),

            if (tagihan.isBelumBayar)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Halaman pembayaran akan dibuat berikutnya',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}