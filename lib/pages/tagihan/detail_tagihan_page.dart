import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../models/tagihan_model.dart';
import '../../services/api_service.dart';
import '../../utils/currency_format.dart';

class DetailTagihanPage extends StatefulWidget {
  final TagihanModel tagihan;

  const DetailTagihanPage({
    super.key,
    required this.tagihan,
  });

  @override
  State<DetailTagihanPage> createState() => _DetailTagihanPageState();
}

class _DetailTagihanPageState extends State<DetailTagihanPage> {
  bool _isPaymentLoading = false;

  Future<void> _bayarSekarang() async {
    setState(() => _isPaymentLoading = true);

    try {
      final response = await ApiService.createPayment(
        tagihanId: widget.tagihan.id,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final paymentUrl = response['data']?['payment_url']?.toString();

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          final uri = Uri.parse(paymentUrl);

          // Try external browser first, then fall back to in-app
          try {
            final launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              // Fallback: try in-app webview
              await launchUrl(uri, mode: LaunchMode.inAppWebView);
            }
          } catch (_) {
            // Final fallback: try platform default
            try {
              await launchUrl(uri, mode: LaunchMode.platformDefault);
            } catch (e) {
              if (mounted) {
                _showError('Tidak dapat membuka halaman pembayaran: $e');
              }
            }
          }
        } else {
          _showError('URL pembayaran tidak tersedia');
        }
      } else {
        final message = response['message']?.toString() ?? 'Gagal membuat pembayaran';
        _showError(message);
      }
    } catch (e) {
      if (mounted) {
        _showError('Tidak dapat terhubung ke server');
      }
    } finally {
      if (mounted) {
        setState(() => _isPaymentLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        content: Text(message),
      ),
    );
  }

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
                    widget.tagihan.isLunas
                        ? Icons.check_circle
                        : Icons.receipt_long,
                    size: 70,
                    color: widget.tagihan.isLunas
                        ? AppColors.success
                        : AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    CurrencyFormat.rupiah(
                      widget.tagihan.totalTagihan,
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
                      color: widget.tagihan.isLunas
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.tagihan.statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.tagihan.isLunas
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
              value: widget.tagihan.periode,
            ),

            _detailCard(
              title: 'Pemakaian',
              value: '${widget.tagihan.pemakaian} m³',
            ),

            _detailCard(
              title: 'Tarif per m³',
              value: CurrencyFormat.rupiah(
                widget.tagihan.tarifPerM3,
              ),
            ),

            _detailCard(
              title: 'Total Tagihan',
              value: CurrencyFormat.rupiah(
                widget.tagihan.totalTagihan,
              ),
            ),

            _detailCard(
              title: 'Jatuh Tempo',
              value: widget.tagihan.jatuhTempo ?? '-',
            ),

            _detailCard(
              title: 'Invoice',
              value: widget.tagihan.invoiceNumber ?? '-',
            ),

            const SizedBox(height: 30),

            if (widget.tagihan.isBelumBayar)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isPaymentLoading ? null : _bayarSekarang,
                  icon: _isPaymentLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.payment),
                  label: Text(
                    _isPaymentLoading ? 'Memproses...' : 'Bayar Sekarang',
                    style: const TextStyle(
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