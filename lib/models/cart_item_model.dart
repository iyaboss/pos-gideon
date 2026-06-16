class CartItemModel {
  String productId;
  String productName;
  String unitType;
  int qty;
  int unitPrice;
  int pointsPerUnit;
  int qtyPerUnit;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.unitType,
    required this.qty,
    required this.unitPrice,
    required this.pointsPerUnit,
    required this.qtyPerUnit,
  });

  int get subtotal => qty * unitPrice;
  int get pointsEarned => qty * pointsPerUnit;
  int get totalBaseQty => qty * qtyPerUnit;

  Map<String, dynamic> toTransactionItem() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_type': unitType,
      'qty': qty,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'points_earned': pointsEarned,
      'qty_per_unit': qtyPerUnit,
    };
  }
}
