import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/services/storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard_controller.dart';
import 'features/resident/dashboard_screen.dart';
import 'features/complaints/complaint_controller.dart';

import 'features/complaints/resident_raise_complaint_screen.dart';
import 'features/complaints/resident_my_complaints_screen.dart';
import 'features/complaints/admin_complaint_list_screen.dart';
import 'features/complaints/super_admin_complaints_screen.dart';
import 'features/payments/admin_payment_settings_screen.dart';
import 'features/payments/admin_payment_list_screen.dart';
import 'features/payments/resident_payment_dashboard.dart';
import 'features/resident/visitor_management_screen.dart';
import 'features/guard/guard_panel_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/super_admin_panel_screen.dart';
import 'features/admin/manage_societies_screen.dart';
import 'features/admin/manage_users_screen.dart';
import 'features/admin/add_resident_screen.dart';
import 'features/admin/edit_resident_screen.dart';
import 'features/admin/edit_admin_screen.dart';
import 'features/admin/add_guard_screen.dart';
import 'features/admin/add_admin_screen.dart';
import 'features/admin/payment_reports_screen.dart';
import 'features/admin/banner_settings_screen.dart';
import 'features/admin/visitor_logs_screen.dart';
import 'features/admin/maintenance_settings_screen.dart';

import 'features/resident/notices_screen.dart';
import 'features/resident/sos_screen.dart';
import 'features/resident/spin_screen.dart';
import 'features/resident/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = true;
  String? firebaseError;

  // Initialize Firebase before app boot.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase Initialized Successfully: ${Firebase.app().options.projectId}");
  } catch (e) {
    firebaseReady = false;
    firebaseError = e.toString();
    debugPrint("❌ Firebase Initialization Failed: $e");
  }

  // Initialize Storage Service
  await StorageService.init();

  if (!firebaseReady) {
    runApp(FirebaseErrorApp(error: firebaseError ?? 'Unknown Firebase error'));
    return;
  }

  final initialRoute = _resolveInitialRoute();
  runApp(SocietyApp(initialRoute: initialRoute));
}

String _resolveInitialRoute() {
  if (!StorageService.isLoggedIn() || FirebaseAuth.instance.currentUser == null) {
    return '/login';
  }

  switch (StorageService.getUserRole()) {
    case 'super_admin':
      return '/super-admin-panel';
    case 'admin':
      return '/admin-dashboard';
    case 'guard':
      return '/guard-panel';
    case 'resident':
      return '/dashboard';
    default:
      return '/login';
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final String error;
  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: _FirebaseErrorScreen(error: error),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  final String error;
  const _FirebaseErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Firebase init failed:\n$error\n\nPlease check Firebase configuration and restart app.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class SocietyApp extends StatelessWidget {
  final String initialRoute;
  const SocietyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController globally
    final authController = Get.put(AuthController(), permanent: true);
    // Initialize DashboardController globally
    Get.put(DashboardController(), permanent: true);
    // Single complaints controller — shared list + realtime stream across Raise / My Complaints / Admin views
    Get.put(ComplaintController(), permanent: true);

    // Auto-login check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.checkLoginStatus();
    });

    return GetMaterialApp(
      title: 'Society App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      getPages: [
        // ── Auth ──────────────────────────────────────────
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/otp', page: () => OTPScreen()),

        // ── Resident ─────────────────────────────────────
        GetPage(name: '/dashboard', page: () => ResidentDashboard()),
        GetPage(name: '/payment', page: () => ResidentPaymentDashboard()),
        GetPage(name: '/my-complaints', page: () => MyComplaintsScreen()),
        GetPage(name: '/raise-complaint', page: () => RaiseComplaintScreen()),
        GetPage(name: '/admin-complaints', page: () => AdminComplaintListScreen()),
        GetPage(name: '/visitor-management', page: () => VisitorManagementScreen()),
        GetPage(name: '/notices', page: () => const NoticesScreen()),
        GetPage(name: '/sos', page: () => const SOSScreen()),
        GetPage(name: '/spin', page: () => const SpinScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),

        // ── Guard ────────────────────────────────────────
        GetPage(name: '/guard-panel', page: () => GuardPanelScreen()),

        // ── Admin ────────────────────────────────────────
        GetPage(name: '/admin-dashboard', page: () => AdminDashboard()),
        GetPage(name: '/manage-users', page: () => ManageUsersScreen()),
        GetPage(name: '/add-resident', page: () => AddResidentScreen()),
        GetPage(name: '/edit-resident', page: () => EditResidentScreen()),
        GetPage(name: '/add-guard', page: () => AddGuardScreen()),
        GetPage(name: '/admin-payments', page: () => AdminPaymentListScreen()),
        GetPage(name: '/maintenance-settings', page: () => const MaintenanceSettingsScreen()),

        // ── Super Admin ──────────────────────────────────
        GetPage(name: '/super-admin-panel', page: () => SuperAdminPanel()),
        GetPage(name: '/manage-societies', page: () => ManageSocietiesScreen()),
        GetPage(name: '/add-admin', page: () => AddAdminScreen()),
        GetPage(name: '/edit-admin', page: () => const EditAdminScreen()),
        GetPage(name: '/payment-settings', page: () => AdminPaymentSettingsScreen()),
        GetPage(name: '/payment-reports', page: () => PaymentReportsScreen()),
        GetPage(name: '/banner-settings', page: () => BannerSettingsScreen()),
        GetPage(name: '/admin-visitor-logs', page: () => AdminVisitorLogsScreen()),
        GetPage(name: '/super-admin-complaints', page: () => SuperAdminComplaintsScreen()),
      ],
    );
  }
}
