import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;
  int get itemCount => _items.length;
  int get totalAmount => _items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalPoints => _items.fold(0, (sum, item) => sum + item.pointsEarned);
  int get totalBaseQty => _items.fold(0, (sum, item) => sum + item.totalBaseQty);

  void addItem(CartItemModel item) {
    final existingIndex = _items.indexWhere(
      (i) => i.productId == item.productId && i.unitType == item.unitType,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = CartItemModel(
        productId: item.productId,
        productName: item.productName,
        unitType: item.unitType,
        qty: _items[existingIndex].qty + item.qty,
        unitPrice: item.unitPrice,
        pointsPerUnit: item.pointsPerUnit,
        qtyPerUnit: item.qtyPerUnit,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void updateQty(int index, int newQty) {
    if (newQty <= 0) {
      removeItem(index);
      return;
    }
    final item = _items[index];
    _items[index] = CartItemModel(
      productId: item.productId,
      productName: item.productName,
      unitType: item.unitType,
      qty: newQty,
      unitPrice: item.unitPrice,
      pointsPerUnit: item.pointsPerUnit,
      qtyPerUnit: item.qtyPerUnit,
    );
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
