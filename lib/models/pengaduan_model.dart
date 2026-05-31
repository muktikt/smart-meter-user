import 'user_model.dart';

class PengaduanModel {
  final int id;
  final int userId;

  final String kategori;
  final String deskripsi;

  final String? foto;
  final String status;

  final int? petugasId;

  final String? createdAt;
  final String? updatedAt;

  final UserModel? user;

  PengaduanModel({
    required this.id,
    required this.userId,
    required this.kategori,
    required this.deskripsi,
    this.foto,
    required this.status,
    this.petugasId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory PengaduanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PengaduanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      userId:
          int.tryParse(json['user_id'].toString()) ?? 0,

      kategori:
          json['kategori']?.toString() ?? '',

      deskripsi:
          json['deskripsi']?.toString() ?? '',

      foto: json['foto']?.toString(),

      status:
          json['status']?.toString() ?? 'proses',

      petugasId: json['petugas_id'] == null
          ? null
          : int.tryParse(
              json['petugas_id'].toString(),
            ),

      createdAt:
          json['created_at']?.toString(),

      updatedAt:
          json['updated_at']?.toString(),

      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'foto': foto,
      'status': status,
      'petugas_id': petugasId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // ====================================
  // HELPER
  // ====================================

  bool get isProses =>
      status.toLowerCase() == 'proses';

  bool get isSelesai =>
      status.toLowerCase() == 'selesai';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'proses':
        return 'Sedang Diproses';

      case 'selesai':
        return 'Selesai';

      default:
        return status;
    }
  }

  String get kategoriLabel {
    switch (kategori.toLowerCase()) {
      case 'kebocoran':
        return 'Kebocoran Pipa';

      case 'air_mati':
        return 'Air Mati';

      case 'meter':
        return 'Masalah Meter';

      case 'tagihan':
        return 'Masalah Tagihan';

      default:
        return kategori;
    }
  }
}