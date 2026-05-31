class MeterModel {
  final int id;
  final int userId;

  final String bulan;
  final int tahun;

  final int meterLama;
  final int meterBaru;
  final int pemakaian;

  final String? fotoMeter;
  final String? hasilOcr;

  final String status;
  final String statusAnomali;

  final String? catatanAnomali;

  final int? petugasId;

  final int ocrPersen;
  final String ocrStatus;
  final String validasiPetugas;

  final String? createdAt;
  final String? updatedAt;

  MeterModel({
    required this.id,
    required this.userId,
    required this.bulan,
    required this.tahun,
    required this.meterLama,
    required this.meterBaru,
    required this.pemakaian,
    this.fotoMeter,
    this.hasilOcr,
    required this.status,
    required this.statusAnomali,
    this.catatanAnomali,
    this.petugasId,
    required this.ocrPersen,
    required this.ocrStatus,
    required this.validasiPetugas,
    this.createdAt,
    this.updatedAt,
  });

  factory MeterModel.fromJson(Map<String, dynamic> json) {
    return MeterModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      userId:
          int.tryParse(json['user_id'].toString()) ?? 0,

      bulan: json['bulan']?.toString() ?? '',

      tahun:
          int.tryParse(json['tahun'].toString()) ?? 0,

      meterLama:
          int.tryParse(json['meter_lama'].toString()) ?? 0,

      meterBaru:
          int.tryParse(json['meter_baru'].toString()) ?? 0,

      pemakaian:
          int.tryParse(json['pemakaian'].toString()) ?? 0,

      fotoMeter: json['foto_meter']?.toString(),

      hasilOcr: json['hasil_ocr']?.toString(),

      status: json['status']?.toString() ?? '',

      statusAnomali:
          json['status_anomali']?.toString() ?? 'normal',

      catatanAnomali:
          json['catatan_anomali']?.toString(),

      petugasId: json['petugas_id'] == null
          ? null
          : int.tryParse(json['petugas_id'].toString()),

      ocrPersen:
          int.tryParse(json['ocr_persen'].toString()) ?? 0,

      ocrStatus:
          json['ocr_status']?.toString() ?? 'pending',

      validasiPetugas:
          json['validasi_petugas']?.toString() ?? 'pending',

      createdAt: json['created_at']?.toString(),

      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bulan': bulan,
      'tahun': tahun,
      'meter_lama': meterLama,
      'meter_baru': meterBaru,
      'pemakaian': pemakaian,
      'foto_meter': fotoMeter,
      'hasil_ocr': hasilOcr,
      'status': status,
      'status_anomali': statusAnomali,
      'catatan_anomali': catatanAnomali,
      'petugas_id': petugasId,
      'ocr_persen': ocrPersen,
      'ocr_status': ocrStatus,
      'validasi_petugas': validasiPetugas,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isValid =>
      validasiPetugas.toLowerCase() == 'valid';

  bool get isPending =>
      validasiPetugas.toLowerCase() == 'pending';

  bool get isAnomali =>
      statusAnomali.toLowerCase() == 'anomali';
}