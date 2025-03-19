import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class ReportDisplayWidget extends StatelessWidget {
  const ReportDisplayWidget({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    if (reportProvider.selectedReport == 'Top Selling') {
      return ListView.builder(
        itemCount: reportProvider.topSellingProducts.length,
        itemBuilder: (context, index) {
          final product = reportProvider.topSellingProducts[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              title: Text(product['name']),
              subtitle: Text(
                'Sold: ${product['quantity']} | Total: ₱${product['total_sales'].toStringAsFixed(2)}',
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: reportProvider.transactions.length,
        itemBuilder: (context, index) {
          final transaction = reportProvider.transactions[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              title: Text('Transaction #${transaction.id}'),
              subtitle: Text(
                'Total: ₱${transaction.total.toStringAsFixed(2)} | ${transaction.timestamp}',
              ),
            ),
          );
        },
      );
    }
  }
}
