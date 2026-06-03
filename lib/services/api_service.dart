import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  ApiService._();

  static Map<String, String> headers = {
    'Accept': 'application/json',
  };

  // =========================
  // AUTH
  // =========================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: headers,
      body: {
        'email': email,
        'password': password,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> unifiedLogin({
    required String identifier,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.unifiedLogin),
      headers: headers,
      body: {
        'identifier': identifier,
        'password': password,
        if (deviceId != null) 'device_id': deviceId,
        if (deviceName != null) 'device_name': deviceName,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register({
    required String noPelanggan,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
    required String kecamatan,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: headers,
      body: {
        'no_pelanggan': noPelanggan,
        'email': email,
        'password': password,
        'no_hp': noHp,
        'alamat': alamat,
        'kecamatan': kecamatan,
      },
    );

    return jsonDecode(response.body);
  }

  // =========================
  // PROFILE
  // =========================

  static Future<Map<String, dynamic>> getProfile(int id) async {
    final response = await http.get(
      Uri.parse(ApiConfig.profile(id)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int id,
    required String nama,
    required String email,
    required String noHp,
    required String alamat,
    required String kecamatan,
    required String latitude,
    required String longitude,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConfig.updateProfile(id)),
      headers: headers,
      body: {
        'nama': nama,
        'email': email,
        'no_hp': noHp,
        'alamat': alamat,
        'kecamatan': kecamatan,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return jsonDecode(response.body);
  }

  // =========================
  // TAGIHAN
  // =========================

  static Future<Map<String, dynamic>> getTagihan(int userId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.tagihan(userId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // PAYMENT DOMPETX
  // =========================

  static Future<Map<String, dynamic>> createPayment({
    required int tagihanId,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.createPayment),
      headers: headers,
      body: {
        'tagihan_id': tagihanId.toString(),
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkPaymentStatus({
    required String invoiceId,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConfig.paymentStatus(invoiceId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // METER OCR
  // =========================

  static Future<Map<String, dynamic>> ocrMeter({
    required File fotoMeter,
    required String hasilOcr,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.ocrMeter),
    );

    request.headers.addAll(headers);

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto_meter',
        fotoMeter.path,
      ),
    );

    request.fields['hasil_ocr'] = hasilOcr;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadMeter({
    required int userId,
    required File fotoMeter,
    required String meterBaru,
    required String hasilOcr,
    required String ocrPersen,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.uploadMeter),
    );

    request.headers.addAll(headers);

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto_meter',
        fotoMeter.path,
      ),
    );

    request.fields['user_id'] = userId.toString();
    request.fields['meter_baru'] = meterBaru;
    request.fields['hasil_ocr'] = hasilOcr;
    request.fields['ocr_persen'] = ocrPersen;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMeterHistory(int userId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.meterHistory(userId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // PENGADUAN
  // =========================

  static Future<Map<String, dynamic>> createPengaduan({
    required int userId,
    required String kategori,
    required String deskripsi,
    File? foto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.createPengaduan),
    );

    request.headers.addAll(headers);

    request.fields['user_id'] = userId.toString();
    request.fields['kategori'] = kategori;
    request.fields['deskripsi'] = deskripsi;

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPengaduanHistory(int userId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.pengaduanHistory(userId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // GANGGUAN AIR
  // =========================

  static Future<Map<String, dynamic>> getGangguan(String kecamatan) async {
    final response = await http.get(
      Uri.parse(ApiConfig.gangguan(kecamatan)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // NOTIFIKASI
  // =========================

  static Future<Map<String, dynamic>> getNotifikasi(int userId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.notifikasi(userId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> readNotifikasi(int id) async {
    final response = await http.put(
      Uri.parse(ApiConfig.readNotifikasi(id)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // PETUGAS API
  // =========================

  static Future<Map<String, dynamic>> petugasLogin({
    required String kodePetugas,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.petugasLogin),
      headers: headers,
      body: {
        'kode_petugas': kodePetugas,
        'password': password,
        if (deviceId != null) 'device_id': deviceId,
        if (deviceName != null) 'device_name': deviceName,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasDashboard(int petugasId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasDashboard(petugasId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasMeter(int petugasId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasMeter(petugasId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasMeterDetail(int meterId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasMeterDetail(meterId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> validasiMeter({
    required int meterId,
    required int petugasId,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.validasiMeter(meterId)),
      headers: headers,
      body: {
        'petugas_id': petugasId.toString(),
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> warningMeter({
    required int meterId,
    required int petugasId,
    required String catatanAnomali,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.warningMeter(meterId)),
      headers: headers,
      body: {
        'petugas_id': petugasId.toString(),
        'catatan_anomali': catatanAnomali,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasMeterHistory(int petugasId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasMeterHistory(petugasId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasPengaduan(int petugasId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasPengaduan(petugasId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasPengaduanDetail(int pengaduanId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasPengaduanDetail(pengaduanId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePengaduanStatus({
    required int pengaduanId,
    required int petugasId,
    required String status,
    String? catatanPetugas,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.updatePengaduanStatus(pengaduanId)),
      headers: headers,
      body: {
        'petugas_id': petugasId.toString(),
        'status': status,
        if (catatanPetugas != null) 'catatan_petugas': catatanPetugas,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasGangguan(int petugasId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasGangguan(petugasId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPetugasProfile(int petugasId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.petugasProfile(petugasId)),
      headers: headers,
    );

    return jsonDecode(response.body);
  }
}