class Transaction {
  final int id;
  final String timestamp;
  final double total;
  final String paymentMethod;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.total,
    required this.paymentMethod,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int? ?? 0, // Default to 0 if null
      timestamp:
      map['timestamp'] as String? ??
          DateTime.now().toIso8601String(), // Default to now
      total:
      (map['total'] as num?)?.toDouble() ??
          0.0, // Convert to double, default to 0.0
      paymentMethod:
      map['payment_method'] as String? ?? 'Unknown', // Default to 'Unknown'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'total': total,
      'payment_method': paymentMethod,
    };
  }

  Transaction copyWith({
    int? id,
    String? timestamp,
    double? total,
    String? paymentMethod,
  }) {
    return Transaction(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, timestamp: $timestamp, total: $total, paymentMethod: $paymentMethod)';
  }
}
