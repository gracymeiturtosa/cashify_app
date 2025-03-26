import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/receipt_widget.dart'; // Adjust import as needed
import '../widgets/payment_processing_widget.dart'; // Adjust import as needed

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  String _sortOption = 'Name (A-Z)';
  final Map<int, TextEditingController> _quantityControllers = {};

  @override
  void dispose() {
    _searchController.dispose();
    _cashController.dispose();
    _quantityControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Name (A-Z)'),
              onTap: () {
                setState(() => _sortOption = 'Name (A-Z)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Name (Z-A)'),
              onTap: () {
                setState(() => _sortOption = 'Name (Z-A)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price (Low to High)'),
              onTap: () {
                setState(() => _sortOption = 'Price (Low to High)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price (High to Low)'),
              onTap: () {
                setState(() => _sortOption = 'Price (High to Low)');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Transaction',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage != null) {
                return Center(
                  child: Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              List<Product> filteredProducts = provider.products
                  .where((product) => product.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .toList();

              switch (_sortOption) {
                case 'Name (A-Z)':
                  filteredProducts.sort((a, b) => a.name.compareTo(b.name));
                  break;
                case 'Name (Z-A)':
                  filteredProducts.sort((a, b) => b.name.compareTo(a.name));
                  break;
                case 'Price (Low to High)':
                  filteredProducts.sort((a, b) => a.price.compareTo(b.price));
                  break;
                case 'Price (High to Low)':
                  filteredProducts.sort((a, b) => b.price.compareTo(a.price));
                  break;
              }

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth * 0.02),
                        IconButton(
                          icon: const Icon(Icons.sort),
                          onPressed: () => _showSortOptions(context),
                          tooltip: 'Sort',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * 0.3,
                              child: ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  _quantityControllers.putIfAbsent(
                                    product.id,
                                    () => TextEditingController(), // No default value
                                  );
                                  return Card(
                                    child: ListTile(
                                      title: Text(product.name),
                                      subtitle: Text(
                                          'Price: ₱${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            child: TextField(
                                              controller: _quantityControllers[product.id],
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                hintText: 'Qty',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_shopping_cart),
                                            onPressed: () {
                                              final qty = int.tryParse(
                                                      _quantityControllers[product.id]!.text) ??
                                                  1; // Default to 1 if empty or invalid
                                              final success = provider.addToCart(product, qty);
                                              if (!success && context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(provider.errorMessage ??
                                                        'Failed to add to cart'),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            Text(
                              'Cart',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.01),
                            SizedBox(
                              height: constraints.maxHeight * 0.2,
                              child: ListView.builder(
                                itemCount: provider.cart.length,
                                itemBuilder: (context, index) {
                                  final item = provider.cart[index];
                                  final product = item['product'] as Product;
                                  final quantity = item['quantity'] as int;
                                  return ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(
                                        'Qty: $quantity | ₱${(product.price * quantity).toStringAsFixed(2)}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      onPressed: () => provider.removeFromCart(index),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            Container(
                              padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Total: ₱${provider.total.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: constraints.maxHeight * 0.015),
                                  TextField(
                                    controller: _cashController,
                                    decoration: InputDecoration(
                                      labelText: 'Cash Tendered',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                  SizedBox(height: constraints.maxHeight * 0.015),
                                  Consumer<TransactionProvider>(
                                    builder: (context, provider, child) {
                                      double cash = double.tryParse(_cashController.text) ?? 0.0;
                                      double change = cash - provider.total;
                                      return Text(
                                        'Change: ₱${change >= 0 ? change.toStringAsFixed(2) : 'Insufficient'}',
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                              color: change >= 0 ? Colors.green : Colors.red,
                                            ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                  SizedBox(height: constraints.maxHeight * 0.015),
                                  PaymentProcessingWidget(
                                    onComplete: () async {
                                      final cashTendered = double.tryParse(_cashController.text) ?? 0.0;
                                      final transactionDetails = await provider.completeTransaction(
                                        context,
                                        cashTendered: cashTendered,
                                      );
                                      if (context.mounted && transactionDetails['transactionId'] != -1) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Transaction Completed')),
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (_) => ReceiptWidget(transactionDetails: transactionDetails),
                                        ).then((_) => Navigator.pop(context));
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(provider.errorMessage ?? 'Transaction failed'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}