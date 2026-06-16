class TransactionModel {
  String? id;
  String customerId;
  String customerName;
  String kasirId;
  DateTime? timestamp;
  List<Map<String, dynamic>> items;
  int totalAmount;
  int totalPointsEarned;
  String paymentMethod;
  String status;

  TransactionModel({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.kasirId,
    this.timestamp,
    required this.items,
    required this.totalAmount,
    required this.totalPointsEarned,
    this.paymentMethod = 'cash',
    this.status = 'completed',
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id,
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      kasirId: json['kasir_id'],
      timestamp: json['timestamp']?.toDate(),
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      totalAmount: json['total_amount'],
      totalPointsEarned: json['total_points_earned'],
      paymentMethod: json['payment_method'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'kasir_id': kasirId,
      'timestamp': timestamp,
      'items': items,
      'total_amount': totalAmount,
      'total_points_earned': totalPointsEarned,
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}
