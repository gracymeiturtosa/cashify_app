import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.black), // Changed to black
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: screenWidth * 0.8,
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 600),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      title: Text('Accept Cash Payments', style: Theme.of(context).textTheme.headlineSmall),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      value: transactionProvider.cashEnabled,
                      onChanged: (value) {
                        transactionProvider.updateLocalSettings(value, transactionProvider.cardEnabled);
                      },
                    ),
                    const SizedBox(height: 24.0),
                    SwitchListTile(
                      title: Text('Accept Card Payments', style: Theme.of(context).textTheme.headlineSmall),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      value: transactionProvider.cardEnabled,
                      onChanged: (value) {
                        transactionProvider.updateLocalSettings(transactionProvider.cashEnabled, value);
                      },
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: transactionProvider.isLoading
                            ? null
                            : () async {
                                final dbService = DatabaseService();
                                try {
                                  await dbService.updateSettings(
                                    transactionProvider.cashEnabled,
                                    transactionProvider.cardEnabled,
                                  );
                                  await transactionProvider.refreshSettings();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Settings saved successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          transactionProvider.errorMessage ?? 'Error saving settings',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: transactionProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Color(0xFF163300)),
                              )
                            : Text('Save', style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}