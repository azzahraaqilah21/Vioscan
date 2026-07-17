import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import library Firebase
import 'firebase_options.dart'; // 2. Import file yang baru digenerate oleh CLI
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/skin_risk_assessment_screen.dart';
import 'screens/uv_processing_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/device_info_screen.dart';
import 'screens/emergency_assistance_screen.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const VioScanApp());
}

class VioScanApp extends StatelessWidget {
  const VioScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VioScan BC-Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A858C),
        ),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'splash';

  void navigate(String screen) {
    setState(() {
      _currentScreen = screen;
    });
    // Update status bar style
    final isDark = ['splash', 'processing'].contains(screen);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(

        
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case 'splash':
        return SplashScreen(navigate: navigate);
      case 'dashboard':
        return DashboardScreen(navigate: navigate);
      case 'assessment':
        return SkinRiskAssessmentScreen(navigate: navigate);
      case 'processing':
        return UVProcessingScreen(navigate: navigate);
      case 'result':
        return ScanResultScreen(navigate: navigate);
      case 'history':
        return ScanHistoryScreen(navigate: navigate);
      case 'device':
        return DeviceInfoScreen(navigate: navigate);
      case 'emergency':
        return EmergencyAssistanceScreen(navigate: navigate);
      default:
        return SplashScreen(navigate: navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentScreen),
          child: _buildScreen(),
        ),
      ),
    );
  }
}
