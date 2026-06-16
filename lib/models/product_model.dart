class ProductModel {
  String? id;
  String name;
  String baseUnit;
  String? imageUrl;
  Map<String, ProductVariant> variants;
  int stockBase;
  bool isActive;

  ProductModel({
    this.id,
    required this.name,
    this.baseUnit = 'pcs',
    this.imageUrl,
    required this.variants,
    this.stockBase = 0,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      name: json['name'],
      baseUnit: json['base_unit'] ?? 'pcs',
      imageUrl: json['image_url'],
      variants: (json['variants'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ProductVariant.fromJson(value)),
          ) ??
          {},
      stockBase: json['stock_base'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'base_unit': baseUnit,
      'image_url': imageUrl,
      'variants': variants.map((key, value) => MapEntry(key, value.toJson())),
      'stock_base': stockBase,
      'is_active': isActive,
    };
  }

  int getStockInUnit(String unitType) {
    if (unitType == baseUnit) return stockBase;
    final variant = variants[unitType];
    if (variant == null) return 0;
    return stockBase ~/ variant.qtyPerUnit;
  }

  void reduceStock(int qty, String unitType) {
    if (unitType == baseUnit) {
      stockBase -= qty;
    } else {
      final variant = variants[unitType];
      if (variant != null) {
        stockBase -= (qty * variant.qtyPerUnit);
      }
    }
  }
}

class ProductVariant {
  int qtyPerUnit;
  int price;
  int points;

  ProductVariant({
    required this.qtyPerUnit,
    required this.price,
    required this.points,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      qtyPerUnit: json['qty_per_unit'] ?? 0,
      price: json['price'] ?? 0,
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qty_per_unit': qtyPerUnit,
      'price': price,
      'points': points,
    };
  }
}
