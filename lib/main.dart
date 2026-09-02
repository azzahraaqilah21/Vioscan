import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/skin_risk_assessment_screen.dart';
import 'screens/hardware_connection_screen.dart';
import 'screens/lesion_info_screen.dart';
import 'screens/waiting_scan_screen.dart';
import 'screens/uv_processing_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/ai_analysis_detail_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/about_bcc_screen.dart';
import 'screens/device_info_screen.dart';
import 'screens/emergency_assistance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: VioScanApp(),
    ),
  );
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

/// AppNavigator mengelola seluruh navigasi aplikasi.
/// StreamBuilder memantau status login Firebase Auth secara real-time:
///   - Belum login → SplashScreen → LoginScreen
///   - Sudah login  → SplashScreen → DashboardScreen
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'splash';

  void navigate(String screen) {
    setState(() => _currentScreen = screen);
    final isDark = ['splash', 'processing', 'waiting_scan'].contains(screen);
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
        // SplashScreen menggunakan StreamBuilder internal (authStateProvider)
        // untuk memutuskan apakah navigate ke 'login' atau 'dashboard'.
        return SplashScreen(navigate: navigate);
      case 'login':
        return LoginScreen(navigate: navigate);
      case 'dashboard':
        return DashboardScreen(navigate: navigate);
      case 'assessment':
        return SkinRiskAssessmentScreen(navigate: navigate);
      case 'hardware':
        return HardwareConnectionScreen(navigate: navigate);
      case 'lesion_info':
        return LesionInfoScreen(navigate: navigate);
      case 'waiting_scan':
        return WaitingScanScreen(navigate: navigate);
      case 'processing':
        return UVProcessingScreen(navigate: navigate);
      case 'result':
        return ScanResultScreen(navigate: navigate);
      case 'ai_detail':
        return AiAnalysisDetailScreen(navigate: navigate);
      case 'history':
        return ScanHistoryScreen(navigate: navigate);
      case 'profile':
        return ProfileScreen(navigate: navigate);
      case 'about_bcc':
        return AboutBccScreen(navigate: navigate);
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
    // StreamBuilder di sini sebagai lapisan keamanan tambahan:
    // Jika Firebase mendeteksi user sudah logout dari luar aplikasi
    // (misal token expired), paksa kembali ke layar login.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Saat Firebase sedang memuat status auth pertama kali
        if (snapshot.connectionState == ConnectionState.waiting &&
            _currentScreen == 'splash') {
          return const _LoadingScreen();
        }

        // Jika ada perubahan auth state dari luar (misal logout paksa)
        // dan bukan sedang di splash/login, redirect ke login
        if (snapshot.hasData == false &&
            _currentScreen != 'splash' &&
            _currentScreen != 'login') {
          // Jadwalkan agar tidak mengubah state selama build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigate('login');
          });
        }

        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(_currentScreen),
              child: _buildScreen(),
            ),
          ),
        );
      },
    );
  }
}

/// Layar loading sementara saat Firebase memuat status autentikasi awal.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A858C),
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
