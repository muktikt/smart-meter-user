import 'meter_model.dart';
import 'user_model.dart';

class TagihanModel {
  final int id;
  final int userId;
  final int meterId;

  final String bulan;
  final int tahun;
  final String periode;

  final int pemakaian;
  final double totalTagihan;
  final double tarifPerM3;

  final String status;

  final String? invoiceNumber;
  final String? tanggalBayar;
  final String? metodeBayar;
  final String? jatuhTempo;

  final String? createdAt;
  final String? updatedAt;

  final UserModel? user;
  final MeterModel? meter;

  TagihanModel({
    required this.id,
    required this.userId,
    required this.meterId,
    required this.bulan,
    required this.tahun,
    required this.periode,
    required this.pemakaian,
    required this.totalTagihan,
    required this.tarifPerM3,
    required this.status,
    this.invoiceNumber,
    this.tanggalBayar,
    this.metodeBayar,
    this.jatuhTempo,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.meter,
  });

  factory TagihanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TagihanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      userId:
          int.tryParse(json['user_id'].toString()) ?? 0,

      meterId:
          int.tryParse(json['meter_id'].toString()) ?? 0,

      bulan: json['bulan']?.toString() ?? '',

      tahun:
          int.tryParse(json['tahun'].toString()) ?? 0,

      periode:
          json['periode']?.toString() ?? '',

      pemakaian:
          int.tryParse(json['pemakaian'].toString()) ?? 0,

      totalTagihan: double.tryParse(json['total_tagihan'].toString()) ?? 0,

      tarifPerM3: double.tryParse(json['tarif_per_m3'].toString()) ?? 0,

      status:
          json['status']?.toString() ?? 'belum_bayar',

      invoiceNumber:
          json['invoice_number']?.toString(),

      tanggalBayar:
          json['tanggal_bayar']?.toString(),

      metodeBayar:
          json['metode_bayar']?.toString(),

      jatuhTempo:
          json['jatuh_tempo']?.toString(),

      createdAt:
          json['created_at']?.toString(),

      updatedAt:
          json['updated_at']?.toString(),

      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,

      meter: json['meter'] != null
          ? MeterModel.fromJson(json['meter'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meter_id': meterId,
      'bulan': bulan,
      'tahun': tahun,
      'periode': periode,
      'pemakaian': pemakaian,
      'total_tagihan': totalTagihan,
      'tarif_per_m3': tarifPerM3,
      'status': status,
      'invoice_number': invoiceNumber,
      'tanggal_bayar': tanggalBayar,
      'metode_bayar': metodeBayar,
      'jatuh_tempo': jatuhTempo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // ==================================================
  // HELPER
  // ==================================================

  bool get isLunas =>
      status.toLowerCase() == 'lunas';

  bool get isBelumBayar =>
      status.toLowerCase() == 'belum_bayar';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'lunas':
        return 'Lunas';

      case 'belum_bayar':
        return 'Belum Bayar';

      default:
        return status;
    }
  }

  String get nominalRupiah {
    return totalTagihan.toString();
  }
}