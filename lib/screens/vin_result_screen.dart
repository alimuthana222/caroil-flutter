import 'package:flutter/material.dart';
import '../services/vin_service.dart';

class VinResultScreen extends StatefulWidget {
  final String vin;

  const VinResultScreen({super.key, required this.vin});

  @override
  State createState() => _VinResultScreenState();
}

class _VinResultScreenState extends State<VinResultScreen> {
  Map<String, dynamic>? vehicleData;
  Map<String, String>? oilRecommendation;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchVinData();
  }

  Future fetchVinData() async {
    setState(() => isLoading = true);
    try {
      final data = await VinService.decodeVin(widget.vin);
      if (data != null) {
        final oilRec = VinService.getOilRecommendation(data);
        setState(() {
          vehicleData = data;
          oilRecommendation = oilRec;
          isLoading = false;
        });
      } else {
        throw Exception('لم يتم العثور على بيانات للمركبة');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتائج VIN: ${widget.vin}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('خطأ: $errorMessage', textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchVinData,
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : vehicleData == null
          ? const Center(child: Text('لا توجد بيانات'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Oil Recommendation Section
                  if (oilRecommendation != null) ...[
                    Card(
                      elevation: 8,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_gas_station, color: Colors.white, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'توصية الزيت المناسب',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            ...oilRecommendation!.entries.map((entry) {
                              String arabicKey = '';
                              switch (entry.key) {
                                case 'oilType':
                                  arabicKey = 'نوع الزيت';
                                  break;
                                case 'capacity':
                                  arabicKey = 'الكمية';
                                  break;
                                case 'brand':
                                  arabicKey = 'العلامة التجارية المفضلة';
                                  break;
                                case 'interval':
                                  arabicKey = 'فترة التغيير';
                                  break;
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$arabicKey: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Vehicle Information Section
                  Text(
                    'معلومات المركبة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Show key vehicle information first
                  ...['Make', 'Model', 'Model Year', 'Engine Configuration', 'Displacement (L)'].map((key) {
                    final value = vehicleData![key];
                    if (value != null && value.toString().isNotEmpty) {
                      String arabicKey = '';
                      switch (key) {
                        case 'Make':
                          arabicKey = 'الصانع';
                          break;
                        case 'Model':
                          arabicKey = 'الموديل';
                          break;
                        case 'Model Year':
                          arabicKey = 'سنة الصنع';
                          break;
                        case 'Engine Configuration':
                          arabicKey = 'تكوين المحرك';
                          break;
                        case 'Displacement (L)':
                          arabicKey = 'حجم المحرك (لتر)';
                          break;
                      }
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.info, color: Colors.blue.shade600),
                          title: Text(
                            arabicKey,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(value.toString()),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }).toList(),
                  
                  SizedBox(height: 20),
                  
                  // Additional vehicle details
                  ExpansionTile(
                    title: Text(
                      'تفاصيل إضافية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    children: vehicleData!.entries.where((entry) => 
                      !['Make', 'Model', 'Model Year', 'Engine Configuration', 'Displacement (L)'].contains(entry.key) &&
                      entry.value != null && 
                      entry.value.toString().isNotEmpty
                    ).map((entry) {
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: ListTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            entry.value.toString(),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
