class BookingModel {
  final String id;
  final String userId;
  final int villaId;

  final DateTime tglCheckin;
  final DateTime tglCheckout;

  final String statusBooking;
  final String? payment;
  final String? paymentProof;

  final int totalPrice;
  final DateTime createdAt;

  final String? villaName;
  final String? villaImage;
  final String? customerName;

  BookingModel({
    required this.id,
    required this.userId,
    required this.villaId,
    required this.tglCheckin,
    required this.tglCheckout,
    required this.statusBooking,
    this.payment,
    this.paymentProof,
    required this.totalPrice,
    required this.createdAt,

    this.villaImage,
    this.villaName,
    this.customerName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final villa = json['villa'] as Map<String, dynamic>?;
    final customer = json['profiles'] as Map<String, dynamic>?;

    return BookingModel(
      id: json['id'],
      userId: json['user_id'],
      villaId: json['villa_id'],
      tglCheckin: DateTime.parse(json['tgl_checkin']),
      tglCheckout: DateTime.parse(json['tgl_checkout']),
      statusBooking: json['status_booking'],
      payment: json['payment'],
      paymentProof: json['payment_proof'],
      totalPrice: json['total_price'],
      createdAt: DateTime.parse(json['created_at']),
      villaName: villa?['nama_villa'],
      villaImage: villa?['image'],
      customerName: customer?['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'villa_id': villaId,
      'tgl_checkin': tglCheckin.toIso8601String(),
      'tgl_checkout': tglCheckout.toIso8601String(),
      'status_booking': statusBooking,
      'payment': payment,
      'payment_proof': paymentProof,
      'total_price': totalPrice,
      'created_at': createdAt,
    };
  }
}