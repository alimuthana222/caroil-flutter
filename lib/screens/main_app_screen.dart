import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';
import 'garage_screen.dart';
import 'maintenance_screen.dart';
import 'oil_products_screen.dart';
import 'settings_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const GarageScreen(),
    const SplashScreen(), // VIN Search
    const MaintenanceScreen(),
    const OilProductsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'الرئيسية',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.garage),
      label: 'مرآبي',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'بحث VIN',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.build),
      label: 'الصيانة',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.oil_barrel),
      label: 'منتجات الزيت',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: _navItems,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
      ),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      title: const Text(
        'أويل ميت',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        StreamBuilder(
          stream: AuthService.authStateChanges,
          builder: (context, snapshot) {
            final isAuthenticated = AuthService.isAuthenticated;
            
            return PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'settings':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                    break;
                  case 'logout':
                    if (isAuthenticated) {
                      await AuthService.signOut();
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('الإعدادات'),
                    ],
                  ),
                ),
                if (isAuthenticated)
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('تسجيل الخروج'),
                      ],
                    ),
                  ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.menu),
              ),
            );
          },
        ),
      ],
    );
  }
}