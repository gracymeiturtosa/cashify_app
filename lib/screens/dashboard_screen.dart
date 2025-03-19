import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'transaction_screen.dart';
import 'inventory_management_screen.dart';
import 'sales_report_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth * 0.8).clamp(200.0, 400.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cashify', style: Theme.of(context).textTheme.headlineLarge),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E231F), Color(0xFF121511)], // Lighter Base Dark to Base Dark
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: _buildMenuButton(context,
                      title: 'New Transaction',
                      icon: Icons.add_shopping_cart,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransactionScreen()),
                      )),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: buttonWidth,
                  child: _buildMenuButton(context,
                      title: 'Inventory Management',
                      icon: Icons.inventory,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InventoryManagementScreen()),
                      )),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: buttonWidth,
                  child: _buildMenuButton(context,
                      title: 'Sales Reports',
                      icon: Icons.bar_chart,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                      )),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: buttonWidth,
                  child: _buildMenuButton(context,
                      title: 'Settings',
                      icon: Icons.settings,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      )),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: buttonWidth,
                  child: _buildMenuButton(context,
                      title: 'Log Out',
                      icon: Icons.logout,
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28.0),
      label: Text(title, style: Theme.of(context).textTheme.labelLarge),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }
}