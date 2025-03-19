import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';

class ReportProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Transaction> _transactions = [];
  List<Map<String, dynamic>> _topSellingProducts = [];
  String _selectedReport = 'Transactions';
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  List<Transaction> get transactions => _transactions;
  List<Map<String, dynamic>> get topSellingProducts => _topSellingProducts;
  String get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalSales {
    if (_selectedReport == 'Top Selling') {
      return _topSellingProducts.fold(0.0, (sum, p) => sum + (p['total_sales'] as double));
    } else {
      return _transactions.fold(0.0, (sum, t) => sum + t.total);
    }
  }

  ReportProvider() {
    _loadReport();
  }

  void setReportType(String type) {
    _selectedReport = type;
    _loadReport();
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    _loadReport();
  }

  Future<void> _loadReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedReport == 'Top Selling') {
        _topSellingProducts = await _dbService.getTopSellingProducts(_fromDate, _toDate);
        _transactions = [];
      } else {
        _transactions = await _dbService.getTransactionsByPeriod(_fromDate, _toDate);
        _topSellingProducts = [];
      }
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load report: $e';
      _isLoading = false;
      _transactions = [];
      _topSellingProducts = [];
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}