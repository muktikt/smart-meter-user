import 'package:flutter/material.dart';
import 'package:smart_meter_user/models/tagihan_model.dart';

class DetailTagihanPage extends StatelessWidget {
  const DetailTagihanPage({super.key, required TagihanModel tagihan});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Detail Tagihan Page'),
      ),
    );
  }
}