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
        title: Text(
          'Cashify App',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.black), // Already black
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E231F), Color(0xFF121511)],
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
                      title: 'Stock Management',
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E231F),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF9FE870),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cashify Menu',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF163300),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'General POS System',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF163300),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: Text('About the App', style: Theme.of(context).textTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified, color: Colors.white),
            title: Text('Version', style: Theme.of(context).textTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              _showVersionDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule, color: Colors.white),
            title: Text('Rules and Regulations', style: Theme.of(context).textTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              _showRulesDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.white),
            title: Text('Our Team', style: Theme.of(context).textTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              _showTeamDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E231F),
        title: Text('About the App', style: Theme.of(context).textTheme.headlineMedium),
        content: Text(
          'Cashify is a versatile Point of Sale (POS) application designed to streamline transactions, manage inventory, and generate sales reports for any retail business.',
          style: Theme.of(context).textTheme.bodyMedium,
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

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E231F),
        title: Text('Version', style: Theme.of(context).textTheme.headlineMedium),
        content: Text(
          'Cashify App Version: 1.0.0+1',
          style: Theme.of(context).textTheme.bodyMedium,
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

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E231F),
        title: Text('Rules and Regulations', style: Theme.of(context).textTheme.headlineMedium),
        content: SingleChildScrollView(
          child: Text(
            '''
            1. Authorized Use: Only authorized personnel may operate this POS system.
            2. Data Integrity: Ensure all transaction and inventory data is entered accurately.
            3. Transaction Policy: All sales are final unless otherwise specified by management.
            4. Security: Protect login credentials to maintain system integrity.
            5. Compliance: Adhere to business policies and applicable local laws.
            ''',
            style: Theme.of(context).textTheme.bodyMedium,
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

  void _showTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E231F),
        title: Text('Our Team', style: Theme.of(context).textTheme.headlineMedium),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gracymei Alcala Turtosa',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Coder and Designer',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: const Color(0xFF868685)),
              ),
              const SizedBox(height: 16),
              Text(
                'Noel Amber Eugenio',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Coder and Designer',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: const Color(0xFF868685)),
              ),
              const SizedBox(height: 16),
              Text(
                'Ejos, Justine',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Coder and Debugger',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: const Color(0xFF868685)),
              ),
              const SizedBox(height: 16),
              Text(
                'Guintao, Christian Paolo A',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Coder and Designer',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: const Color(0xFF868685)),
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