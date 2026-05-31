class GangguanModel {
  final int id;

  final String judul;
  final String deskripsi;
  final String? foto;

  final String kecamatan;

  final String? tanggalMulai;
  final String? estimasiSelesai;

  final String status;

  final String? createdAt;
  final String? updatedAt;

  GangguanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.foto,
    required this.kecamatan,
    this.tanggalMulai,
    this.estimasiSelesai,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory GangguanModel.fromJson(Map<String, dynamic> json) {
    return GangguanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      foto: json['foto']?.toString(),
      kecamatan: json['kecamatan']?.toString() ?? '',
      tanggalMulai: json['tanggal_mulai']?.toString(),
      estimasiSelesai: json['estimasi_selesai']?.toString(),
      status: json['status']?.toString() ?? 'aktif',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'foto': foto,
      'kecamatan': kecamatan,
      'tanggal_mulai': tanggalMulai,
      'estimasi_selesai': estimasiSelesai,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAktif => status.toLowerCase() == 'aktif';

  bool get isSelesai => status.toLowerCase() == 'selesai';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'aktif':
        return 'Aktif';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }
}