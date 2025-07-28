import 'package:flutter/material.dart';
import '../models/user_vehicle.dart';
import '../services/auth_service.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  List<UserVehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load user vehicles from database
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      setState(() {
        _vehicles = []; // Would be populated from database
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading vehicles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        title: const Text(
          'مرآبي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddVehicleDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVehicles,
              child: _vehicles.isEmpty
                  ? _buildEmptyState()
                  : _buildVehiclesList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.garage,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'مرآبك فارغ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'أضف سيارتك الأولى لبدء تتبع الصيانة والحصول على توصيات الزيت المناسبة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddVehicleDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إضافة سيارة جديدة'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/vin-search');
              },
              icon: const Icon(Icons.search),
              label: const Text('البحث باستخدام VIN'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(UserVehicle vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: vehicle.isPrimary
                    ? [Colors.blue[700]!, Colors.blue[500]!]
                    : [Colors.grey[600]!, Colors.grey[400]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.car_repair,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.nickname ?? 'سيارتي',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.currentMileage} كم',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vehicle.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'أساسية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleVehicleAction(value, vehicle),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'maintenance',
                      child: Row(
                        children: [
                          Icon(Icons.build, size: 18),
                          SizedBox(width: 8),
                          Text('سجل الصيانة'),
                        ],
                      ),
                    ),
                    if (!vehicle.isPrimary)
                      const PopupMenuItem(
                        value: 'setPrimary',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 8),
                            Text('جعلها أساسية'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Vehicle Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailItem(
                      'اللوحة',
                      vehicle.licensePlate ?? 'غير محدد',
                      Icons.badge,
                    ),
                    const SizedBox(width: 24),
                    _buildDetailItem(
                      'اللون',
                      vehicle.color ?? 'غير محدد',
                      Icons.palette,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDetailItem(
                      'سنة الشراء',
                      vehicle.purchaseYear?.toString() ?? 'غير محدد',
                      Icons.calendar_today,
                    ),
                    const SizedBox(width: 24),
                    _buildDetailItem(
                      'الحالة',
                      'جيدة',
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewVehicleDetails(vehicle),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('التفاصيل'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _scheduleMaintenance(vehicle),
                        icon: const Icon(Icons.schedule, size: 18),
                        label: const Text('جدولة صيانة'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: color ?? Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    if (!AuthService.isAuthenticated) {
      _showLoginPrompt();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سيارة جديدة'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('كيف تريد إضافة سيارتك؟'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to VIN search
            },
            icon: const Icon(Icons.search),
            label: const Text('باستخدام VIN'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showManualEntryDialog();
            },
            icon: const Icon(Icons.edit),
            label: const Text('إدخال يدوي'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    // TODO: Implement manual vehicle entry
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة الإدخال اليدوي قريباً')),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text('لإدارة مرآبك، يرجى تسجيل الدخول أولاً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to login screen
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  void _handleVehicleAction(String action, UserVehicle vehicle) {
    switch (action) {
      case 'edit':
        _editVehicle(vehicle);
        break;
      case 'maintenance':
        _viewMaintenanceHistory(vehicle);
        break;
      case 'setPrimary':
        _setPrimaryVehicle(vehicle);
        break;
      case 'delete':
        _deleteVehicle(vehicle);
        break;
    }
  }

  void _editVehicle(UserVehicle vehicle) {
    // TODO: Implement vehicle editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة تعديل السيارة قريباً')),
    );
  }

  void _viewMaintenanceHistory(UserVehicle vehicle) {
    // TODO: Navigate to maintenance history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة سجل الصيانة قريباً')),
    );
  }

  void _setPrimaryVehicle(UserVehicle vehicle) {
    // TODO: Set as primary vehicle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعيين السيارة كأساسية')),
    );
  }

  void _deleteVehicle(UserVehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السيارة'),
        content: Text('هل أنت متأكد من حذف "${vehicle.nickname ?? 'السيارة'}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete vehicle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف السيارة'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewVehicleDetails(UserVehicle vehicle) {
    // TODO: Navigate to vehicle details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة تفاصيل السيارة قريباً')),
    );
  }

  void _scheduleMaintenance(UserVehicle vehicle) {
    // TODO: Navigate to schedule maintenance
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة جدولة الصيانة قريباً')),
    );
  }
}