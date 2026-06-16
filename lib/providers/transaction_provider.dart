import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String> createTransaction({
    required String customerId,
    required String customerName,
    required String kasirId,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required int totalPoints,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final transactionId = await _firebaseService.createTransaction(
        customerId: customerId,
        kasirId: kasirId,
        items: items,
        totalAmount: totalAmount,
        totalPoints: totalPoints,
        paymentMethod: paymentMethod,
        customerName: customerName,
      );
      _isLoading = false;
      notifyListeners();
      return transactionId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> redeemMerchandise({
    required String customerId,
    required String merchId,
    required String merchName,
    required int pointsRequired,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final redemptionId = await _firebaseService.redeemMerchandise(
        customerId: customerId,
        merchId: merchId,
        merchName: merchName,
        pointsRequired: pointsRequired,
      );
      _isLoading = false;
      notifyListeners();
      return redemptionId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<TransactionModel>> getTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _firebaseService.getTransactionsStream(startDate: startOfDay);
  }
}
