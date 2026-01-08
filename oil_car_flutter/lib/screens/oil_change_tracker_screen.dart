import 'package:flutter/material.dart';
import 'package:oil_finder/models/oil_change_record.dart';
import 'package:oil_finder/services/oil_change_service.dart';
import 'package:oil_finder/screens/add_oil_change_screen.dart';
import 'package:intl/intl.dart';

class OilChangeTrackerScreen extends StatefulWidget {
  const OilChangeTrackerScreen({Key? key}) : super(key: key);

  @override
  State<OilChangeTrackerScreen> createState() => _OilChangeTrackerScreenState();
}

class _OilChangeTrackerScreenState extends State<OilChangeTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OilChangeRecord> _allRecords = [];
  List<OilChangeRecord> _overdueRecords = [];
  List<OilChangeRecord> _upcomingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        OilChangeService.getOilChangeRecords(),
        OilChangeService.getOverdueOilChanges(),
        OilChangeService.getUpcomingOilChanges(),
      ]);

      setState(() {
        _allRecords = results[0];
        _overdueRecords = results[1];
        _upcomingRecords = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('متتبع تغيير الزيت'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.history),
              text: 'السجل (${_allRecords.length})',
            ),
            Tab(
              icon: Icon(Icons.warning),
              text: 'متأخر (${_overdueRecords.length})',
            ),
            Tab(
              icon: Icon(Icons.schedule),
              text: 'قريباً (${_upcomingRecords.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAllRecordsTab(),
          _buildOverdueTab(),
          _buildUpcomingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddOilChangeScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: Icon(Icons.add),
        label: Text('تسجيل تغيير زيت'),
      ),
    );
  }

  Widget _buildAllRecordsTab() {
    if (_allRecords.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        message: 'لا توجد سجلات تغيير زيت',
        description: 'ابدأ بتسجيل أول تغيير زيت لسيارتك',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _allRecords.length,
        itemBuilder: (context, index) {
          final record = _allRecords[index];
          return _buildRecordCard(record);
        },
      ),
    );
  }

  Widget _buildOverdueTab() {
    if (_overdueRecords.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        message: 'لا توجد تغييرات زيت متأخرة',
        description: 'جميع سياراتك في موعدها!',
        color: Colors.green,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _overdueRecords.length,
      itemBuilder: (context, index) {
        final record = _overdueRecords[index];
        return _buildRecordCard(record, isOverdue: true);
      },
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingRecords.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        message: 'لا توجد تغييرات زيت قريبة',
        description: 'ستظهر التذكيرات هنا عندما يحين موعدها',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _upcomingRecords.length,
      itemBuilder: (context, index) {
        final record = _upcomingRecords[index];
        return _buildRecordCard(record, isUpcoming: true);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String description,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: color ?? Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(
      OilChangeRecord record, {
        bool isOverdue = false,
        bool isUpcoming = false,
      }) {
    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;

    if (isOverdue) {
      cardColor = Colors.red[50]!;
      borderColor = Colors.red[300]!;
    } else if (isUpcoming) {
      cardColor = Colors.orange[50]!;
      borderColor = Colors.orange[300]!;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: Colors.green[700],
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${record.vehicleMake} ${record.vehicleModel} ${record.vehicleYear}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'متأخر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isUpcoming)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'قريباً',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12),

            // Oil Change Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'تاريخ التغيير',
                    record.formattedChangeDate,
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'الموعد القادم',
                    record.formattedNextDueDate,
                    Icons.schedule,
                  ),
                ),
              ],
            ),

            if (record.mileage != null || record.oilType != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  if (record.mileage != null)
                    Expanded(
                      child: _buildDetailItem(
                        'الكيلومترات',
                        '${record.mileage!.toString()} كم',
                        Icons.speed,
                      ),
                    ),
                  if (record.oilType != null)
                    Expanded(
                      child: _buildDetailItem(
                        'نوع الزيت',
                        record.oilType!,
                        Icons.oil_barrel,
                      ),
                    ),
                ],
              ),
            ],

            if (record.notes != null && record.notes!.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editRecord(record),
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('تعديل'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteRecord(record),
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('حذف'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editRecord(OilChangeRecord record) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddOilChangeScreen(recordToEdit: record),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteRecord(OilChangeRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا السجل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      final success = await OilChangeService.deleteOilChangeRecord(record.id!);
      if (success) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف السجل بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف السجل'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}