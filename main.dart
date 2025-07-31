import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:car_oil/screens/vin_lookup_screen.dart';
import 'package:car_oil/config/supabase_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );


  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    testDeviceIds: ['8f07c362-db8a-4279-be50-02975bb753ee'],
  ));

  runApp(CarOilApp());
}



class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4305177190816730/6733575446',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: ${error.code} - ${error.message}');
          ad.dispose();
        },

      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return Container(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}



class CarOilApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Oil Finder',
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
      ),
      home: VinLookupScreen(),
    );
  }
}