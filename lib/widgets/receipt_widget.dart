import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptWidget extends StatelessWidget {
  final Map<String, dynamic> transactionDetails;

  const ReceiptWidget({required this.transactionDetails, super.key});

  Future<void> _generatePdf(BuildContext context) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    // Load a font that supports the peso symbol (e.g., Roboto)
    final font = await PdfGoogleFonts.robotoRegular();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text(
              'Cashify Receipt',
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
<<<<<<< HEAD
            // Transaction Details
=======
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
            pw.Text(
              'Transaction ID: ${transactionDetails['transactionId'] ?? 'N/A'}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.Text(
              'Date: ${DateTime.now().toIso8601String().substring(0, 19)}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.Text(
              'Payment Method: ${transactionDetails['paymentMethod'] ?? 'N/A'}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.SizedBox(height: 24),
<<<<<<< HEAD
            // Items Table
=======
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
            pw.Text(
              'Items:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
            ),
            pw.SizedBox(height: 8),
<<<<<<< HEAD
            transactionDetails['cart'] == null ||
                    (transactionDetails['cart'] as List).isEmpty
                ? pw.Text(
                    'No items in cart',
                    style: pw.TextStyle(
                        fontSize: 12, font: font, color: PdfColors.grey),
                  )
                : pw.Table.fromTextArray(
                    headers: ['Product', 'Qty', 'Price', 'Subtotal'],
                    data: (transactionDetails['cart']
                            as List<Map<String, dynamic>>)
                        .map((item) {
=======
            transactionDetails['cart'] == null || (transactionDetails['cart'] as List).isEmpty
                ? pw.Text(
                    'No items in cart',
                    style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey),
                  )
                : pw.Table.fromTextArray(
                    headers: ['Product', 'Qty', 'Price', 'Subtotal'],
                    data: (transactionDetails['cart'] as List<Map<String, dynamic>>).map((item) {
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
                      final product = item['product'];
                      final quantity = item['quantity'] ?? 0;
                      final subtotal = (product?.price ?? 0) * quantity;
                      return [
                        product?.name ?? 'Unknown Product',
                        quantity.toString(),
                        '₱${(product?.price ?? 0).toStringAsFixed(2)}',
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
<<<<<<< HEAD
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    cellPadding: const pw.EdgeInsets.all(4),
                  ),
            pw.SizedBox(height: 24),
            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
=======
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    cellPadding: const pw.EdgeInsets.all(4),
                  ),
            pw.SizedBox(height: 24),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
              children: [
                pw.Text(
                  'Total: ₱${(transactionDetails['total'] ?? 0).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                    color: PdfColors.green900,
                  ),
                ),
<<<<<<< HEAD
=======
                if (transactionDetails['paymentMethod'] == 'Cash') ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Change: ₱${(transactionDetails['change'] ?? 0).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      font: font,
                      color: PdfColors.green700,
                    ),
                  ),
                ],
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Thank you for using Cashify POS!',
<<<<<<< HEAD
              style: pw.TextStyle(
                  fontSize: 12, font: font, color: PdfColors.grey700),
=======
              style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey700),
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await doc.save(),
<<<<<<< HEAD
        filename:
            'receipt_${transactionDetails['transactionId'] ?? 'unknown'}.pdf',
=======
        filename: 'receipt_${transactionDetails['transactionId'] ?? 'unknown'}.pdf',
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    debugPrint(
        'Receipt Widget Build - Transaction Details: $transactionDetails');
=======
    debugPrint('Receipt Widget Build - Transaction Details: $transactionDetails');
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
    debugPrint('Receipt Widget Build - Cart: ${transactionDetails['cart']}');

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Receipt',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transactionDetails['transactionId'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Date: ${DateTime.now().toIso8601String().substring(0, 19)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Payment Method: ${transactionDetails['paymentMethod'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Items:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
<<<<<<< HEAD
              transactionDetails['cart'] == null ||
                      (transactionDetails['cart'] as List).isEmpty
                  ? Text(
                      'No items in cart',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.grey),
                    )
                  : Column(
                      children: (transactionDetails['cart']
                              as List<Map<String, dynamic>>)
                          .map((item) {
=======
              transactionDetails['cart'] == null || (transactionDetails['cart'] as List).isEmpty
                  ? Text(
                      'No items in cart',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                    )
                  : Column(
                      children: (transactionDetails['cart'] as List<Map<String, dynamic>>).map((item) {
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
                        final product = item['product'];
                        final quantity = item['quantity'] ?? 0;
                        final subtotal = (product?.price ?? 0) * quantity;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${product?.name ?? 'Unknown Product'} x$quantity',
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
              const Divider(color: Colors.grey),
              const SizedBox(height: 12),
<<<<<<< HEAD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₱${(transactionDetails['total'] ?? 0).toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
=======
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₱${(transactionDetails['total'] ?? 0).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (transactionDetails['paymentMethod'] == 'Cash') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '₱${(transactionDetails['change'] ?? 0).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _generatePdf(context),
          child: Text(
            'Save/Print',
<<<<<<< HEAD
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).primaryColor),
=======
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
>>>>>>> 9d7be7c8502db62a78fdb8bb41e7e088028d963b
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}