import 'package:flutter/material.dart';
import 'package:smart_meter_user/models/tagihan_model.dart';

class DetailTagihanPage extends StatelessWidget {
  final TagihanModel tagihan; // tambahkan field ini

  const DetailTagihanPage({super.key, required this.tagihan}); // pakai this.tagihan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tagihan')),
      body: Center(child: Text(tagihan.periode)), // sekarang bisa diakses
    );
  }
}