import 'package:flutter/material.dart';
import 'package:car_oil/screens/result/ui/vin_result_screen.dart';
import '../logic/vin_service.dart'; // Make sure this exists

class VinInputScreen extends StatefulWidget {
  const VinInputScreen({super.key});

  @override
  State createState() => _VinInputScreenState();
}

class _VinInputScreenState extends State {
  final TextEditingController _vinController = TextEditingController();
  bool _isLoading = false;

  void _submitVin() async {
    final vin = _vinController.text.trim().toUpperCase();

    if (vin.length != 17) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن يكون رقم VIN مكون من 17 خانة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final vehicleData = await VinService.decodeVin(vin); // async call

    setState(() => _isLoading = false);

    if (vehicleData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VinResultScreen(vin: vin),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على بيانات لهذا الرقم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فحص رقم VIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ادخل رقم VIN الخاص بسيارتك',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _vinController,
              maxLength: 17,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'رقم VIN',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitVin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('فحص'),
            ),
          ],
        ),
      ),
    );
  }
}
