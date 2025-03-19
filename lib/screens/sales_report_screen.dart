import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      reportProvider.setDateRange(_fromDate, _toDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Reports', style: Theme.of(context).textTheme.headlineLarge),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ReportProvider>(
          builder: (context, reportProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          'From: ${_fromDate.toString().substring(0, 10)}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          'To: ${_toDate.toString().substring(0, 10)}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: reportProvider.selectedReport,
                  items: const [
                    DropdownMenuItem(value: 'Transactions', child: Text('Transactions')),
                    DropdownMenuItem(value: 'Top Selling', child: Text('Top Selling Products')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      reportProvider.setReportType(value);
                    }
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: reportProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : reportProvider.errorMessage != null
                      ? Center(child: Text(reportProvider.errorMessage!, style: Theme.of(context).textTheme.bodyMedium))
                      : ListView.builder(
                    itemCount: reportProvider.selectedReport == 'Top Selling'
                        ? reportProvider.topSellingProducts.length
                        : reportProvider.transactions.length,
                    itemBuilder: (context, index) {
                      if (reportProvider.selectedReport == 'Top Selling') {
                        final product = reportProvider.topSellingProducts[index];
                        return Card(
                          color: Theme.of(context).colorScheme.surface, // Lighter Base Dark
                          child: ListTile(
                            title: Text(product['name'], style: Theme.of(context).textTheme.headlineSmall),
                            subtitle: Text(
                              'Qty Sold: ${product['quantity']} | Total: ₱${product['total_sales'].toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        );
                      } else {
                        final transaction = reportProvider.transactions[index];
                        return Card(
                          color: Theme.of(context).colorScheme.surface, // Lighter Base Dark
                          child: ListTile(
                            title: Text('Transaction #${transaction.id}',
                                style: Theme.of(context).textTheme.headlineSmall),
                            subtitle: Text(
                              'Total: ₱${transaction.total.toStringAsFixed(2)} | ${transaction.timestamp}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Total Sales: ₱${reportProvider.totalSales.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}