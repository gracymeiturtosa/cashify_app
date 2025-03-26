import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
import 'inventory_provider.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Product> _products = [];
  final List<Map<String, dynamic>> _cart = [];
  double _total = 0.0;
  String _paymentMethod = 'Cash';
  bool _cashEnabled = true;
  bool _cardEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Map<String, dynamic>> get cart => _cart;
  double get total => _total;
  bool get cashEnabled => _cashEnabled;
  bool get cardEnabled => _cardEnabled;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionProvider() {
    _loadProducts();
    _loadSettings();
  }

  Future<void> _loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _dbService.getProducts();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      _isLoading = false;
      _products = [];
    }
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _dbService.getSettings();
      _cashEnabled = settings['cash_enabled'] == 1;
      _cardEnabled = settings['card_enabled'] == 1;
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      _cashEnabled = true;
      _cardEnabled = false;
    }
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await _loadProducts();
  }

  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  void updateLocalSettings(bool cashEnabled, bool cardEnabled) {
    _cashEnabled = cashEnabled;
    _cardEnabled = cardEnabled;
    notifyListeners();
  }

  bool addToCart(Product product, int quantity) {
    if (quantity <= 0) {
      _errorMessage = 'Quantity must be greater than 0';
      notifyListeners();
      return false;
    }

    final existingItemIndex = _cart.indexWhere(
      (item) => item['product'].id == product.id,
    );
    final currentQuantity =
        existingItemIndex >= 0 ? _cart[existingItemIndex]['quantity'] : 0;
    final totalRequestedQuantity = currentQuantity + quantity;

    if (totalRequestedQuantity > product.stock) {
      _errorMessage =
          'Not enough stock for ${product.name} (Available: ${product.stock})';
      notifyListeners();
      return false;
    }

    if (existingItemIndex >= 0) {
      _cart[existingItemIndex]['quantity'] = totalRequestedQuantity;
    } else {
      _cart.add({'product': product, 'quantity': quantity});
    }
    _total += product.price * quantity;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cart.length) {
      final item = _cart[index];
      _total -= item['product'].price * item['quantity'];
      _cart.removeAt(index);
      _errorMessage = null;
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> completeTransaction(BuildContext context, {required double cashTendered}) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return {
        'transactionId': -1,
        'total': 0.0,
        'cart': [],
        'paymentMethod': _paymentMethod,
        'change': 0.0,
      };
    }

    if (_paymentMethod == 'Cash' && cashTendered < _total) {
      _errorMessage = 'Insufficient cash tendered';
      _isLoading = false;
      notifyListeners();
      return {
        'transactionId': -1,
        'total': 0.0,
        'cart': [],
        'paymentMethod': _paymentMethod,
        'change': 0.0,
      };
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cartCopy = List<Map<String, dynamic>>.from(_cart);
      
      final transactionDetails = await _dbService.insertTransaction(
        _total,
        _paymentMethod,
        cartCopy,
        cashTendered, // Pass cashTendered to DatabaseService
      );

      final result = {
        'transactionId': transactionDetails['transactionId'] ?? -1,
        'total': _total,
        'cart': cartCopy,
        'paymentMethod': _paymentMethod,
        'change': transactionDetails['change'] as double, // Use change from DatabaseService
      };

      _cart.clear();
      _total = 0.0;
      await _loadProducts();

      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );
      await inventoryProvider.refreshProducts();

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Transaction failed: $e';
      _isLoading = false;
      notifyListeners();
      return {
        'transactionId': -1,
        'total': 0.0,
        'cart': [],
        'paymentMethod': _paymentMethod,
        'change': 0.0,
      };
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}