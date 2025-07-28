import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VinResultScreen extends StatefulWidget {
  final String vin;

  const VinResultScreen({super.key, required this.vin});

  @override
  State createState() => _VinResultScreenState();
}

class _VinResultScreenState extends State <VinResultScreen> {
  Map<String, dynamic>? vehicleData;
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
      final url = Uri.parse(
        'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/${widget.vin}?format=json',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = decoded['Results'] as List;
        final Map<String, String> info = {};
        for (var item in results) {
          if (item['Value'] != null && item['Variable'] != null) {
            info[item['Variable']] = item['Value'];
          }
        }
        setState(() {
          vehicleData = info;
          isLoading = false;
        });
      } else {
        throw Exception('فشل في جلب البيانات');
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
      appBar: AppBar(title: Text('نتائج VIN: ${widget.vin}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text('خطأ: $errorMessage'))
          : vehicleData == null
          ? const Center(child: Text('لا توجد بيانات'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'نتائج تحليل رقم الهيكل (VIN)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: vehicleData!.entries.map((entry) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(entry.value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
