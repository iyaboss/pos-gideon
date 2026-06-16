import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTransaction({
    required String customerId,
    required String customerName,
    required String kasirId,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required int totalPoints,
    required String paymentMethod,
  }) async {
    return await _firestore.runTransaction((transaction) async {
      final transRef = _firestore.collection('transactions').doc();
      transaction.set(transRef, {
        'customer_id': customerId,
        'customer_name': customerName,
        'kasir_id': kasirId,
        'timestamp': FieldValue.serverTimestamp(),
        'items': items,
        'total_amount': totalAmount,
        'total_points_earned': totalPoints,
        'payment_method': paymentMethod,
        'status': 'completed',
      });

      final customerRef = _firestore.collection('customers').doc(customerId);
      final customerSnap = await transaction.get(customerRef);
      final currentPoints = (customerSnap.data()?['total_points'] ?? 0) as int;
      transaction.update(customerRef, {
        'total_points': currentPoints + totalPoints,
      });

      for (var item in items) {
        final productRef = _firestore.collection('products').doc(item['product_id']);
        final productSnap = await transaction.get(productRef);
        final currentStock = (productSnap.data()?['stock_base'] ?? 0) as int;
        final qtyUsed = (item['qty'] as int) * (item['qty_per_unit'] as int);
        transaction.update(productRef, {
          'stock_base': currentStock - qtyUsed,
        });
      }

      return transRef.id;
    });
  }

  Future<String> redeemMerchandise({
    required String customerId,
    required String merchId,
    required String merchName,
    required int pointsRequired,
  }) async {
    return await _firestore.runTransaction((transaction) async {
      final customerRef = _firestore.collection('customers').doc(customerId);
      final customerSnap = await transaction.get(customerRef);
      final currentPoints = (customerSnap.data()?['total_points'] ?? 0) as int;

      if (currentPoints < pointsRequired) {
        throw Exception('Poin tidak mencukupi! Sisa poin: $currentPoints');
      }

      final merchRef = _firestore.collection('merchandise').doc(merchId);
      final merchSnap = await transaction.get(merchRef);
      final currentStock = (merchSnap.data()?['stock'] ?? 0) as int;

      if (currentStock <= 0) {
        throw Exception('Stok merchandise habis!');
      }

      transaction.update(customerRef, {
        'total_points': currentPoints - pointsRequired,
      });

      transaction.update(merchRef, {
        'stock': currentStock - 1,
      });

      final redeemRef = _firestore.collection('redemptions').doc();
      transaction.set(redeemRef, {
        'customer_id': customerId,
        'merch_id': merchId,
        'merch_name': merchName,
        'points_used': pointsRequired,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      return redeemRef.id;
    });
  }

  Stream<List<Map<String, dynamic>>> getTransactionsStream({DateTime? startDate}) {
    Query query = _firestore.collection('transactions')
        .orderBy('timestamp', descending: true);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    final snapshot = await _firestore
        .collection('customers')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '${query}\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> getCustomersStream() {
    return _firestore
        .collection('customers')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> getMerchandiseStream() {
    return _firestore
        .collection('merchandise')
        .where('is_active', isEqualTo: true)
        .orderBy('points_required')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }
}
