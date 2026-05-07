import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/storage_service.dart';
import '../core/services/firestore_service.dart';
import '../core/models/user_model.dart';
import 'auth/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // ── Navigation State ──────────────────────────────────────
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    if (index == selectedIndex.value) return;

    switch (index) {
      case 1:
        if (isPaymentsEnabled.value) {
          if (currentUserRole.value == 'admin' || currentUserRole.value == 'super_admin') {
            Get.toNamed('/admin-payments');
          } else {
            Get.toNamed('/payment');
          }
        } else {
          Get.snackbar('Disabled', 'Payments are disabled by admin');
        }
        break;
      case 2:
        if (isComplaintEnabled.value) {
          if (currentUserRole.value == 'admin' || currentUserRole.value == 'super_admin') {
            Get.toNamed('/admin-complaints');
          } else {
            Get.toNamed('/my-complaints');
          }
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
  var currentUserId = ''.obs;
  var currentUserName = 'User'.obs;
  var currentUserRole = ''.obs;
  var currentUserSociety = ''.obs;   // Society ID
  var societyId = ''.obs;            // Same as currentUserSociety (shorthand)
  var currentUserFlat = ''.obs;
  var currentUserFlatType = ''.obs;
  var currentUserBlock = ''.obs;
  var currentUserMobile = ''.obs;
  var societyName = ''.obs;
  var isLoadingUser = false.obs;
  var isUpdatingProfile = false.obs;

  // ── Resident Dashboard Data ───────────────────────────────
  final maintenanceAmount = 1200.0.obs;
  final maintenanceDueDate = 'May 1, 2026'.obs;
  final isMaintenancePaid = false.obs;

  // ── Banner Data (Dual: Global + Society) ───────────────────
  var currentBannerIndex = 0.obs;
  StreamSubscription? _globalBannerSubscription;
  StreamSubscription? _societyBannerSubscription;
  var globalBanners = <Map<String, dynamic>>[].obs;
  var societyBanners = <Map<String, dynamic>>[].obs;
  var bannerImages = <Map<String, dynamic>>[].obs;

  // ── Admin Dashboard Counts ────────────────────────────────
  var totalResidents = 0.obs;
  var totalGuards = 0.obs;
  var pendingComplaints = 0.obs;
  var totalVisitorsToday = 0.obs;
  var totalPaymentsCollected = '₹0'.obs;

  // ── Super Admin Dashboard Counts ──────────────────────────
  var totalSocieties = 0.obs;
  var totalUsers = 0.obs;
  var dauCount = 0.obs; // Daily Active Users
  var wauCount = 0.obs; // Weekly Active Users
  var mauCount = 0.obs; // Monthly Active Users

  // ── Recent Activities ─────────────────────────────────────
  var recentActivities = <Map<String, String>>[].obs;

  // ── Feature Toggles (Super Admin controlled) ──────────────
  final isSosEnabled = true.obs;
  final isComplaintEnabled = true.obs;
  final isSpinEnabled = true.obs;
  final isVisitorsEnabled = true.obs;
  final isPaymentsEnabled = true.obs;
  final isNoticeEnabled = true.obs;

  // ── Push Notification (Super Admin) ───────────────────────
  final notificationTitleController = TextEditingController();
  final notificationMessageController = TextEditingController();
  var isSendingNotification = false.obs;
  var isOpeningLink = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRealUserData();
    _listenToFeatureToggles();
  }

  // ════════════════════════════════════════════════════════════
  // FETCH USER DATA & ROLE-BASED DASHBOARD DATA
  // ════════════════════════════════════════════════════════════

  Future<void> fetchRealUserData() async {
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
          // CHECK STATUS: If deactivated, force logout
          if (!user.isActive) {
            Get.find<AuthController>().logout();
            return;
          }

          currentUserId.value = user.id ?? '';
          currentUserName.value = user.name;
          currentUserRole.value = user.role;
          currentUserSociety.value = user.societyId;
          societyId.value = user.societyId; // Keep both in sync
          currentUserMobile.value = user.mobile;
          if (user.flatNo != null) currentUserFlat.value = user.flatNo!;
          if (user.flatType != null) currentUserFlatType.value = user.flatType!;
          if (user.block != null) currentUserBlock.value = user.block!;

          try {
            final society = await _firestoreService.getSocietyById(user.societyId);
            societyName.value = society?.name ?? 'your society hub';
          } catch (e) {
            societyName.value = 'your society hub';
          }

          // Load role-specific data
          _loadRoleBasedData(user.role, user.societyId);
          
          // Update last active
          _updateUserHeartbeat();
        }
      }
      update(); // Notify GetBuilder listeners
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      isLoadingUser.value = false;
      update();
    }
  }

  /// Updates the user's last active timestamp in Firestore
  Future<void> _updateUserHeartbeat() async {
    if (currentUserId.value.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId.value)
            .update({'last_active': FieldValue.serverTimestamp()});
      } catch (e) {
        debugPrint('Heartbeat update failed: $e');
      }
    }
  }
  
  Future<bool> updateProfile({
    required String name,
    String? flatType,
    String? flatNo,
    String? block,
  }) async {
    if (name.isEmpty) return false;
    if (currentUserId.value.isEmpty) {
      _showError('User ID not found. Please log in again.');
      return false;
    }
    
    isUpdatingProfile.value = true;
    try {
      final Map<String, dynamic> updates = {'name': name};
      if (flatType != null) updates['flatType'] = flatType;
      if (flatNo != null) updates['flatNo'] = flatNo;
      if (block != null) updates['block'] = block;

      await _firestoreService.updateUser(currentUserId.value, updates);
      
      // Update local observables
      currentUserName.value = name;
      if (flatType != null) currentUserFlatType.value = flatType;
      if (flatNo != null) currentUserFlat.value = flatNo;
      if (block != null) currentUserBlock.value = block;
      
      return true;
    } catch (e) {
      _showError('Failed to update profile: $e');
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  void _loadRoleBasedData(String role, String societyId) {
    // Start listening to visitors for all roles that need it
    if (societyId.isNotEmpty) {
      _listenToVisitors(societyId);
    }
    
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
        // Guard specific data if any
        break;
    }
    loadBannerDataForSociety(societyId);
    _loadRecentActivities(role);
  }

  // ════════════════════════════════════════════════════════════
  // RESIDENT DATA
  // ════════════════════════════════════════════════════════════

  void _loadResidentData(String societyId) {
    // Maintenance details can be loaded here if needed
  }

  // ════════════════════════════════════════════════════════════
  // ADMIN DATA
  // ════════════════════════════════════════════════════════════

  Future<void> _loadAdminData(String societyId) async {
    try {
      // Get real counts from Firestore
      totalResidents.value = await _firestoreService.countUsersByRole(societyId, 'resident');
      totalGuards.value = await _firestoreService.countUsersByRole(societyId, 'guard');
      
      // Get total complaints count for this society (Summary)
      final complaintsSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('societyId', isEqualTo: societyId)
          .where('status', isNotEqualTo: 'Resolved') // Count all except Resolved
          .count()
          .get();
      pendingComplaints.value = complaintsSnapshot.count ?? 0;
      
      // Get real payments collected
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('societyId', isEqualTo: societyId)
          .where('status', isEqualTo: 'Approved')
          .get();
          
      double total = 0;
      for (var doc in paymentsSnapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      
      if (total >= 100000) {
        totalPaymentsCollected.value = '₹${(total / 100000).toStringAsFixed(1)}L';
      } else if (total >= 1000) {
        totalPaymentsCollected.value = '₹${(total / 1000).toStringAsFixed(1)}K';
      } else {
        totalPaymentsCollected.value = '₹${total.toStringAsFixed(0)}';
      }
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
      
      final now = DateTime.now();
      final dayAgo = now.subtract(const Duration(days: 1));
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));

      dauCount.value = users.where((u) => u.lastActive != null && u.lastActive!.isAfter(dayAgo)).length;
      wauCount.value = users.where((u) => u.lastActive != null && u.lastActive!.isAfter(weekAgo)).length;
      mauCount.value = users.where((u) => u.lastActive != null && u.lastActive!.isAfter(monthAgo)).length;
    } catch (e) {
      debugPrint('Error loading super admin data: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // GUARD DATA
  // ════════════════════════════════════════════════════════════

  // ── Guard Data & Visitors ──────────────────────────────
  var allVisitors = <Map<String, dynamic>>[].obs;
  var todayVisitors = <Map<String, dynamic>>[].obs;
  var visitorHistory = <Map<String, dynamic>>[].obs;
  var isCheckingIn = false.obs;

  void _listenToVisitors(String societyId) {
    _firestoreService.streamVisitorsBySociety(societyId).listen((visitors) {
      // Sort locally by created_at (descending) to avoid needing a Firestore composite index
      final sortedVisitors = List<Map<String, dynamic>>.from(visitors);
      sortedVisitors.sort((a, b) {
        final aTime = (a['created_at'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b['created_at'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime); // Newest first
      });

      allVisitors.value = sortedVisitors;
      
      // Separate today's (active) and history
      final activeVisitors = sortedVisitors.where((v) => v['status'] == 'in').toList();
      todayVisitors.value = activeVisitors;
      totalVisitorsToday.value = activeVisitors.length; // Update the dashboard count!
      
      visitorHistory.value = sortedVisitors.where((v) => v['status'] == 'out').toList();
    });
  }

  /// Guard: Check-in a visitor
  Future<void> checkInVisitor({
    required String name,
    required String mobile,
    required String flat,
    required String block,
    String? purpose,
  }) async {
    if (name.isEmpty || mobile.isEmpty || flat.isEmpty || (purpose ?? '').isEmpty) {
      _showError('All fields including Purpose are required');
      return;
    }

    try {
      isCheckingIn.value = true;
      final now = DateTime.now();
      final timeStr = DateFormat('dd MMM, hh:mm a').format(now);

      await _firestoreService.addVisitor({
        'name': name,
        'mobile': mobile.startsWith('+91') ? mobile : '+91$mobile',
        'flat': flat,
        'block': block,
        'purpose': purpose ?? '',
        'time': timeStr,
        'status': 'in',
        'society_id': currentUserSociety.value, // Use real society ID, not name!
      });

      Get.snackbar('✅ Checked In', '$name checked in for Flat $flat',
        backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
    } catch (e) {
      _showError(e.toString());
    } finally {
      isCheckingIn.value = false;
    }
  }

  /// Guard: Check-out a visitor
  Future<void> checkOutVisitor(String visitorId, String visitorName) async {
    try {
      final now = DateTime.now();
      final timeStr = DateFormat('dd MMM, hh:mm a').format(now);
      
      await _firestoreService.updateVisitorCheckout(visitorId, timeStr);

      Get.snackbar('👋 Checked Out', '$visitorName checked out',
        backgroundColor: Colors.orange.shade700, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    Get.snackbar('Error', message,
      backgroundColor: Colors.redAccent, colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
  }

  // ════════════════════════════════════════════════════════════
  // FEATURE TOGGLES (Society-Specific)
  // ════════════════════════════════════════════════════════════

  void _listenToFeatureToggles() {
    // Initial fetch if societyId is already present
    if (currentUserSociety.value.isNotEmpty) {
      _startFeatureToggleListener(currentUserSociety.value);
    }

    ever(currentUserSociety, (String sId) {
      if (sId.isNotEmpty) {
        _startFeatureToggleListener(sId);
      }
    });
  }

  void _startFeatureToggleListener(String sId) {
    FirebaseFirestore.instance
        .collection('societies')
        .doc(sId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final toggles = data['feature_toggles'] ?? {};
        isSosEnabled.value = toggles['SOS'] ?? true;
        isComplaintEnabled.value = toggles['Complaint'] ?? true;
        isSpinEnabled.value = toggles['Spin'] ?? true;
        isVisitorsEnabled.value = toggles['Visitors'] ?? true;
        isPaymentsEnabled.value = toggles['Payments'] ?? true;
        isNoticeEnabled.value = toggles['Notices'] ?? true;

        // Load Maintenance Data
        maintenanceAmount.value = (data['maintenance_amount'] ?? 1200.0).toDouble();
        maintenanceDueDate.value = (data['due_date'] ?? 'May 1, 2026').toString();
      }
    });
  }

  // ════════════════════════════════════════════════════════════
  // BANNER DATA (Combined Global + Society Specific)
  // ════════════════════════════════════════════════════════════

  void loadBannerDataForSociety(String sId) {
    debugPrint('Loading banners for Society: $sId');
    
    // Clear old data first to avoid stale state
    globalBanners.clear();
    societyBanners.clear();
    bannerImages.clear();

    // 1. Listen to Global Banners (Common for everyone)
    _globalBannerSubscription?.cancel();
    _globalBannerSubscription = FirebaseFirestore.instance
        .collection('banners')
        .snapshots()
        .listen((snapshot) {
      globalBanners.value = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      debugPrint('Global Banners Loaded: ${globalBanners.length}');
      _combineBanners();
    });

    // 2. Listen to Society Specific Banners
    if (sId.isNotEmpty) {
      _societyBannerSubscription?.cancel();
      _societyBannerSubscription = FirebaseFirestore.instance
          .collection('societies')
          .doc(sId)
          .collection('banners')
          .snapshots()
          .listen((snapshot) {
        societyBanners.value = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
        debugPrint('Society Banners Loaded: ${societyBanners.length}');
        _combineBanners();
      });
    }
  }

  void _combineBanners() {
    // Combine Global Banners first, then Society Banners
    bannerImages.value = [...globalBanners, ...societyBanners];
  }

  Future<void> toggleFeature(String feature, {String? targetSocietyId}) async {
    final sId = targetSocietyId ?? currentUserSociety.value;
    if (sId.isEmpty) {
      Get.snackbar('Error', 'No society selected', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('societies').doc(sId).get();
      if (!doc.exists) return;

      Map<String, dynamic> data = doc.data() ?? {};
      Map<String, dynamic> toggles = Map<String, dynamic>.from(data['feature_toggles'] ?? {});

      bool currentValue = toggles[feature] ?? true;
      bool newValue = !currentValue;
      toggles[feature] = newValue;

      await FirebaseFirestore.instance
          .collection('societies')
          .doc(sId)
          .update({'feature_toggles': toggles});
          
      Get.snackbar('Success', '$feature module ${newValue ? 'Enabled' : 'Disabled'} for this society',
        backgroundColor: const Color(0xFF0D47A1), colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
    } catch (e) {
      _showError('Failed to update feature: $e');
    }
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
  // RECENT ACTIVITIES
  // ════════════════════════════════════════════════════════════

  void _loadRecentActivities(String role) {
    // For now, clear dummy data. Real activities are populated via listeners (e.g. _listenToVisitors)
    recentActivities.clear();
    
    // You could add logic here to fetch recent payments or complaints 
    // to populate the list dynamically.
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

  // ── Helpers ───────────────────────────────────────────────
  String formatPhoneForDisplay(String phone) {
    if (phone.startsWith('+91')) {
      return phone.substring(3);
    }
    return phone;
  }

  @override
  void onClose() {
    _globalBannerSubscription?.cancel();
    _societyBannerSubscription?.cancel();
    notificationTitleController.dispose();
    notificationMessageController.dispose();
    super.onClose();
  }
}
