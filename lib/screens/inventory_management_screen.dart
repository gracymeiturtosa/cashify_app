import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/product_model.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  _InventoryManagementScreenState createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  String _searchQuery = '';
  String _sortBy = 'Name';
  bool _sortAscending = true;

  void _showEditDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Edit Product', style: Theme.of(context).textTheme.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: stockController,
              decoration: InputDecoration(
                labelText: 'Stock',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () async {
              final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
              try {
                final success = await inventoryProvider.updateProduct(
                  product.id,
                  nameController.text,
                  double.parse(priceController.text),
                  int.parse(stockController.text),
                );
                if (success && context.mounted) {
                  await Provider.of<TransactionProvider>(context, listen: false).refreshProducts();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(inventoryProvider.errorMessage ?? 'Invalid input')),
                  );
                }
              }
            },
            child: Text('Save', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  List<Product> _sortProducts(List<Product> products) {
    final sortedProducts = List<Product>.from(products);
    switch (_sortBy) {
      case 'Name':
        sortedProducts.sort((a, b) => _sortAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'Price':
        sortedProducts.sort((a, b) => _sortAscending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
        break;
      case 'Stock':
        sortedProducts.sort((a, b) => _sortAscending ? a.stock.compareTo(b.stock) : b.stock.compareTo(a.stock));
        break;
    }
    return sortedProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stock Management',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.black), // Changed to black
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Products',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16.0),
            _buildAddProductForm(context, Provider.of<InventoryProvider>(context, listen: false)),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                    DropdownMenuItem(value: 'Price', child: Text('Sort by Price')),
                    DropdownMenuItem(value: 'Stock', child: Text('Sort by Stock')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value ?? 'Name'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () => setState(() => _sortAscending = !_sortAscending),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!, style: Theme.of(context).textTheme.bodyMedium));
                  }
                  final filteredProducts =
                      provider.products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  final sortedProducts = _sortProducts(filteredProducts);

                  return ListView.builder(
                    itemCount: sortedProducts.length,
                    itemBuilder: (context, index) {
                      final product = sortedProducts[index];
                      return Card(
                        color: Theme.of(context).colorScheme.surface,
                        child: ListTile(
                          title: Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                          subtitle: Text(
                            'Price: ${product.price.toStringAsFixed(2)} | Stock: ${product.stock}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDelete(context, product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductForm(BuildContext context, InventoryProvider provider) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              border: const OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: 'Price',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              border: const OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: TextField(
            controller: stockController,
            decoration: InputDecoration(
              labelText: 'Stock',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              border: const OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10.0),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  if (nameController.text.isEmpty || priceController.text.isEmpty || stockController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
                    return;
                  }
                  try {
                    final success = await provider.addProduct(
                      nameController.text,
                      double.parse(priceController.text),
                      int.parse(stockController.text),
                    );
                    if (success && context.mounted) {
                      await Provider.of<TransactionProvider>(context, listen: false).refreshProducts();
                      nameController.clear();
                      priceController.clear();
                      stockController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product added successfully')),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.errorMessage ?? 'Unknown error')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.errorMessage ?? 'Invalid input')),
                      );
                    }
                  }
                },
          child: provider.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF163300)))
              : Text('Add', style: Theme.of(context).textTheme.labelLarge),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Product', style: Theme.of(context).textTheme.headlineMedium),
        content: Text('Are you sure you want to delete ${product.name}?',
            style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final success = await inventoryProvider.deleteProduct(product.id);
      if (success && context.mounted) {
        await Provider.of<TransactionProvider>(context, listen: false).refreshProducts();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully')));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(inventoryProvider.errorMessage ?? 'Failed to delete product')),
        );
      }
    }
  }
}