import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class InventoryListWidget extends StatelessWidget {
  const InventoryListWidget({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return inventoryProvider.products.isEmpty
        ? const Center(child: Text('No products available'))
        : ListView.builder(
      scrollDirection: Axis.vertical, // Changed to vertical for mobile
      itemCount: inventoryProvider.products.length,
      itemBuilder: (context, index) {
        final product = inventoryProvider.products[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 8.0,
          ),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(
              'Price: ₱${product.price.toStringAsFixed(2)} | Stock: ${product.stock}',
            ),
          ),
        );
      },
    );
  }
}
