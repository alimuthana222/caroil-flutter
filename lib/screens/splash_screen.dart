import 'package:flutter/material.dart';
import 'vin_result_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _vinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  void _submitVin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final vin = _vinController.text.trim().toUpperCase();
      
      // Add a small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _isLoading = false);
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VinResultScreen(vin: vin)),
      );
    }
  }

  String? _validateVin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم VIN';
    }
    
    final vin = value.trim();
    if (vin.length != 17) {
      return 'رقم VIN يجب أن يكون 17 خانة';
    }
    
    // Basic VIN validation - no I, O, Q characters
    if (vin.contains(RegExp(r'[IOQ]'))) {
      return 'رقم VIN لا يحتوي على الأحرف I أو O أو Q';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 32),
                
                // App Title
                const Text(
                  'OilMate',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'دليلك الذكي لزيت السيارة المناسب',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Input Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'أدخل رقم VIN الخاص بسيارتك',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _vinController,
                            decoration: const InputDecoration(
                              labelText: 'رقم VIN (17 خانة)',
                              hintText: 'مثال: 1HGBH41JXMN109186',
                              prefixIcon: Icon(Icons.confirmation_number),
                              counterText: '',
                            ),
                            maxLength: 17,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: _validateVin,
                          ),
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitVin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'احصل على توصية الزيت',
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ستحصل على توصية مخصصة لنوع الزيت المناسب لسيارتك\nبناءً على معلومات الشركة المصنعة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
