class NotificationModel {
  final int id;

  final int? userId;

  final String judul;
  final String pesan;

  final String tipe;
  final String status;

  final String? createdAt;
  final String? updatedAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationModel(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      userId: json['user_id'] == null
          ? null
          : int.tryParse(
              json['user_id'].toString(),
            ),

      judul:
          json['judul']?.toString() ?? '',

      pesan:
          json['pesan']?.toString() ?? '',

      tipe:
          json['tipe']?.toString() ?? '',

      status:
          json['status']?.toString() ?? 'unread',

      createdAt:
          json['created_at']?.toString(),

      updatedAt:
          json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'pesan': pesan,
      'tipe': tipe,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // =====================================
  // HELPER
  // =====================================

  bool get isRead =>
      status.toLowerCase() == 'read';

  bool get isUnread =>
      status.toLowerCase() == 'unread';

  String get tipeLabel {
    switch (tipe.toLowerCase()) {
      case 'tagihan_baru':
        return 'Tagihan Baru';

      case 'jatuh_tempo':
        return 'Jatuh Tempo';

      case 'pengaduan_selesai':
        return 'Pengaduan Selesai';

      case 'gangguan_air':
        return 'Gangguan Air';

      default:
        return tipe;
    }
  }

  String get iconName {
    switch (tipe.toLowerCase()) {
      case 'tagihan_baru':
        return 'receipt';

      case 'jatuh_tempo':
        return 'warning';

      case 'pengaduan_selesai':
        return 'support_agent';

      case 'gangguan_air':
        return 'water_drop';

      default:
        return 'notifications';
    }
  }
}