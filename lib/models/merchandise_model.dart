class MerchandiseModel {
  String? id;
  String name;
  String? imageUrl;
  int pointsRequired;
  int stock;
  bool isActive;

  MerchandiseModel({
    this.id,
    required this.name,
    this.imageUrl,
    required this.pointsRequired,
    required this.stock,
    this.isActive = true,
  });

  factory MerchandiseModel.fromJson(Map<String, dynamic> json, String id) {
    return MerchandiseModel(
      id: id,
      name: json['name'],
      imageUrl: json['image_url'],
      pointsRequired: json['points_required'] ?? 0,
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'points_required': pointsRequired,
      'stock': stock,
      'is_active': isActive,
    };
  }

  bool get isAvailable => isActive && stock > 0;
}
