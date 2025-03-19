import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptWidget extends StatelessWidget {
  final Map<String, dynamic> transactionDetails;

  const ReceiptWidget({required this.transactionDetails, super.key});

  Future<void> _generatePdf(BuildContext context) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Ukay-Ukay Receipt',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Transaction ID: ${transactionDetails['transactionId']}',
            ),
            pw.Text(
              'Date: ${DateTime.now().toIso8601String().substring(0, 19)}',
            ),
            pw.Text(
              'Payment Method: ${transactionDetails['paymentMethod']}',
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Product', 'Qty', 'Price', 'Subtotal'],
              data:
              (transactionDetails['cart'] as List<Map<String, dynamic>>)
                  .map((item) {
                final subtotal =
                    item['product'].price * item['quantity'];
                return [
                  item['product'].name,
                  item['quantity'].toString(),
                  '₱${item['product'].price.toStringAsFixed(2)}',
                  '₱${subtotal.toStringAsFixed(2)}',
                ];
              })
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerRight,
              cellStyle: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total: ₱${transactionDetails['total'].toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'receipt_${transactionDetails['transactionId']}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Receipt'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${transactionDetails['transactionId']}'),
            Text('Date: ${DateTime.now().toIso8601String().substring(0, 19)}'),
            Text('Payment Method: ${transactionDetails['paymentMethod']}'),
            const SizedBox(height: 10),
            ...(transactionDetails['cart'] as List<Map<String, dynamic>>).map((
                item,
                ) {
              final subtotal = item['product'].price * item['quantity'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '${item['product'].name} x${item['quantity']} - ₱${subtotal.toStringAsFixed(2)}',
                ),
              );
            }),
            const SizedBox(height: 10),
            Text(
              'Total: ₱${transactionDetails['total'].toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _generatePdf(context),
          child: const Text('Save/Print'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
