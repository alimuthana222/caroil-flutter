import 'package:flutter/material.dart';
import 'package:oil_finder/models/oil_change_record.dart';
import 'package:oil_finder/models/vehicle.dart';
import 'package:oil_finder/services/oil_change_service.dart';
import 'package:intl/intl.dart';

class AddOilChangeScreen extends StatefulWidget {
  final Vehicle? vehicle;
  final OilChangeRecord? recordToEdit;

  const AddOilChangeScreen({
    Key? key,
    this.vehicle,
    this.recordToEdit,
  }) : super(key: key);

  @override
  State<AddOilChangeScreen> createState() => _AddOilChangeScreenState();
}

class _AddOilChangeScreenState extends State<AddOilChangeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _mileageController = TextEditingController();
  final _oilTypeController = TextEditingController();
  final _oilQuantityController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _changeDate = DateTime.now();
  DateTime? _nextDueDate;
  int? _nextDueMileage;
  int _intervalMonths = 6;
  int _intervalMiles = 5000;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _isEditing = widget.recordToEdit != null;

    if (widget.vehicle != null) {
      // Pre-fill from vehicle data
      _makeController.text = widget.vehicle!.make ?? '';
      _modelController.text = widget.vehicle!.model ?? '';
      _yearController.text = widget.vehicle!.year ?? '';
      _vinController.text = widget.vehicle!.vin ?? '';
    }

    if (widget.recordToEdit != null) {
      // Pre-fill from existing record
      final record = widget.recordToEdit!;
      _makeController.text = record.vehicleMake;
      _modelController.text = record.vehicleModel;
      _yearController.text = record.vehicleYear.toString();
      _vinController.text = record.vehicleVin ?? '';
      _mileageController.text = record.mileage?.toString() ?? '';
      _oilTypeController.text = record.oilType ?? '';
      _oilQuantityController.text = record.oilQuantity?.toString() ?? '';
      _notesController.text = record.notes ?? '';
      _changeDate = record.changeDate;
      _nextDueDate = record.nextDueDate;
      _nextDueMileage = record.nextDueMileage;
    }

    _calculateNextDueDate();
  }

  void _calculateNextDueDate() {
    _nextDueDate = OilChangeService.calculateNextOilChangeDate(
      _changeDate,
      intervalMonths: _intervalMonths,
    );

    final currentMileage = int.tryParse(_mileageController.text);
    if (currentMileage != null) {
      _nextDueMileage = OilChangeService.calculateNextOilChangeMileage(
        currentMileage,
        intervalMiles: _intervalMiles,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل سجل تغيير الزيت' : 'إضافة تغيير زيت'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteRecord,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Information Section
              _buildSectionTitle('معلومات السيارة'),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: InputDecoration(
                        labelText: 'الماركة *',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال الماركة';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'الموديل *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال الموديل';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'السنة *',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال السنة';
                        }
                        final year = int.tryParse(value!);
                        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                          return 'سنة غير صحيحة';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _vinController,
                      decoration: InputDecoration(
                        labelText: 'رقم الشاصي',
                        prefixIcon: Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Remove the problematic textDirection line completely
                      style: TextStyle(
                        // Force LTR for VIN numbers by using a monospace font
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Oil Change Details Section
              _buildSectionTitle('تفاصيل تغيير الزيت'),
              SizedBox(height: 16),

              // Change Date
              InkWell(
                onTap: _selectChangeDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'تاريخ تغيير الزيت *',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_changeDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mileageController,
                      decoration: InputDecoration(
                        labelText: 'الكيلومترات',
                        prefixIcon: Icon(Icons.speed),
                        suffixText: 'كم',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateNextDueDate(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _oilQuantityController,
                      decoration: InputDecoration(
                        labelText: 'كمية الزيت',
                        prefixIcon: Icon(Icons.local_gas_station),
                        suffixText: 'لتر',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _oilTypeController,
                decoration: InputDecoration(
                  labelText: 'نوع الزيت',
                  prefixIcon: Icon(Icons.oil_barrel),
                  hintText: 'مثال: 5W-30 Synthetic',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Next Change Settings
              _buildSectionTitle('إعدادات التغيير القادم'),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فترة التغيير (بالأشهر)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _intervalMonths,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.schedule),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [3, 6, 9, 12].map((months) {
                            return DropdownMenuItem(
                              value: months,
                              child: Text('$months أشهر'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _intervalMonths = value!;
                              _calculateNextDueDate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فترة التغيير (بالكيلومترات)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _intervalMiles,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.speed),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [3000, 5000, 7500, 10000].map((miles) {
                            return DropdownMenuItem(
                              value: miles,
                              child: Text('$miles كم'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _intervalMiles = value!;
                              _calculateNextDueDate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Next Due Date Display
              if (_nextDueDate != null)
                Card(
                  color: Colors.green[50],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.green[700]),
                            SizedBox(width: 8),
                            Text(
                              'موعد التغيير القادم',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.green[600]),
                            SizedBox(width: 4),
                            Text(
                              'التاريخ: ${DateFormat('dd/MM/yyyy').format(_nextDueDate!)}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        if (_nextDueMileage != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.speed, size: 16, color: Colors.green[600]),
                              SizedBox(width: 4),
                              Text(
                                'الكيلومترات: ${_nextDueMileage!.toString()} كم',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 24),

              // Notes Section
              _buildSectionTitle('ملاحظات'),
              SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات إضافية',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'أي ملاحظات حول تغيير الزيت...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),

              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveRecord,
                  icon: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(Icons.save),
                  label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ السجل'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
      ),
    );
  }

  Future<void> _selectChangeDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _changeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _changeDate = selectedDate;
        _calculateNextDueDate();
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final record = OilChangeRecord(
        id: widget.recordToEdit?.id,
        vehicleMake: _makeController.text.trim(),
        vehicleModel: _modelController.text.trim(),
        vehicleYear: int.parse(_yearController.text),
        vehicleVin: _vinController.text.trim().isNotEmpty
            ? _vinController.text.trim()
            : null,
        changeDate: _changeDate,
        mileage: _mileageController.text.isNotEmpty
            ? int.parse(_mileageController.text)
            : null,
        oilType: _oilTypeController.text.trim().isNotEmpty
            ? _oilTypeController.text.trim()
            : null,
        oilQuantity: _oilQuantityController.text.isNotEmpty
            ? double.parse(_oilQuantityController.text)
            : null,
        nextDueDate: _nextDueDate,
        nextDueMileage: _nextDueMileage,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      OilChangeRecord? savedRecord;
      if (_isEditing && widget.recordToEdit?.id != null) {
        savedRecord = await OilChangeService.updateOilChangeRecord(
          widget.recordToEdit!.id!,
          record,
        );
      } else {
        savedRecord = await OilChangeService.addOilChangeRecord(record);
      }

      if (savedRecord != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تحديث السجل بنجاح' : 'تم حفظ السجل بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('فشل في حفظ السجل');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRecord() async {
    if (widget.recordToEdit?.id == null) return;

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final success = await OilChangeService.deleteOilChangeRecord(
          widget.recordToEdit!.id!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف السجل بنجاح'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في حذف السجل'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الحذف: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _oilTypeController.dispose();
    _oilQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}