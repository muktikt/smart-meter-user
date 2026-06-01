import 'dart:io';

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class OcrResultPage extends StatefulWidget {
  final File imageFile;
  final String hasilOcr;
  final int ocrPersen;

  const OcrResultPage({
    super.key,
    required this.imageFile,
    required this.hasilOcr,
    required this.ocrPersen,
  });

  @override
  State<OcrResultPage> createState() => _OcrResultPageState();
}

class _OcrResultPageState extends State<OcrResultPage> {
  late TextEditingController meterController;

  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    meterController = TextEditingController(
      text: widget.hasilOcr,
    );
  }

  Future<void> submitMeter() async {
    final userId = await StorageService.getUserId();

    if (userId == null) {
      showMessage(
        'User tidak ditemukan',
        isError: true,
      );
      return;
    }

    if (meterController.text.trim().isEmpty) {
      showMessage(
        'Angka meter wajib diisi',
        isError: true,
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final response = await ApiService.uploadMeter(
        userId: userId,
        fotoMeter: widget.imageFile,
        meterBaru: meterController.text.trim(),
        hasilOcr: widget.hasilOcr,
        ocrPersen: widget.ocrPersen.toString(),
      );

      if (response['status'] == true) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: const Text(
                'Berhasil',
              ),
              content: const Text(
                'Data meter berhasil dikirim dan menunggu validasi petugas.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                  ),
                ),
              ],
            );
          },
        );
      } else {
        showMessage(
          response['message'] ?? 'Upload gagal',
          isError: true,
        );
      }
    } catch (e) {
      showMessage(
        'Gagal terhubung ke server',
        isError: true,
      );
    }

    if (mounted) {
      setState(() {
        isUploading = false;
      });
    }
  }

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isError ? AppColors.danger : AppColors.success,
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    meterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Hasil OCR',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OCR Accuracy ${widget.ocrPersen}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: meterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Angka Meter',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Periksa kembali hasil OCR sebelum dikirim.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                    isUploading ? null : submitMeter,
                icon: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  isUploading
                      ? 'Mengirim...'
                      : 'Kirim Meter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}