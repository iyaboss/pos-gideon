import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    fetchProducts();
  }

  Stream<List<ProductModel>> get productsStream {
    return _firestore
        .collection('products')
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('is_active', isEqualTo: true)
          .orderBy('name')
          .get();
      _products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String> addProduct(ProductModel product) async {
    final doc = await _firestore.collection('products').add(product.toJson());
    await fetchProducts();
    return doc.id;
  }

  Future<void> updateProduct(ProductModel product) async {
    if (product.id == null) return;
    await _firestore.collection('products').doc(product.id).update(product.toJson());
    await fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).update({'is_active': false});
    await fetchProducts();
  }
}
