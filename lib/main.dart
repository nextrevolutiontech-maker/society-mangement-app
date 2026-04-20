import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme.dart';
import 'core/services/storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/resident/dashboard_screen.dart';
import 'features/resident/payment_screen.dart';
import 'features/resident/complaint_screen.dart';
import 'features/resident/visitor_management_screen.dart';
import 'features/guard/guard_panel_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/super_admin_panel_screen.dart';
import 'features/admin/manage_societies_screen.dart';
import 'features/admin/manage_users_screen.dart';
import 'features/admin/add_resident_screen.dart';
import 'features/admin/add_guard_screen.dart';
import 'features/admin/add_admin_screen.dart';
import 'features/admin/payment_reports_screen.dart';
import 'features/admin/banner_settings_screen.dart';

import 'features/resident/notices_screen.dart';
import 'features/resident/sos_screen.dart';
import 'features/resident/spin_screen.dart';
import 'features/resident/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with success check
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase Initialized Successfully: ${Firebase.app().options.projectId}");
  } catch (e) {
    debugPrint("❌ Firebase Initialization Failed: $e");
  }
  
  // Initialize Storage Service
  await StorageService.init();
  
  runApp(const SocietyApp());
}

class SocietyApp extends StatelessWidget {
  const SocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController globally
    final authController = Get.put(AuthController(), permanent: true);

    // Auto-login check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.checkLoginStatus();
    });

    return GetMaterialApp(
      title: 'Society App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      getPages: [
        // ── Auth ──────────────────────────────────────────
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/otp', page: () => OTPScreen()),

        // ── Resident ─────────────────────────────────────
        GetPage(name: '/dashboard', page: () => ResidentDashboard()),
        GetPage(name: '/payment', page: () => const MaintenancePaymentScreen()),
        GetPage(name: '/complaint', page: () => const RaiseComplaintScreen()),
        GetPage(name: '/visitor-management', page: () => const VisitorManagementScreen()),
        GetPage(name: '/notices', page: () => const NoticesScreen()),
        GetPage(name: '/sos', page: () => const SOSScreen()),
        GetPage(name: '/spin', page: () => const SpinScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),

        // ── Guard ────────────────────────────────────────
        GetPage(name: '/guard-panel', page: () => GuardPanelScreen()),

        // ── Admin ────────────────────────────────────────
        GetPage(name: '/admin-dashboard', page: () => AdminDashboard()),
        GetPage(name: '/manage-users', page: () => ManageUsersScreen()),
        GetPage(name: '/add-resident', page: () => AddResidentScreen()),
        GetPage(name: '/add-guard', page: () => AddGuardScreen()),
        GetPage(name: '/payment-reports', page: () => PaymentReportsScreen()),

        // ── Super Admin ──────────────────────────────────
        GetPage(name: '/super-admin-panel', page: () => SuperAdminPanel()),
        GetPage(name: '/manage-societies', page: () => ManageSocietiesScreen()),
        GetPage(name: '/add-admin', page: () => AddAdminScreen()),
        GetPage(name: '/banner-settings', page: () => BannerSettingsScreen()),
      ],
    );
  }
}
