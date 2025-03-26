import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
import '../providers/inventory_provider.dart'; // For refreshing inventory after transaction

class TransactionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Product> _products = [];
  List<Map<String, dynamic>> _cart = [];
  double _total = 0.0;
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  String? _errorMessage;
  bool _cashEnabled = true;
  bool _cardEnabled = true;

  // Getters
  List<Product> get products => _products;
  List<Map<String, dynamic>> get cart => _cart;
  double get total => _total;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get cashEnabled => _cashEnabled;
  bool get cardEnabled => _cardEnabled;

  TransactionProvider() {
    loadProducts(); // Initial load of products
  }

  // Load products from the database
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _dbService.getAllProducts();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      _isLoading = false;
      _products = [];
    }
    notifyListeners();
  }

  // Add product to cart
  bool addToCart(Product product, int quantity) {
    if (quantity <= 0) {
      _errorMessage = 'Quantity must be greater than zero';
      notifyListeners();
      return false;
    }
    if (product.stock < quantity) {
      _errorMessage = 'Insufficient stock for ${product.name}';
      notifyListeners();
      return false;
    }

    final existingItemIndex =
        _cart.indexWhere((item) => item['product'].id == product.id);
    if (existingItemIndex != -1) {
      _cart[existingItemIndex]['quantity'] += quantity;
    } else {
      _cart.add({'product': product, 'quantity': quantity});
    }
    _total += product.price * quantity;
    notifyListeners();
    return true;
  }

  // Remove product from cart
  void removeFromCart(int index) {
    final item = _cart[index];
    _total -= item['product'].price * item['quantity'];
    _cart.removeAt(index);
    notifyListeners();
  }

  // Set payment method (if you want to reintroduce explicit selection later)
  void setPaymentMethod(String method) {
    if ((method == 'Cash' && _cashEnabled) ||
        (method == 'Card' && _cardEnabled)) {
      _paymentMethod = method;
      notifyListeners();
    } else {
      _errorMessage = 'Selected payment method is not enabled';
      notifyListeners();
    }
  }

  // Complete the transaction
  Future<Map<String, dynamic>> completeTransaction(BuildContext context,
      {required double cashTendered}) async {
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

    // Infer payment method: "Cash" if cashTendered > 0 and enabled, "Card" otherwise
    _paymentMethod = cashTendered > 0 && _cashEnabled
        ? 'Cash'
        : (_cardEnabled ? 'Card' : 'Cash');

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
        cashTendered,
      );

      final result = {
        'transactionId': transactionDetails['transactionId'] ?? -1,
        'total': _total,
        'cart': cartCopy,
        'paymentMethod': _paymentMethod,
        'change': transactionDetails['change'] as double,
      };

      // Clear cart and reset total
      _cart.clear();
      _total = 0.0;

      // Refresh products after transaction
      await loadProducts();

      // Refresh inventory (if InventoryProvider is used)
      final inventoryProvider =
          Provider.of<InventoryProvider>(context, listen: false);
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

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Optionally set payment method availability (if needed elsewhere)
  void setPaymentOptions({bool cashEnabled = true, bool cardEnabled = true}) {
    _cashEnabled = cashEnabled;
    _cardEnabled = cardEnabled;
    if (!_cashEnabled && _paymentMethod == 'Cash') {
      _paymentMethod = _cardEnabled ? 'Card' : 'Cash';
    } else if (!_cardEnabled && _paymentMethod == 'Card') {
      _paymentMethod = _cashEnabled ? 'Cash' : 'Card';
    }
    notifyListeners();
  }
}
