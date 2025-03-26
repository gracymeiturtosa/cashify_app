import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/product_model.dart';

class ProductSelectionWidget extends StatefulWidget {
  final List<Product>? filteredProducts;
  const ProductSelectionWidget({super.key, this.filteredProducts});

  @override
  _ProductSelectionWidgetState createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends State<ProductSelectionWidget> {
  final Map<int, TextEditingController> _quantityControllers = {};

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final productsToDisplay = widget.filteredProducts ?? transactionProvider.products;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: productsToDisplay.isEmpty
                  ? Center(child: Text('No matching products', style: Theme.of(context).textTheme.bodyMedium))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productsToDisplay.length,
                      itemBuilder: (context, index) {
                        final product = productsToDisplay[index];
                        _quantityControllers.putIfAbsent(
                          product.hashCode,
                          () => TextEditingController(),
                        );
                        final quantityController = _quantityControllers[product.hashCode]!;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Theme.of(context).colorScheme.surface, // Lighter Base Dark
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        product.name,
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Price: ₱${product.price.toStringAsFixed(2)} | Stock: ${product.stock}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: const Color(0xFF868685)), // Interactive Secondary
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller: quantityController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Qty',
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: const Color(0xFF868685)),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF868685), // Interactive Secondary
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                          ),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_shopping_cart),
                                        color: Colors.white, // Changed from Forest Green to White
                                        iconSize: 28,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _addToCart(
                                          transactionProvider,
                                          product,
                                          quantityController,
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(
    TransactionProvider provider,
    Product product,
    TextEditingController controller,
    BuildContext context,
  ) {
    final quantity = int.tryParse(controller.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid quantity', style: Theme.of(context).textTheme.bodyMedium),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final success = provider.addToCart(product, quantity);
      if (success) {
        controller.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to add to cart',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              textColor: Theme.of(context).colorScheme.secondary, // Forest Green
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }
}