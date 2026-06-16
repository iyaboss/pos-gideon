class CustomerModel {
  String? id;
  String name;
  String phone;
  String? email;
  String? address;
  int totalPoints;
  DateTime? createdAt;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.totalPoints = 0,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      totalPoints: json['total_points'] ?? 0,
      createdAt: json['created_at']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'total_points': totalPoints,
      'created_at': createdAt,
    };
  }
}
