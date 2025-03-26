class Transaction {
  final int id;
  final String timestamp;
  final double total;
  final String paymentMethod;
  final double change; // Added change field
  final List<Map<String, dynamic>> cart;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.total,
    required this.paymentMethod,
    required this.change, // Required field
    this.cart = const [],
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int? ?? 0,
      timestamp: map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] as String? ?? 'Unknown',
      change: (map['change'] as num?)?.toDouble() ?? 0.0, // Parse change
      cart: (map['cart'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'total': total,
      'payment_method': paymentMethod,
      'change': change, // Include change
      'cart': cart,
    };
  }

  Transaction copyWith({
    int? id,
    String? timestamp,
    double? total,
    String? paymentMethod,
    double? change, // Added change
    List<Map<String, dynamic>>? cart,
  }) {
    return Transaction(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      change: change ?? this.change, // Use new change or existing
      cart: cart ?? this.cart,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, timestamp: $timestamp, total: $total, paymentMethod: $paymentMethod, change: $change, cart: $cart)';
  }
}