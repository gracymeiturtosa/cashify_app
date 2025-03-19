import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/product_selection_widget.dart';
import '../widgets/cart_review_widget.dart';
import '../widgets/payment_processing_widget.dart';
import '../widgets/receipt_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortOption = 'name_asc';

  @override
  void dispose() {
    _cashController.dispose();
    _searchController.dispose();
    ScaffoldMessenger.of(context).clearSnackBars();
    Provider.of<TransactionProvider>(context, listen: false).clearError();
    super.dispose();
  }

  List<Product> _sortProducts(List<Product> products) {
    switch (_sortOption) {
      case 'name_asc':
        return products..sort((a, b) => a.name.compareTo(b.name));
      case 'name_desc':
        return products..sort((a, b) => b.name.compareTo(a.name));
      case 'price_asc':
        return products..sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        return products..sort((a, b) => b.price.compareTo(a.price));
      case 'stock_asc':
        return products..sort((a, b) => a.stock.compareTo(b.stock));
      case 'stock_desc':
        return products..sort((a, b) => b.stock.compareTo(a.stock));
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction',
            style: Theme.of(context).textTheme.headlineLarge),
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

              final searchedProducts = provider.products
                  .where((p) =>
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();
              final sortedProducts = _sortProducts(searchedProducts);

              return Column(
                children: [
                  // Search and Sort Header
                  Container(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.1),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search Products',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.grey[400],
                                ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showSortOptions(context),
                              icon: const Icon(Icons.sort, size: 20),
                              label: Text('Sort',
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.03,
                                  vertical: constraints.maxHeight * 0.015,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Product Selection
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight *
                                    0.6, // 60% of screen height
                              ),
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SingleChildScrollView(
                                child: sortedProducts.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Center(
                                          child: Text(
                                            'No products match your search',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      )
                                    : ProductSelectionWidget(
                                        filteredProducts: sortedProducts),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            // Cart Review
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight *
                                    0.4, // 40% of screen height
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CartReviewWidget(),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            // Payment Section
                            Container(
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _cashController,
                                    decoration: InputDecoration(
                                      labelText: 'Cash Tendered',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.5),
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.015),
                                  Consumer<TransactionProvider>(
                                    builder: (context, provider, child) {
                                      double total = provider.total;
                                      double cash = double.tryParse(
                                              _cashController.text) ??
                                          0.0;
                                      double change = cash - total;
                                      return Text(
                                        'Change: ₱${change >= 0 ? change.toStringAsFixed(2) : 'Insufficient'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: change >= 0
                                                  ? const Color(0xFF2F5711)
                                                  : const Color(0xFFA8200D),
                                            ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.015),
                                  PaymentProcessingWidget(
                                    onComplete: () async {
                                      final transactionDetails =
                                          await transactionProvider
                                              .completeTransaction(context);
                                      if (context.mounted &&
                                          transactionDetails['transactionId'] !=
                                              -1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Transaction Completed')),
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (_) => ReceiptWidget(
                                              transactionDetails:
                                                  transactionDetails),
                                        ).then((_) => Navigator.pop(context));
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              transactionProvider
                                                      .errorMessage ??
                                                  'Transaction failed',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
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

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Sort Products',
            style: Theme.of(context).textTheme.headlineMedium),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Name (A-Z)',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  setState(() => _sortOption = 'name_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Name (Z-A)',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  setState(() => _sortOption = 'name_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Price (Low to High)',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  setState(() => _sortOption = 'price_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Price (High to Low)',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  setState(() => _sortOption = 'price_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Stock (Low to High)',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  setState(() => _sortOption = 'stock_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Stock (High to Low)',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  setState(() => _sortOption = 'stock_desc');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
