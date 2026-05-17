import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/payment_model.dart';
import '../../core/config/api_keys.dart';
import '../dashboard_controller.dart';

class PaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DashboardController _dashboardController = Get.find<DashboardController>();
  final ImagePicker _picker = ImagePicker();

  // Reactive state
  var currentMaintenanceAmount = 0.0.obs;
  var currentFlatTypeAmounts = <String, double>{}.obs;
  var currentUpiId = ''.obs;
  var currentPaymentName = ''.obs;
  var currentBankName = ''.obs;
  var currentAccountInfo = ''.obs;
  var currentPaymentNotes = ''.obs;
  
  final String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  
  var myPayments = <PaymentModel>[].obs;
  var allPayments = <PaymentModel>[].obs;
  
  var isLoading = false.obs;
  var isSettingsLoading = false.obs;
  var isActionLoading = false.obs;

  // Manual payment form state
  var selectedImagePath = ''.obs;
  var selectedPaymentMode = 'UPI'.obs;
  final List<String> paymentModes = ['UPI', 'Bank Transfer', 'Cash', 'Other'];

  // Admin Filtering State
  var adminFilterMonth = 'All'.obs;
  var adminFilterStatus = 'All'.obs;
  var adminFilterFlat = ''.obs;
  var filteredPayments = <PaymentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initial fetch attempts
    _fetchSocietyPaymentSettings();
    _fetchMyPayments();
    if (_dashboardController.currentUserRole.value == 'admin' || 
        _dashboardController.currentUserRole.value == 'super_admin') {
      _fetchAllPayments();
    }

    // Task: Re-fetch whenever society ID or User ID changes
    ever(_dashboardController.currentUserSociety, (_) {
      _fetchSocietyPaymentSettings();
      _fetchMyPayments();
      if (_dashboardController.currentUserRole.value == 'admin' || 
          _dashboardController.currentUserRole.value == 'super_admin') {
        _fetchAllPayments();
      }
    });

    ever(_dashboardController.currentUserId, (_) {
      _fetchMyPayments();
    });

    // Filtering logic
    everAll([allPayments, adminFilterMonth, adminFilterStatus, adminFilterFlat], (_) {
      _applyFilters();
    });

    // Task: Recalculate amount whenever resident's flat type is loaded/changed
    ever(_dashboardController.currentUserFlatType, (_) {
      currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
    });
  }

  // ── Image Handling ──────────────────────────────────────────

  Future<void> pickProofImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1200,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void clearSelectedImage() {
    selectedImagePath.value = '';
  }

  // ── Payment Submission ──────────────────────────────────────

  /// Saves the complete payment configuration.
  Future<void> savePaymentConfig({
    required String upiId,
    required String name,
    required String bankName,
    required String accountInfo,
    required String paymentNotes,
  }) async {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) {
      Get.snackbar('Error', 'Society ID not found. Please wait for profile to load or login again.', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final trimmedUpi = upiId.trim();
    
    // If not clearing, validate UPI format
    if (trimmedUpi.isNotEmpty && !trimmedUpi.contains('@')) {
      Get.snackbar('Invalid UPI', 'Please enter a valid UPI ID (e.g. name@bank)', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isSettingsLoading.value = true;
    try {
      final configMap = {
        'upiId': trimmedUpi,
        'payeeName': name.trim(),
        'bankName': bankName.trim(),
        'accountInfo': accountInfo.trim(),
        'paymentNotes': paymentNotes.trim(),
      };

      await _firestore.collection('societies').doc(societyId).set({
        'paymentConfig': configMap,
      }, SetOptions(merge: true));
      
      currentUpiId.value = configMap['upiId']!;
      currentPaymentName.value = configMap['payeeName']!;
      currentBankName.value = configMap['bankName']!;
      currentAccountInfo.value = configMap['accountInfo']!;
      currentPaymentNotes.value = configMap['paymentNotes']!;
      
      if (trimmedUpi.isEmpty) {
        Get.snackbar('Deleted', 'Payment config cleared successfully', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Success', 'Payment config saved successfully', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save payment config: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSettingsLoading.value = false;
    }
  }

  Future<void> upsertFlatTypeAmount(String flatType, double amount) async {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) return;
    final key = _normalizeFlatTypeKey(flatType);
    if (key.isEmpty) {
      Get.snackbar('Invalid', 'Flat / BHK type must be non-empty', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (amount <= 0) {
      Get.snackbar('Invalid', 'Amount must be greater than 0', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isSettingsLoading.value = true;
    try {
      final docRef = _firestore.collection('societies').doc(societyId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        // Create empty doc first if it doesn't exist
        await docRef.set({'maintenanceByFlatType': {}}, SetOptions(merge: true));
      }

      // Use dot notation to update only this specific key in the map
      await docRef.update({
        'maintenanceByFlatType.$key': amount,
      });

      final next = Map<String, double>.from(currentFlatTypeAmounts);
      next[key] = amount;
      currentFlatTypeAmounts.value = next;
      currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
      Get.snackbar('Success', '$key amount saved', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update $key: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSettingsLoading.value = false;
    }
  }

  Future<void> deleteFlatTypeAmount(String flatType) async {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) return;
    final key = _normalizeFlatTypeKey(flatType);
    if (key.isEmpty) return;

    isSettingsLoading.value = true;
    try {
      await _firestore.collection('societies').doc(societyId).update({
        'maintenanceByFlatType.$key': FieldValue.delete(),
      });
      
      final next = Map<String, double>.from(currentFlatTypeAmounts);
      next.remove(key);
      currentFlatTypeAmounts.value = next;

      currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
      Get.snackbar('Deleted', '$key amount removed', backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete $key: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSettingsLoading.value = false;
    }
  }

  // Common: Fetch Society Payment Settings
  Future<void> _fetchSocietyPaymentSettings() async {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) return;

    try {
      final doc = await _firestore.collection('societies').doc(societyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final rawMap = data['maintenanceByFlatType'];
        if (rawMap is Map) {
          currentFlatTypeAmounts.value = _normalizeFlatTypeAmounts(rawMap);
        } else {
          final legacy = (data['maintenanceAmount'] ?? 0.0).toDouble();
          if (legacy > 0) {
            currentFlatTypeAmounts.value = {'Others': legacy};
          } else {
            currentFlatTypeAmounts.value = {};
          }
        }
        currentMaintenanceAmount.value = _currentUserMaintenanceAmount();

        // Load new nested paymentConfig
        final paymentConfig = data['paymentConfig'] as Map<String, dynamic>?;
        if (paymentConfig != null) {
          currentUpiId.value = paymentConfig['upiId'] ?? '';
          currentPaymentName.value = paymentConfig['payeeName'] ?? '';
          currentBankName.value = paymentConfig['bankName'] ?? '';
          currentAccountInfo.value = paymentConfig['accountInfo'] ?? '';
          currentPaymentNotes.value = paymentConfig['paymentNotes'] ?? '';
        } else {
          // Fallback to old root-level keys if nested config is missing
          currentUpiId.value = data['upiId'] ?? '';
          currentPaymentName.value = data['paymentName'] ?? '';
          currentBankName.value = '';
          currentAccountInfo.value = '';
          currentPaymentNotes.value = '';
        }
      } else {
        currentFlatTypeAmounts.value = {};
        currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
        currentUpiId.value = '';
        currentPaymentName.value = '';
        currentBankName.value = '';
        currentAccountInfo.value = '';
        currentPaymentNotes.value = '';
      }
    } catch (e) {
      debugPrint('Error fetching society settings: $e');
      currentFlatTypeAmounts.value = {};
      currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
    }
  }

  // Resident: Fetch My Payments
  void _fetchMyPayments() {
    final userId = _dashboardController.currentUserId.value;
    if (userId.isEmpty) return;

    isLoading.value = true;
    _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      debugPrint('📩 Firestore Update: Received ${snapshot.docs.length} payments for user $userId');
      final list = snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data(), doc.id)).toList();
      
      // Sort: Newest first by createdAt
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      myPayments.value = list;
      myPayments.refresh();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('🚨 FIREBASE ERROR: Error fetching my payments: $e');
      isLoading.value = false;
    });
  }

  // Admin: Fetch All Payments
    void _fetchAllPayments() {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) return;

    isLoading.value = true;
    _firestore
        .collection('payments')
        .where('societyId', isEqualTo: societyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      allPayments.value = snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data(), doc.id)).toList();
      _applyFilters(); // Apply immediately
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error fetching all payments: $e');
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var list = allPayments.toList();

    if (adminFilterMonth.value != 'All') {
      list = list.where((p) => p.month == adminFilterMonth.value).toList();
    }

    if (adminFilterStatus.value != 'All') {
      list = list.where((p) => p.status == adminFilterStatus.value).toList();
    }

    if (adminFilterFlat.value.isNotEmpty) {
      final query = adminFilterFlat.value.toLowerCase();
      list = list.where((p) => p.flatNumber.toLowerCase().contains(query)).toList();
    }

    filteredPayments.value = list;
  }

  // Resident: Get total amount paid and approved for a specific month
  double getTotalPaidForMonth(String month) {
    return myPayments
        .where((p) => p.month == month && (p.status == 'Approved' || p.status == 'Paid'))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // Resident: Get remaining dues for current month dynamically
  double getRemainingDues() {
    String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    double totalPaid = getTotalPaidForMonth(currentMonth);
    double maintenance = currentMaintenanceAmount.value;
    double due = maintenance - totalPaid;
    return due > 0 ? due : 0.0;
  }

  // Resident: Get precise accounting status for a month
  String getDetailedStatus(String month) {
    final payments = myPayments.where((p) => p.month == month).toList();

    // Priority 1: Fully Paid
    double totalPaid = getTotalPaidForMonth(month);
    double maintenance = currentMaintenanceAmount.value;
    if (maintenance > 0 && totalPaid >= maintenance) return 'Paid';

    // Priority 2: Processing (online intent fired but not yet confirmed)
    if (payments.any((p) => p.status == 'Processing')) {
      return 'Processing';
    }

    // Priority 3: Pending Verification (screenshot uploaded, awaiting admin)
    if (payments.any((p) => p.status == 'Pending Verification' || p.status == 'Pending')) {
      return 'Pending Verification';
    }

    // Priority 4: Partially Paid (some approved, but not full amount)
    if (totalPaid > 0) {
      return 'Partially Paid';
    }

    // Priority 5: Maintenance not set
    if (maintenance <= 0) return 'Unpaid';

    // Priority 6: Rejected
    if (payments.any((p) => p.status == 'Rejected')) {
      return 'Rejected';
    }

    return 'Unpaid';
  }

  // Helper to get the most relevant payment for a month (Priority: Approved > Pending > Rejected)
  PaymentModel? getPaymentForMonth(String month) {
    final monthPayments = myPayments.where((p) => p.month == month).toList();
    if (monthPayments.isEmpty) return null;
    
    // Sort: Approved first, then Pending, then Rejected
    monthPayments.sort((a, b) {
      final order = {'Approved': 0, 'Pending': 1, 'Rejected': 2};
      return (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
    });
    
    return monthPayments.first;
  }

  void resetAdminFilters() {
    adminFilterMonth.value = 'All';
    adminFilterStatus.value = 'All';
    adminFilterFlat.value = '';
  }

  double getAmountForFlatType(String flatType) {
    if (flatType.isEmpty) return 0.0;
    final k = _normalizeFlatTypeKey(flatType);
    return currentFlatTypeAmounts[k] ?? 0.0;
  }

  String _normalizeFlatTypeKey(String s) => s.trim().toUpperCase();

  double _currentUserMaintenanceAmount() {
    final flatType = _normalizeFlatTypeKey(_dashboardController.currentUserFlatType.value);
    final fromMap = getAmountForFlatType(flatType);
    if (fromMap > 0) return fromMap;
    // Residents with custom flat labels can still be mapped by admin via Others.
    final othersAmount = getAmountForFlatType('OTHERS');
    if (othersAmount > 0) return othersAmount;
    return 0.0;
  }

  Map<String, double> _normalizeFlatTypeAmounts(Map rawMap) {
    final normalized = <String, double>{};
    for (final e in rawMap.entries) {
      final k = _normalizeFlatTypeKey('${e.key}');
      if (k.isEmpty) continue;
      final v = e.value;
      final d = v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
      if (d > 0) normalized[k] = d;
    }
    return normalized;
  }

  // Resident: Initiate Online Payment (Pay Now)
  Future<void> initiateUPIPayment() async {
    if (currentUpiId.value.isEmpty || !currentUpiId.value.contains('@')) {
      Get.snackbar(
        'Payment Not Configured',
        'Admin has not configured the Society UPI ID. Please contact your Admin.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final double amountToPay = getRemainingDues();
    if (amountToPay <= 0) {
      Get.snackbar('No Dues', 'No pending dues for this month.', backgroundColor: const Color(0xFF1565C0), colorText: Colors.white);
      return;
    }

    // Delegate entirely to the new production method
    await initiateOnlinePayment(amountToPay);
  }

  Future<void> initiateOnlinePayment(double amount) async {
    final upiId = currentUpiId.value.trim();
    final name = currentPaymentName.value.trim().isEmpty ? 'Society Admin' : currentPaymentName.value.trim();
    
    if (upiId.isEmpty || !upiId.contains('@')) {
      Get.snackbar('Configuration Error', 'Society UPI ID is not configured. Please contact Admin.', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (amount <= 0) {
      Get.snackbar('Invalid Amount', 'Amount must be greater than 0.', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Duplicate Prevention
    final existingPending = myPayments.firstWhereOrNull((p) => p.month == currentMonth && (p.status == 'Pending' || p.status == 'Pending Verification'));
    if (existingPending != null) {
      Get.snackbar('Already Pending', 'A manual payment request for $currentMonth is already under review.', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isActionLoading.value = true;
    try {
      final userId = _dashboardController.currentUserId.value;
      final userName = _dashboardController.currentUserName.value;
      final flatNumber = _dashboardController.currentUserFlat.value;
      final flatType = _dashboardController.currentUserFlatType.value;
      final societyId = _dashboardController.currentUserSociety.value;
      
      // Check if a Processing record already exists for this month
      final existingProcessing = myPayments.firstWhereOrNull((p) => p.month == currentMonth && p.status == 'Processing');
      
      final now = DateTime.now();
      
      if (existingProcessing == null) {
        // Create new Processing record
        final newPayment = PaymentModel(
          userId: userId,
          userName: userName,
          flatNumber: flatNumber,
          flatType: flatType,
          societyId: societyId,
          month: currentMonth,
          year: now.year,
          amount: currentMaintenanceAmount.value,
          dueAmount: amount,
          paidAmount: 0.0,
          status: 'Processing',
          paymentMode: 'Online Intent',
          createdAt: now,
          updatedAt: now,
        );
        
        await _firestore.collection('payments').add(newPayment.toMap());
      } else {
        // Update existing Processing record
        await _firestore.collection('payments').doc(existingProcessing.id).update({
          'updatedAt': Timestamp.fromDate(now),
          'dueAmount': amount,
        });
      }

      final amountStr = amount.toStringAsFixed(2);
      // Raw string — no Uri() constructor to avoid @ encoding to %40
      final String upiUrl = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=$amountStr&cu=INR';
      final Uri uri = Uri.parse(upiUrl);
      debugPrint('🚀 UPI Intent: $upiUrl');

      bool launched = false;
      String? launchError;

      try {
        // Primary: externalApplication mode (correct for Android intents)
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ launchUrl result: $launched');
      } catch (e) {
        launchError = e.toString();
        debugPrint('⚠️ launchUrl exception: $e');
      }

      // ACTIVITY_NOT_FOUND is the ONLY definitive "no app installed" signal.
      // If launched=false but no exception, it is a false-negative on some devices.
      // We treat anything that is NOT ACTIVITY_NOT_FOUND as "intent was fired".
      final bool isDefinitelyNotFound = launchError != null &&
          launchError.toUpperCase().contains('ACTIVITY_NOT_FOUND');

      if (isDefinitelyNotFound) {
        // Truly no app — show fallback
        _handleUPIFallback(upiId,
            error: 'Koi UPI app nahi mila. Paytm ya GPay install karein.');
      } else {
        // Intent was fired (or likely opened). Show manual verification prompt.
        Get.defaultDialog(
          title: 'Payment Sent?',
          titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'If your UPI payment was successful, please use the "I Have Paid" button on the payment screen to upload your screenshot for Admin verification.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          confirm: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate payment: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isActionLoading.value = false;
    }
  }

  void _handleUPIFallback(String upiId, {String? error}) {
    Clipboard.setData(ClipboardData(text: upiId));
    Get.snackbar(
      'Payment Launch Issue', 
      'Error: ${error ?? "No UPI app responded"}. UPI ID ($upiId) copied. Please pay manually and upload the screenshot.',
      backgroundColor: Colors.orange.shade900,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Resident: Submit Manual Payment (Already Paid)
  Future<void> submitManualPayment({
    required String month,
    required double amount,
    required String mode,
    String? note, // Added
  }) async {
    final userId = _dashboardController.currentUserId.value;
    if (userId.isEmpty) return;

    // Duplicate Prevention: Check if there's already a Pending request for this exact month
    final existingPending = myPayments.firstWhereOrNull((p) => p.month == month && (p.status == 'Pending' || p.status == 'Pending Verification'));
    if (existingPending != null) {
      Get.snackbar('Already Pending', 'A payment request for $month is already under review. Please wait for Admin approval.', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (selectedImagePath.isEmpty) {
      Get.snackbar('Error', 'Please upload a proof screenshot', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isActionLoading.value = true;
    try {
      // 1. Upload Screenshot to Cloudinary
      final String? proofUrl = await _uploadToCloudinary(File(selectedImagePath.value));
      
      if (proofUrl == null) {
        throw 'Failed to get upload URL from Cloudinary';
      }

      // 2. Check for an existing 'Processing' record (from Pay Now flow)
      final now = DateTime.now();
      final existingProcessing = myPayments.firstWhereOrNull((p) => p.month == month && p.status == 'Processing');

      if (existingProcessing != null) {
        // Update the existing Processing record
        await _firestore.collection('payments').doc(existingProcessing.id).update({
          'status': 'Pending Verification',
          'paymentMode': mode,
          'proofUrl': proofUrl,
          'residentNote': note,
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
        // Create new Payment Model
        int selectedYear = now.year;
        try {
          // Try to extract year from month string like "May 2026"
          final parts = month.split(' ');
          if (parts.length > 1) {
            selectedYear = int.parse(parts[1]);
          }
        } catch (_) {}

        final payment = PaymentModel(
          userId: userId,
          userName: _dashboardController.currentUserName.value,
          flatNumber: _dashboardController.currentUserFlat.value,
          flatType: _dashboardController.currentUserFlatType.value,
          societyId: _dashboardController.currentUserSociety.value,
          month: month,
          year: selectedYear,
          amount: currentMaintenanceAmount.value, // Base total amount
          dueAmount: amount, // The remaining amount they are attempting to pay
          paidAmount: 0.0,
          status: 'Pending Verification',
          paymentMode: mode,
          proofUrl: proofUrl,
          residentNote: note, // Added
          createdAt: now,
          updatedAt: now,
        );

        // 3. Save to Firestore
        await _firestore.collection('payments').add(payment.toMap());
      }
      
      myPayments.refresh();
      // Cleanup
      selectedImagePath.value = '';
      Get.back(); // Close form
      Get.snackbar('Success', 'Payment proof submitted for approval', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('Error submitting manual payment: $e');
      Get.snackbar('Error', 'Failed to submit payment: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    try {
      final String cloudName = ApiKeys.cloudinaryCloudName;
      final String uploadPreset = ApiKeys.cloudinaryUploadPreset;
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      
      final request = http.MultipartRequest("POST", uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = utf8.decode(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        debugPrint('Cloudinary Error Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary Upload Exception: $e');
      return null;
    }
  }

  // Resident: Confirm Payment Record after returning from UPI app (Online Flow)
  Future<void> confirmPaymentRecord() async {
    final userId = _dashboardController.currentUserId.value;
    if (userId.isEmpty) return;

    isActionLoading.value = true;
    String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    double amountToPay = getRemainingDues();
    if (amountToPay <= 0) return;

    try {
      final now = DateTime.now();
      int selectedYear = now.year;
      try {
        final parts = currentMonth.split(' ');
        if (parts.length > 1) {
          selectedYear = int.parse(parts[1]);
        }
      } catch (_) {}

      final payment = PaymentModel(
        userId: userId,
        userName: _dashboardController.currentUserName.value,
        flatNumber: _dashboardController.currentUserFlat.value,
        flatType: _dashboardController.currentUserFlatType.value,
        societyId: _dashboardController.currentUserSociety.value,
        month: currentMonth,
        year: selectedYear,
        amount: amountToPay,
        status: 'Pending', 
        paymentMode: 'Online (UPI)',
        createdAt: now,
      );

      // 3. Save to Firestore
      await _firestore.collection('payments').add(payment.toMap());
      
      myPayments.refresh();
      Get.back();
      Get.snackbar('Success', 'Payment record created.', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      Get.snackbar('Error', 'Failed to confirm payment: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isActionLoading.value = false;
    }
  }

  // Admin or Resident: Delete a payment record
  Future<bool> deletePayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).delete();
      myPayments.refresh();
      _fetchAllPayments();
      allPayments.refresh();
      Get.snackbar('Success', 'Payment record removed', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      return false;
    }
  }

  // Admin: Update Payment Status with Remarks
  Future<bool> updatePaymentStatus(String paymentId, String status, {String? remarks}) async {
    final adminName = _dashboardController.currentUserName.value;
    isActionLoading.value = true;
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
        'adminRemarks': remarks,
        'approvedAt': status == 'Approved' ? Timestamp.now() : null,
        'approvedBy': status == 'Approved' ? adminName : null,
      });

      Get.snackbar('Success', 'Payment $status', backgroundColor: Colors.green, colorText: Colors.white);
      _fetchAllPayments(); // Refresh list automatically
      allPayments.refresh();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
