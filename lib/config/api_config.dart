import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get _host {
    if (kIsWeb) {
      return "localhost";
    }
    // IP Address Laptop Anda (aktif di Wi-Fi): 192.168.100.18
    // Menggunakan IP Wi-Fi agar bisa diakses oleh HP Fisik maupun Emulator Android
    return "192.168.100.18";
  }

  static const String _port = "8000";
  static String get baseUrl => "http://$_host:$_port/api";

  static String get login => "$baseUrl/login";
  static String get register => "$baseUrl/register";
  static String get unifiedLogin => "$baseUrl/unified-login";

  static String profile(int id) => "$baseUrl/profile/$id";
  static String updateProfile(int id) => "$baseUrl/profile/update/$id";

  static String get ocrMeter => "$baseUrl/meter/ocr";
  static String get uploadMeter => "$baseUrl/upload-meter";
  static String meterHistory(int userId) => "$baseUrl/meter/history/$userId";

  static String tagihan(int userId) => "$baseUrl/tagihan/$userId";

  static String get createPengaduan => "$baseUrl/pengaduan";
  static String pengaduanHistory(int userId) => "$baseUrl/pengaduan/$userId";

  static String gangguan(String kecamatan) => "$baseUrl/gangguan/$kecamatan";

  static String notifikasi(int userId) => "$baseUrl/notifikasi/$userId";
  static String readNotifikasi(int id) => "$baseUrl/notifikasi/read/$id";

  static String get createPayment => "$baseUrl/payment/create";
  static String paymentStatus(String invoiceId) =>
      "$baseUrl/payment/status/$invoiceId";

  static String get petugasLogin => "$baseUrl/petugas/login";
  static String petugasMeter(int id) => "$baseUrl/petugas/meter/$id";
  static String petugasPengaduan(int id) => "$baseUrl/petugas/pengaduan/$id";
  static String validasiMeter(int id) => "$baseUrl/petugas/meter/validasi/$id";
  static String warningMeter(int id) => "$baseUrl/petugas/meter/warning/$id";
  
  static String petugasDashboard(int id) => "$baseUrl/petugas/dashboard/$id";
  static String petugasMeterDetail(int id) => "$baseUrl/petugas/meter/detail/$id";
  static String petugasMeterHistory(int id) => "$baseUrl/petugas/meter/history/$id";
  static String petugasPengaduanDetail(int id) => "$baseUrl/petugas/pengaduan/detail/$id";
  static String updatePengaduanStatus(int id) => "$baseUrl/petugas/pengaduan/update/$id";
  static String petugasGangguan(int id) => "$baseUrl/petugas/gangguan/$id";
  static String petugasProfile(int id) => "$baseUrl/petugas/profile/$id";
}