import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehicle_model.dart';
import '../models/maintenance_record.dart';
import '../services/car_database_service.dart';

class MaintenanceScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const MaintenanceScreen({super.key, required this.vehicle});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _mileageController = TextEditingController();
  final _oilTypeController = TextEditingController();
  final _oilQuantityController = TextEditingController();
  final _filterController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'USD';
  bool _isLoading = false;

  final List<String> _serviceTypes = [
    'تغيير زيت المحرك',
    'تغيير فلتر الزيت',
    'صيانة شاملة',
    'تغيير فلتر الهواء',
    'تغيير فلتر الوقود',
    'فحص السوائل',
    'خدمة أخرى',
  ];

  final List<String> _oilTypes = [
    '0W-20',
    '5W-20',
    '5W-30',
    '0W-30',
    '5W-40',
    '10W-30',
    '10W-40',
    '15W-40',
    '20W-50',
  ];

  final List<String> _currencies = ['USD', 'SAR', 'AED', 'EUR', 'CNY'];

  @override
  void initState() {
    super.initState();
    _serviceTypeController.text = _serviceTypes[0];
    _oilTypeController.text = _oilTypes[0];
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _mileageController.dispose();
    _oilTypeController.dispose();
    _oilQuantityController.dispose();
    _filterController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
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
          'إضافة سجل صيانة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVehicleInfoCard(),
                    const SizedBox(height: 16),
                    _buildServiceDetailsCard(),
                    const SizedBox(height: 16),
                    _buildOilDetailsCard(),
                    const SizedBox(height: 16),
                    _buildCostCard(),
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'معلومات السيارة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الصنع والموديل', '${widget.vehicle.make} ${widget.vehicle.model}'),
            _buildInfoRow('سنة الصنع', widget.vehicle.year.toString()),
            _buildInfoRow('رقم VIN', widget.vehicle.vin),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الخدمة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _serviceTypeController.text,
              decoration: const InputDecoration(
                labelText: 'نوع الخدمة *',
                prefixIcon: Icon(Icons.build),
              ),
              items: _serviceTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _serviceTypeController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار نوع الخدمة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'قراءة العداد (كيلومتر) *',
                prefixIcon: Icon(Icons.speed),
                suffixText: 'كم',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال قراءة العداد';
                }
                if (int.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.blue[700]),
              title: const Text('تاريخ الخدمة'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'مكان الخدمة',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'اسم المركز أو الورشة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOilDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.oil_barrel, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الزيت',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _oilTypeController.text,
              decoration: const InputDecoration(
                labelText: 'نوع الزيت المستخدم',
                prefixIcon: Icon(Icons.oil_barrel),
              ),
              items: _oilTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _oilTypeController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _oilQuantityController,
              decoration: const InputDecoration(
                labelText: 'كمية الزيت',
                prefixIcon: Icon(Icons.local_gas_station),
                suffixText: 'لتر',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _filterController,
              decoration: const InputDecoration(
                labelText: 'فلتر الزيت المستخدم',
                prefixIcon: Icon(Icons.filter_alt),
                hintText: 'رقم القطعة أو العلامة التجارية',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'التكلفة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'التكلفة الإجمالية',
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'العملة',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value ?? 'USD';
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'ملاحظات إضافية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                prefixIcon: Icon(Icons.notes),
                hintText: 'أي ملاحظات إضافية حول الخدمة',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveMaintenanceRecord,
        icon: const Icon(Icons.save),
        label: const Text('حفظ سجل الصيانة'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMaintenanceRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = MaintenanceRecord(
        id: '', // Will be generated by database
        vehicleId: widget.vehicle.id,
        vin: widget.vehicle.vin,
        serviceType: _serviceTypeController.text,
        serviceDate: _selectedDate,
        mileageAtService: int.parse(_mileageController.text),
        oilTypeUsed: _oilTypeController.text.isNotEmpty ? _oilTypeController.text : 'غير محدد',
        oilQuantity: double.tryParse(_oilQuantityController.text) ?? 0.0,
        filterUsed: _filterController.text.isNotEmpty ? _filterController.text : 'غير محدد',
        serviceLocation: _locationController.text.isNotEmpty ? _locationController.text : 'غير محدد',
        cost: double.tryParse(_costController.text) ?? 0.0,
        currency: _selectedCurrency,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        additionalData: {
          'created_by': 'user',
          'app_version': '1.0.0',
        },
        createdAt: DateTime.now(),
      );

      final success = await CarDatabaseService.addMaintenanceRecord(record);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ سجل الصيانة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء حفظ السجل'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}