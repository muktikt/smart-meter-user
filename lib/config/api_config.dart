class ApiConfig {
  ApiConfig._();

  static const String webLocal =
      "http://127.0.0.1:8000/api";

  static const String emulator =
      "http://10.0.2.2:8000/api";

  static const String local =
      "http://192.168.1.100:8000/api";

  static const String production =
      "https://your-domain.com/api";

  static const String baseUrl = webLocal;

  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";

  static String profile(int id) => "$baseUrl/profile/$id";
  static String updateProfile(int id) => "$baseUrl/profile/update/$id";

  static const String ocrMeter = "$baseUrl/meter/ocr";
  static const String uploadMeter = "$baseUrl/upload-meter";
  static String meterHistory(int userId) => "$baseUrl/meter/history/$userId";

  static String tagihan(int userId) => "$baseUrl/tagihan/$userId";

  static const String createPengaduan = "$baseUrl/pengaduan";
  static String pengaduanHistory(int userId) => "$baseUrl/pengaduan/$userId";

  static String gangguan(String kecamatan) => "$baseUrl/gangguan/$kecamatan";

  static String notifikasi(int userId) => "$baseUrl/notifikasi/$userId";
  static String readNotifikasi(int id) => "$baseUrl/notifikasi/read/$id";

  static const String createPayment = "$baseUrl/payment/create";
  static String paymentStatus(String invoiceId) =>
      "$baseUrl/payment/status/$invoiceId";

  static const String petugasLogin = "$baseUrl/petugas/login";
  static String petugasMeter(int id) => "$baseUrl/petugas/meter/$id";
  static String petugasPengaduan(int id) => "$baseUrl/petugas/pengaduan/$id";
  static String validasiMeter(int id) => "$baseUrl/petugas/meter/validasi/$id";
  static String warningMeter(int id) => "$baseUrl/petugas/meter/warning/$id";
}