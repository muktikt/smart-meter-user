import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  // =====================================================
  // USER SESSION
  // =====================================================

  static Future<void> saveUser({
    required int id,
    required String nama,
    required String email,
    required String noPelanggan,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_login', true);
    await prefs.setString('role', 'user');
    await prefs.setInt('user_id', id);
    await prefs.setString('nama', nama);
    await prefs.setString('email', email);
    await prefs.setString('no_pelanggan', noPelanggan);
  }

  static Future<void> savePetugas({
    required int id,
    required String nama,
    required String email,
    required String kodePetugas,
    required String kecamatan,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_login', true);
    await prefs.setString('role', 'petugas');
    await prefs.setInt('user_id', id); // We can use user_id to store petugas ID
    await prefs.setString('nama', nama);
    await prefs.setString('email', email);
    await prefs.setString('kode_petugas', kodePetugas);
    await prefs.setString('kecamatan', kecamatan);
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'user';
  }

  static Future<String> getKecamatan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('kecamatan') ?? '';
  }

  static Future<String> getKodePetugas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('kode_petugas') ?? '';
  }

  // =====================================================
  // LOGIN STATUS
  // =====================================================

  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('is_login') ?? false;
  }

  // =====================================================
  // USER ID
  // =====================================================

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('user_id');
  }

  // =====================================================
  // USER NAME
  // =====================================================

  static Future<String> getNama() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('nama') ?? '';
  }

  // =====================================================
  // USER EMAIL
  // =====================================================

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('email') ?? '';
  }

  // =====================================================
  // NOMOR PELANGGAN
  // =====================================================

  static Future<String> getNoPelanggan() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('no_pelanggan') ?? '';
  }

  // =====================================================
  // UPDATE PROFILE LOCAL
  // =====================================================

  static Future<void> updateProfile({
    required String nama,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nama', nama);
    await prefs.setString('email', email);
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}