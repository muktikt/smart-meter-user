class CurrencyFormat {
  CurrencyFormat._();

  // =====================================================
  // FORMAT RUPIAH LENGKAP
  // Contoh: 400000.0 → "Rp 400.000"
  // =====================================================
  static String rupiah(double value) {
    final String angka = value.toStringAsFixed(0);

    final String formatted = angka.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp $formatted';
  }

  // =====================================================
  // FORMAT RUPIAH DENGAN DESIMAL
  // Contoh: 400000.5 → "Rp 400.000,50"
  // =====================================================
  static String rupiahDesimal(double value) {
    final parts = value.toStringAsFixed(2).split('.');

    final String ribuan = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp $ribuan,${parts[1]}';
  }

  // =====================================================
  // FORMAT ANGKA SAJA (TANPA "Rp")
  // Contoh: 400000.0 → "400.000"
  // =====================================================
  static String angka(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  // =====================================================
  // FORMAT SINGKAT (RIBUAN / JUTA)
  // Contoh: 1500000 → "Rp 1,5 Jt"
  //         400000  → "Rp 400 Rb"
  //         5000    → "Rp 5.000"
  // =====================================================
  static String singkat(double value) {
    if (value >= 1000000000) {
      final double miliar = value / 1000000000;
      final String hasil = miliar % 1 == 0
          ? miliar.toStringAsFixed(0)
          : miliar.toStringAsFixed(1);
      return 'Rp $hasil M';
    } else if (value >= 1000000) {
      final double juta = value / 1000000;
      final String hasil = juta % 1 == 0
          ? juta.toStringAsFixed(0)
          : juta.toStringAsFixed(1);
      return 'Rp $hasil Jt';
    } else if (value >= 1000) {
      final double ribu = value / 1000;
      final String hasil = ribu % 1 == 0
          ? ribu.toStringAsFixed(0)
          : ribu.toStringAsFixed(1);
      return 'Rp $hasil Rb';
    } else {
      return rupiah(value);
    }
  }

  // =====================================================
  // PARSE STRING RUPIAH KE DOUBLE
  // Contoh: "Rp 400.000" → 400000.0
  // =====================================================
  static double parse(String value) {
    final String cleaned = value
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }
}