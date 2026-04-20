import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/storage_service.dart';
import '../core/services/firestore_service.dart';
import '../core/models/user_model.dart';

class DashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // ── Navigation State ──────────────────────────────────────
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    if (index == selectedIndex.value) return;

    switch (index) {
      case 1:
        if (isPaymentsEnabled.value) {
          Get.toNamed('/payment');
        } else {
          Get.snackbar('Disabled', 'Payments are disabled by admin');
        }
        break;
      case 2:
        if (isComplaintEnabled.value) {
          Get.toNamed('/complaint');
        } else {
          Get.snackbar('Disabled', 'Complaints are disabled by admin');
        }
        break;
      case 3:
        if (isVisitorsEnabled.value) {
          Get.toNamed('/visitor-management');
        } else {
          Get.snackbar('Disabled', 'Visitor tracking is disabled by admin');
        }
        break;
      case 4:
        Get.toNamed('/profile');
        break;
    }
  }

  // ── Current User Data ─────────────────────────────────────
  var currentUserName = 'User'.obs;
  var currentUserRole = ''.obs;
  var currentUserSociety = ''.obs;
  var currentUserFlat = ''.obs;
  var currentUserBlock = ''.obs;
  var currentUserMobile = ''.obs;
  var societyName = ''.obs;
  var isLoadingUser = false.obs;

  // ── Resident Dashboard Data ───────────────────────────────
  final maintenanceAmount = 1200.0.obs;
  final maintenanceDueDate = 'May 1, 2026'.obs;
  final isMaintenancePaid = false.obs;

  // ── Banner Data (Super Admin controlled) ──────────────────
  var bannerImages = <Map<String, String>>[].obs;
  var currentBannerIndex = 0.obs;

  // ── Admin Dashboard Counts ────────────────────────────────
  var totalResidents = 0.obs;
  var totalGuards = 0.obs;
  var pendingComplaints = 5.obs;
  var totalVisitorsToday = 12.obs;
  var totalPaymentsCollected = '₹1.2L'.obs;

  // ── Super Admin Dashboard Counts ──────────────────────────
  var totalSocieties = 0.obs;
  var totalUsers = 0.obs;
  var activeUsers = 0.obs;

  // ── Guard Dashboard Data ──────────────────────────────────
  var todayVisitors = <Map<String, dynamic>>[].obs;
  var isCheckingIn = false.obs;

  // ── Recent Activities ─────────────────────────────────────
  var recentActivities = <Map<String, String>>[].obs;

  // ── Feature Toggles (Super Admin controlled) ──────────────
  final isSosEnabled = true.obs;
  final isComplaintEnabled = true.obs;
  final isSpinEnabled = true.obs;
  final isVisitorsEnabled = true.obs;
  final isPaymentsEnabled = true.obs;

  // ── Push Notification (Super Admin) ───────────────────────
  final notificationTitleController = TextEditingController();
  final notificationMessageController = TextEditingController();
  var isSendingNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchRealUserData();
  }

  // ════════════════════════════════════════════════════════════
  // FETCH USER DATA & ROLE-BASED DASHBOARD DATA
  // ════════════════════════════════════════════════════════════

  Future<void> _fetchRealUserData() async {
    isLoadingUser.value = true;
    try {
      String? identifier = StorageService.getUserIdentifier();
      String? role = StorageService.getUserRole();
      currentUserRole.value = role ?? '';

      if (identifier != null && identifier.isNotEmpty) {
        UserModel? user;

        if (identifier.contains('@')) {
          user = await _firestoreService.getUserByEmail(identifier);
        } else {
          user = await _firestoreService.getUserByMobile(identifier);
        }

        if (user != null) {
          currentUserName.value = user.name;
          currentUserRole.value = user.role;
          currentUserSociety.value = user.societyId;
          currentUserMobile.value = user.mobile;
          if (user.flatNo != null) currentUserFlat.value = user.flatNo!;
          if (user.block != null) currentUserBlock.value = user.block!;

          try {
            final society = await _firestoreService.getSocietyById(user.societyId);
            societyName.value = society?.name ?? 'your society hub';
          } catch (e) {
            societyName.value = 'your society hub';
          }

          // Load role-specific data
          _loadRoleBasedData(user.role, user.societyId);
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      isLoadingUser.value = false;
    }
  }

  void _loadRoleBasedData(String role, String societyId) {
    switch (role) {
      case 'resident':
        _loadResidentData(societyId);
        break;
      case 'admin':
        _loadAdminData(societyId);
        break;
      case 'super_admin':
        _loadSuperAdminData();
        break;
      case 'guard':
        _loadGuardData(societyId);
        break;
    }
    _loadBannerData(societyId);
    _loadRecentActivities(role);
  }

  // ════════════════════════════════════════════════════════════
  // RESIDENT DATA
  // ════════════════════════════════════════════════════════════

  void _loadResidentData(String societyId) {
    // Load maintenance details, feature toggles from Firestore
    _loadFeatureToggles(societyId);
  }

  // ════════════════════════════════════════════════════════════
  // ADMIN DATA
  // ════════════════════════════════════════════════════════════

  Future<void> _loadAdminData(String societyId) async {
    try {
      // Get real counts from Firestore
      totalResidents.value = await _firestoreService.countUsersByRole(societyId, 'resident');
      totalGuards.value = await _firestoreService.countUsersByRole(societyId, 'guard');
    } catch (e) {
      debugPrint('Error loading admin data: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // SUPER ADMIN DATA
  // ════════════════════════════════════════════════════════════

  Future<void> _loadSuperAdminData() async {
    try {
      final societies = await _firestoreService.getAllSocieties();
      totalSocieties.value = societies.length;

      final users = await _firestoreService.getAllUsers();
      totalUsers.value = users.length;
      activeUsers.value = users.where((u) => u.isActive).length;
    } catch (e) {
      debugPrint('Error loading super admin data: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // GUARD DATA
  // ════════════════════════════════════════════════════════════

  void _loadGuardData(String societyId) {
    // Load today's visitor entries
    todayVisitors.value = [
      {'name': 'Rahul Singh', 'mobile': '+919876543210', 'flat': '204', 'block': 'A', 'time': '09:45 AM', 'status': 'in'},
      {'name': 'Amit Kumar', 'mobile': '+918765432109', 'flat': '102', 'block': 'B', 'time': '11:30 AM', 'checkout_time': '12:45 PM', 'status': 'out'},
      {'name': 'Priya Sharma', 'mobile': '+917654321098', 'flat': '301', 'block': 'C', 'time': '01:15 PM', 'status': 'in'},
    ];
  }

  /// Guard: Check-in a visitor
  void checkInVisitor({
    required String name,
    required String mobile,
    required String flat,
    required String block,
    String? purpose,
  }) {
    if (name.isEmpty || mobile.isEmpty || flat.isEmpty) {
      Get.snackbar('Missing Fields', 'Name, mobile, and flat are required',
        backgroundColor: Colors.redAccent, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
      return;
    }

    final now = TimeOfDay.now();
    final timeStr = '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';

    todayVisitors.insert(0, {
      'name': name,
      'mobile': mobile.startsWith('+91') ? mobile : '+91$mobile',
      'flat': flat,
      'block': block,
      'purpose': purpose ?? '',
      'time': timeStr,
      'status': 'in',
    });

    Get.snackbar('✅ Checked In', '$name checked in for Flat $flat',
      backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
  }

  /// Guard: Check-out a visitor
  void checkOutVisitor(int index) {
    if (index >= 0 && index < todayVisitors.length) {
      var visitor = Map<String, dynamic>.from(todayVisitors[index]);
      final now = TimeOfDay.now();
      final timeStr = '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
      visitor['status'] = 'out';
      visitor['checkout_time'] = timeStr;
      todayVisitors[index] = visitor;

      Get.snackbar('👋 Checked Out', '${visitor['name']} checked out',
        backgroundColor: Colors.orange.shade700, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
    }
  }

  // ════════════════════════════════════════════════════════════
  // BANNER DATA
  // ════════════════════════════════════════════════════════════

  void _loadBannerData(String societyId) {
    // Default banners — in production these come from Firestore
    bannerImages.value = [
      {'title': 'Community Event', 'subtitle': 'Annual Society Meet — May 15', 'gradient': 'blue'},
      {'title': 'Maintenance Reminder', 'subtitle': 'Pay before May 1 to avoid late fees', 'gradient': 'teal'},
      {'title': 'Safety First', 'subtitle': 'New CCTV cameras installed in Block C', 'gradient': 'purple'},
    ];
  }

  void nextBanner() {
    if (bannerImages.isNotEmpty) {
      currentBannerIndex.value = (currentBannerIndex.value + 1) % bannerImages.length;
    }
  }

  void prevBanner() {
    if (bannerImages.isNotEmpty) {
      currentBannerIndex.value = (currentBannerIndex.value - 1 + bannerImages.length) % bannerImages.length;
    }
  }

  // ════════════════════════════════════════════════════════════
  // FEATURE TOGGLES
  // ════════════════════════════════════════════════════════════

  void _loadFeatureToggles(String societyId) {
    // In production, load from Firestore society settings
    // For now, using defaults (all enabled)
  }

  void toggleFeature(String feature) {
    switch (feature) {
      case 'SOS':
        isSosEnabled.toggle();
        break;
      case 'Complaint':
        isComplaintEnabled.toggle();
        break;
      case 'Spin':
        isSpinEnabled.toggle();
        break;
      case 'Visitors':
        isVisitorsEnabled.toggle();
        break;
      case 'Payments':
        isPaymentsEnabled.toggle();
        break;
    }
    // In production, save toggle state to Firestore
  }

  // ════════════════════════════════════════════════════════════
  // RECENT ACTIVITIES
  // ════════════════════════════════════════════════════════════

  void _loadRecentActivities(String role) {
    switch (role) {
      case 'resident':
        recentActivities.value = [
          {'title': 'Maintenance Due: ₹1,200', 'time': 'Due May 1', 'type': 'payment'},
          {'title': 'Visitor: Rahul Singh', 'time': '09:45 AM', 'type': 'visitor'},
          {'title': 'Notice: Water Supply', 'time': 'Yesterday', 'type': 'notice'},
          {'title': 'Complaint Resolved: Lift Issue', 'time': '2 days ago', 'type': 'complaint'},
          {'title': 'SOS Alert Tested', 'time': '3 days ago', 'type': 'sos'},
          {'title': 'Spin & Win: Won ₹50 Coupon', 'time': 'Last week', 'type': 'spin'},
        ];
        break;
      case 'admin':
        recentActivities.value = [
          {'title': 'New Complaint: Water Leakage', 'time': '30 min ago', 'type': 'complaint'},
          {'title': 'Maintenance Paid: Flat B-102', 'time': '09:15 AM', 'type': 'payment'},
          {'title': 'Visitor Entry: Rahul Singh', 'time': '09:45 AM', 'type': 'visitor'},
          {'title': 'New Resident Added: Priya S.', 'time': 'Yesterday', 'type': 'user'},
          {'title': 'Guard Added: Ramesh K.', 'time': '2 days ago', 'type': 'user'},
        ];
        break;
      case 'super_admin':
        recentActivities.value = [
          {'title': 'New Society: Green Valley', 'time': '1 hour ago', 'type': 'society'},
          {'title': 'Admin Created: Ali Khan', 'time': 'Today', 'type': 'user'},
          {'title': 'Feature Toggle: SOS Disabled', 'time': 'Yesterday', 'type': 'setting'},
          {'title': 'Banner Updated', 'time': '2 days ago', 'type': 'banner'},
          {'title': 'Push Notification Sent', 'time': '3 days ago', 'type': 'notification'},
        ];
        break;
      default:
        recentActivities.value = [];
    }
  }

  // ════════════════════════════════════════════════════════════
  // PUSH NOTIFICATION (Super Admin)
  // ════════════════════════════════════════════════════════════

  Future<void> sendPushNotification() async {
    String title = notificationTitleController.text.trim();
    String message = notificationMessageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      Get.snackbar('Missing Fields', 'Title and message are required',
        backgroundColor: Colors.redAccent, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
      return;
    }

    isSendingNotification.value = true;
    try {
      // In production: Use Firebase Cloud Messaging
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      notificationTitleController.clear();
      notificationMessageController.clear();

      Get.snackbar('✅ Notification Sent', 'Push notification sent to all users',
        backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification: $e',
        backgroundColor: Colors.redAccent, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
    } finally {
      isSendingNotification.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // GREETING HELPER
  // ════════════════════════════════════════════════════════════

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Hello';
  }

  @override
  void onClose() {
    notificationTitleController.dispose();
    notificationMessageController.dispose();
    super.onClose();
  }
}
