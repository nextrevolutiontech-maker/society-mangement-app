import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/payment_model.dart';
import '../dashboard_controller.dart';

class PaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  // Reactive state
  var currentMaintenanceAmount = 0.0.obs;
  var currentFlatTypeAmounts = <String, double>{}.obs;
  var currentUpiId = ''.obs;
  var currentPaymentName = ''.obs;
  
  var myPayments = <PaymentModel>[].obs;
  var allPayments = <PaymentModel>[].obs;
  
  var isLoading = false.obs;
  var isSettingsLoading = false.obs;
  var isActionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initial fetch attempts
    _fetchSocietyPaymentSettings();
    if (_dashboardController.currentUserRole.value == 'resident') {
      _fetchMyPayments();
    } else {
      _fetchAllPayments();
    }

    // Task: Re-fetch whenever society ID or Role changes (e.g. after profile loads)
    ever(_dashboardController.currentUserSociety, (_) {
      _fetchSocietyPaymentSettings();
      if (_dashboardController.currentUserRole.value == 'resident') {
        _fetchMyPayments();
      } else {
        _fetchAllPayments();
      }
    });

    // Task: Recalculate amount whenever resident's flat type is loaded/changed
    ever(_dashboardController.currentUserFlatType, (_) {
      currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
    });
  }

  /// Saves UPI + display name only (flat-type slabs are edited via upsert/delete).
  Future<void> savePaymentIdentifiers({required String upiId, required String name}) async {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) {
      Get.snackbar('Error', 'Society ID not found. Please wait for profile to load or login again.', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final trimmedUpi = upiId.trim();
    final trimmedName = name.trim();
    
    // If not clearing, validate UPI format
    if (trimmedUpi.isNotEmpty && !trimmedUpi.contains('@')) {
      Get.snackbar('Invalid UPI', 'Please enter a valid UPI ID (e.g. name@bank)', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isSettingsLoading.value = true;
    try {
      await _firestore.collection('societies').doc(societyId).set({
        'upiId': trimmedUpi,
        'paymentName': trimmedName,
      }, SetOptions(merge: true));
      
      currentUpiId.value = trimmedUpi;
      currentPaymentName.value = trimmedName;
      
      if (trimmedUpi.isEmpty) {
        Get.snackbar('Deleted', 'UPI details cleared successfully', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Success', 'UPI details saved successfully', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save UPI details: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
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
        currentUpiId.value = data['upiId'] ?? '';
        currentPaymentName.value = data['paymentName'] ?? '';
      } else {
        currentFlatTypeAmounts.value = {};
        currentMaintenanceAmount.value = _currentUserMaintenanceAmount();
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
      myPayments.value = snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data(), doc.id)).toList();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error fetching my payments: $e');
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
        .snapshots()
        .listen((snapshot) {
      allPayments.value = snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data(), doc.id)).toList();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error fetching all payments: $e');
      isLoading.value = false;
    });
  }

  // Resident: Get remaining dues for current month
  double getRemainingDues() {
    String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    double totalPaid = 0.0;
    for (var p in myPayments) {
      if (p.month == currentMonth && p.status != 'Rejected') {
        totalPaid += p.amount;
      }
    }
    final monthlyAmount = _currentUserMaintenanceAmount();
    if (currentMaintenanceAmount.value != monthlyAmount) {
      currentMaintenanceAmount.value = monthlyAmount;
    }
    double remaining = monthlyAmount - totalPaid;
    return remaining > 0 ? remaining : 0.0;
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
    final othersAmount = getAmountForFlatType('Others');
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

  // Resident: Initiate UPI Payment (Launch app)
  Future<bool> initiateUPIPayment() async {
    if (currentMaintenanceAmount.value <= 0) {
      Get.snackbar('Notice', 'No maintenance amount set by Admin', backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    if (currentUpiId.value.isEmpty || currentPaymentName.value.isEmpty) {
      Get.snackbar('Notice', 'Payment details not fully configured by Admin', backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    
    double amountToPay = getRemainingDues();
    if (amountToPay <= 0) {
      Get.snackbar('Notice', 'No pending dues for this month', backgroundColor: const Color(0xFF1565C0), colorText: Colors.white);
      return false;
    }

    // Task 27: Validate UPI ID existence
    if (currentUpiId.value.isEmpty || !currentUpiId.value.contains('@')) {
      Get.snackbar('Payment Error', 'Society UPI ID is not configured properly by Admin.', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    final String upiUrl = 'upi://pay?pa=${currentUpiId.value.trim()}&pn=${Uri.encodeComponent(currentPaymentName.value.trim())}&am=${amountToPay.toStringAsFixed(2)}&cu=INR';
    final Uri uri = Uri.parse(upiUrl);

    try {
      // Use externalApplication as it's more compatible with various Android versions
      bool launched = await launchUrl(
        uri, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        debugPrint('System could not launch $upiUrl');
        await Clipboard.setData(ClipboardData(text: currentUpiId.value));
        Get.snackbar('Manual Payment', 'Society UPI ID copied to clipboard. Please paste it in Paytm manually.', 
          backgroundColor: Colors.orange, colorText: Colors.white);
        return true; 
      }
      return true;
    } catch (e) {
      debugPrint('Error launching UPI: $e');
      await Clipboard.setData(ClipboardData(text: currentUpiId.value));
      Get.snackbar('Manual Payment', 'UPI ID copied. Please paste it in your payment app.', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return true;
    }
  }

  // Resident: Confirm Payment Record after returning from UPI app
  Future<void> confirmPaymentRecord() async {
    final userId = _dashboardController.currentUserId.value;
    if (userId.isEmpty) return;

    isActionLoading.value = true;
    String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    double amountToPay = getRemainingDues();
    if (amountToPay <= 0) return;

    try {
      final payment = PaymentModel(
        userId: userId,
        userName: _dashboardController.currentUserName.value,
        flatNumber: _dashboardController.currentUserFlat.value,
        societyId: _dashboardController.currentUserSociety.value,
        month: currentMonth,
        amount: amountToPay,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('payments').add(payment.toMap());
      Get.snackbar('Success', 'Payment submitted successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit payment: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isActionLoading.value = false;
    }
  }

  // Admin: Update Payment Status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    final adminName = _dashboardController.currentUserName.value;
    isActionLoading.value = true;
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
        'approvedAt': status == 'Approved' ? Timestamp.now() : null,
        'approvedBy': status == 'Approved' ? adminName : null,
      });

      final idx = allPayments.indexWhere((p) => p.id == paymentId);
      if (idx != -1) {
        final prev = allPayments[idx];
        allPayments[idx] = PaymentModel(
          userId: prev.userId,
          userName: prev.userName,
          flatNumber: prev.flatNumber,
          societyId: prev.societyId,
          month: prev.month,
          amount: prev.amount,
          status: status,
          createdAt: prev.createdAt,
          approvedAt: status == 'Approved' ? DateTime.now() : null,
          approvedBy: status == 'Approved' ? adminName : null,
          id: prev.id,
        );
      }

      Get.snackbar('Success', 'Status updated to $status', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
