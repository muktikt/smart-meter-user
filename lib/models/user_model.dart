class UserModel {
  final int id;
  final int? roleId;
  final String noPelanggan;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String kecamatan;
  final double? latitude;
  final double? longitude;
  final String statusAkun;
  final String? deviceId;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    this.roleId,
    required this.noPelanggan,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.kecamatan,
    this.latitude,
    this.longitude,
    required this.statusAkun,
    this.deviceId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      roleId: json['role_id'] == null
          ? null
          : int.tryParse(json['role_id'].toString()),
      noPelanggan: json['no_pelanggan']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      latitude: json['latitude'] == null
          ? null
          : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] == null
          ? null
          : double.tryParse(json['longitude'].toString()),
      statusAkun: json['status_akun']?.toString() ?? '',
      deviceId: json['device_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'no_pelanggan': noPelanggan,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'alamat': alamat,
      'kecamatan': kecamatan,
      'latitude': latitude,
      'longitude': longitude,
      'status_akun': statusAkun,
      'device_id': deviceId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}