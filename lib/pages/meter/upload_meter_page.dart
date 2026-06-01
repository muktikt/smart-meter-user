import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../config/app_colors.dart';
import 'ocr_result_page.dart';

class UploadMeterPage extends StatefulWidget {
  const UploadMeterPage({super.key});

  @override
  State<UploadMeterPage> createState() => _UploadMeterPageState();
}

class _UploadMeterPageState extends State<UploadMeterPage> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  bool isProcessing = false;

  String hasilOcr = '';
  String ocrStatus = 'pending';

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      hasilOcr = '';
      ocrStatus = 'pending';
    });

    await processOCR();
  }

  Future<void> processOCR() async {
    if (selectedImage == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFile(selectedImage!);

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      final String allText = recognizedText.text;

      final RegExp angkaRegex = RegExp(r'\d+');
      final Iterable<RegExpMatch> matches = angkaRegex.allMatches(allText);

      String angkaTerbaca = '';

      for (final match in matches) {
        final angka = match.group(0) ?? '';

        if (angka.length > angkaTerbaca.length) {
          angkaTerbaca = angka;
        }
      }

      setState(() {
        hasilOcr = angkaTerbaca;
        ocrStatus = angkaTerbaca.isNotEmpty ? 'berhasil' : 'gagal';
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OcrResultPage(
            imageFile: selectedImage!,
            hasilOcr: angkaTerbaca,
            ocrPersen: angkaTerbaca.isNotEmpty ? 100 : 0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        ocrStatus = 'gagal';
      });

      showMessage(
        'Gagal memproses OCR',
        isError: true,
      );
    }

    if (mounted) {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Upload Meter'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  selectedImage == null
                      ? Container(
                          height: 240,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),

                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 75,
                                color: AppColors.primary,
                              ),

                              SizedBox(height: 14),

                              Text(
                                'Ambil foto meter air',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                'Pastikan angka terlihat jelas',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                          ),
                        ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Kamera'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text('Galeri'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI OCR Meter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (isProcessing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          ocrStatus == 'berhasil'
                              ? Icons.check_circle
                              : ocrStatus == 'gagal'
                                  ? Icons.error_outline
                                  : Icons.info_outline,
                          color: ocrStatus == 'berhasil'
                              ? AppColors.success
                              : ocrStatus == 'gagal'
                                  ? AppColors.danger
                                  : AppColors.textSecondary,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            ocrStatus == 'berhasil'
                                ? 'OCR berhasil membaca angka: $hasilOcr'
                                : ocrStatus == 'gagal'
                                    ? 'OCR belum berhasil membaca angka. Anda tetap bisa input manual di halaman konfirmasi.'
                                    : 'Ambil foto untuk mulai membaca angka meter.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Tips: gunakan foto angka meter yang jelas. Untuk demo, Anda bisa menulis angka besar di kertas lalu memfotonya.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}