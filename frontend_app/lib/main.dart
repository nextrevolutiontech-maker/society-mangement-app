import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/resident/dashboard_screen.dart';
import 'features/resident/payment_screen.dart';
import 'features/resident/complaint_screen.dart';

import 'features/resident/visitor_management_screen.dart';
import 'features/guard/guard_panel_screen.dart';

import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/super_admin_panel_screen.dart';
import 'features/admin/manage_societies_screen.dart';
import 'features/admin/manage_users_screen.dart';
import 'features/admin/payment_reports_screen.dart';
import 'features/admin/banner_settings_screen.dart';

void main() {
  runApp(const SocietyApp());
}

class SocietyApp extends StatelessWidget {
  const SocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OTPScreen(),
        '/dashboard': (context) => const ResidentDashboard(),
        '/payment': (context) => const MaintenancePaymentScreen(),
        '/complaint': (context) => const RaiseComplaintScreen(),
        '/visitor-management': (context) => const VisitorManagementScreen(),
        '/guard-panel': (context) => const GuardPanelScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/super-admin-panel': (context) => const SuperAdminPanel(),
        '/manage-societies': (context) => const ManageSocietiesScreen(),
        '/manage-users': (context) => const ManageUsersScreen(),
        '/payment-reports': (context) => const PaymentReportsScreen(),
        '/banner-settings': (context) => const BannerSettingsScreen(),
      },
    );
  }
}
