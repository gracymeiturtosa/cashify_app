import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
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

  void _refreshReport(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    reportProvider.setDateRange(_fromDate, _toDate);
  }

  Future<void> _generateTransactionPdf(BuildContext context, Map<String, dynamic> transaction) async {
    debugPrint('Generating PDF for transaction: $transaction');
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    final transactionDetails = {
      'transactionId': transaction['id'],
      'total': transaction['total'],
      'cart': transaction['cart'],
      'paymentMethod': transaction['payment_method'] ?? 'Unknown',
      'change': transaction['change'] ?? 0.0,
    };

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Ukay Ukay Receipt',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                font: font,
                color: PdfColors.green900,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Text(
              'Transaction ID: ${transactionDetails['transactionId']}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.Text(
              'Date: ${transaction['timestamp']}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.Text(
              'Payment Method: ${transactionDetails['paymentMethod']}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Items:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: font),
            ),
            pw.SizedBox(height: 8),
            transactionDetails['cart'] == null || (transactionDetails['cart'] as List).isEmpty
                ? pw.Text(
                    'No items recorded',
                    style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey),
                  )
                : pw.Table.fromTextArray(
                    headers: ['Product', 'Qty', 'Price', 'Subtotal'],
                    data: (transactionDetails['cart'] as List<Map<String, dynamic>>).map((item) {
                      final product = item['product'];
                      final quantity = item['quantity'] ?? 0;
                      final subtotal = (product['price'] ?? 0) * quantity;
                      return [
                        product['name'] ?? 'Unknown Product',
                        quantity.toString(),
                        '₱${(product['price'] ?? 0).toStringAsFixed(2)}',
                        '₱${subtotal.toStringAsFixed(2)}',
                      ];
                    }).toList(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      font: font,
                      color: PdfColors.black,
                    ),
                    cellStyle: pw.TextStyle(fontSize: 12, font: font),
                    cellAlignment: pw.Alignment.centerRight,
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    cellPadding: const pw.EdgeInsets.all(4),
                  ),
            pw.SizedBox(height: 24),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Total: ₱${transactionDetails['total'].toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                    color: PdfColors.green900,
                  ),
                ),
                if (transactionDetails['paymentMethod'] == 'Cash') ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Change: ₱${transactionDetails['change'].toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 16, font: font, color: PdfColors.green700),
                  ),
                ],
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Thank you for shopping at Ukay Ukay!',
              style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'receipt_${transactionDetails['transactionId']}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    debugPrint('Transaction Details: $transaction');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Transaction #${transaction['id']}', style: Theme.of(context).textTheme.headlineMedium),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${transaction['timestamp']}', style: Theme.of(context).textTheme.bodyMedium),
              Text('Payment Method: ${transaction['payment_method'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text('Items:', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              transaction['cart'] == null || (transaction['cart'] as List).isEmpty
                  ? Text('No items recorded', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey))
                  : Column(
                      children: (transaction['cart'] as List<Map<String, dynamic>>).map((item) {
                        final product = item['product'];
                        final quantity = item['quantity'] ?? 0;
                        final subtotal = (product['price'] ?? 0) * quantity;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${product['name'] ?? 'Unknown Product'} x$quantity',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '₱${subtotal.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                  Text('₱${transaction['total'].toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              if (transaction['payment_method'] == 'Cash') ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Change:', style: Theme.of(context).textTheme.bodyMedium),
                    Text('₱${(transaction['change'] as double).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sales Reports',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Report',
            onPressed: () => _refreshReport(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ReportProvider>(
          builder: (context, reportProvider, child) {
            debugPrint('Transactions in ReportProvider: ${reportProvider.transactions}');
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
                          style: Theme.of(context).textTheme.labelLarge, // Fixed parameter name
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
                          ? Center(
                              child: Text(
                                reportProvider.errorMessage!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              itemCount: reportProvider.selectedReport == 'Top Selling'
                                  ? reportProvider.topSellingProducts.length
                                  : reportProvider.transactions.length,
                              itemBuilder: (context, index) {
                                if (reportProvider.selectedReport == 'Top Selling') {
                                  final product = reportProvider.topSellingProducts[index];
                                  return Card(
                                    color: Theme.of(context).colorScheme.surface,
                                    child: ListTile(
                                      title: Text(product['name'],
                                          style: Theme.of(context).textTheme.headlineSmall),
                                      subtitle: Text(
                                        'Qty Sold: ${product['quantity']} | Total: ₱${product['total_sales'].toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  );
                                } else {
                                  final transaction = reportProvider.transactions[index];
                                  return Card(
                                    color: Theme.of(context).colorScheme.surface,
                                    child: ListTile(
                                      title: Text('Transaction #${transaction.id}',
                                          style: Theme.of(context).textTheme.headlineSmall),
                                      subtitle: Text(
                                        'Total: ₱${transaction.total.toStringAsFixed(2)} | ${transaction.timestamp}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.info),
                                            color: Theme.of(context).primaryColor,
                                            onPressed: () => _showTransactionDetails(context, transaction.toMap()),
                                            tooltip: 'View Details',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.print),
                                            color: Theme.of(context).primaryColor,
                                            onPressed: () => _generateTransactionPdf(context, transaction.toMap()),
                                            tooltip: 'Print Receipt',
                                          ),
                                        ],
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
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.bold),
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