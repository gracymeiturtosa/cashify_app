import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class CartReviewWidget extends StatelessWidget {
  const CartReviewWidget({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Column(
      children: [
        Expanded(
          child:
          transactionProvider.cart.isEmpty
              ? const Center(child: Text('No items in cart'))
              : ListView.builder(
            itemCount: transactionProvider.cart.length,
            itemBuilder: (context, index) {
              final item = transactionProvider.cart[index];
              return ListTile(
                title: Text(item['product'].name),
                subtitle: Text(
                  'Qty: ${item['quantity']} | ₱${item['product'].price.toStringAsFixed(2)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      () => transactionProvider.removeFromCart(index),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total: ₱${transactionProvider.total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
