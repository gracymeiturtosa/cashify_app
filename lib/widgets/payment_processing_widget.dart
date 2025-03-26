import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class PaymentProcessingWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const PaymentProcessingWidget({super.key, required this.onComplete});

  @override
  _PaymentProcessingWidgetState createState() => _PaymentProcessingWidgetState();
}

class _PaymentProcessingWidgetState extends State<PaymentProcessingWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final availableMethods = <String>[];
        if (transactionProvider.cashEnabled) availableMethods.add('Cash');
        if (transactionProvider.cardEnabled) availableMethods.add('Card');

        String? initialValue = availableMethods.isNotEmpty
            ? (availableMethods.contains(transactionProvider.paymentMethod)
            ? transactionProvider.paymentMethod
            : availableMethods.first)
            : null;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (availableMethods.isEmpty)
                Text(
                  'No payment methods enabled',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: const Color(0xFFA8200D)), // Sentiment Negative
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary, // Forest Green
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    value: initialValue,
                    items: availableMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method, style: Theme.of(context).textTheme.bodyMedium),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        transactionProvider.setPaymentMethod(value);
                      }
                    },
                    underline: const SizedBox.shrink(),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).colorScheme.surface, // Lighter Base Dark
                  ),
                ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: availableMethods.isEmpty || transactionProvider.isLoading
                      ? null
                      : widget.onComplete,
                  child: transactionProvider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF163300), // Forest Green
                    ),
                  )
                      : Text(
                    'Complete Transaction',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}