class PaymentModel {
  final int id;
  final int tagihanId;

  final String invoiceId;
  final String paymentGateway;
  final int amount;
  final String metodePembayaran;
  final String status;
  final String? paymentUrl;
  final String? paidAt;

  final String? createdAt;
  final String? updatedAt;

  PaymentModel({
    required this.id,
    required this.tagihanId,
    required this.invoiceId,
    required this.paymentGateway,
    required this.amount,
    required this.metodePembayaran,
    required this.status,
    this.paymentUrl,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      tagihanId: int.tryParse(json['tagihan_id'].toString()) ?? 0,
      invoiceId: json['invoice_id']?.toString() ?? '',
      paymentGateway: json['payment_gateway']?.toString() ?? 'dompetx',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      metodePembayaran: json['metode_pembayaran']?.toString() ?? 'checkout',
      status: json['status']?.toString() ?? 'pending',
      paymentUrl: json['payment_url']?.toString(),
      paidAt: json['paid_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagihan_id': tagihanId,
      'invoice_id': invoiceId,
      'payment_gateway': paymentGateway,
      'amount': amount,
      'metode_pembayaran': metodePembayaran,
      'status': status,
      'payment_url': paymentUrl,
      'paid_at': paidAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isPaid => status.toLowerCase() == 'paid';

  bool get isFailed =>
      status.toLowerCase() == 'failed' ||
      status.toLowerCase() == 'expired' ||
      status.toLowerCase() == 'cancelled';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Lunas';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'failed':
        return 'Gagal';
      case 'expired':
        return 'Kedaluwarsa';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}