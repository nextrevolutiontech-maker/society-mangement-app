import 'package:flutter/material.dart';
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
    _fetchSocietyPaymentSettings();
    if (_dashboardController.currentUserRole.value == 'resident') {
      _fetchMyPayments();
    } else {
      _fetchAllPayments();
    }
  }

  // Admin: Update Payment Settings
  Future<void> updatePaymentSettings(double amount, String upiId, String name) async {
    final societyId = _dashboardController.currentUserSociety.value;
    if (societyId.isEmpty) return;

    isSettingsLoading.value = true;
    try {
      await _firestore.collection('societies').doc(societyId).update({
        'maintenanceAmount': amount,
        'upiId': upiId,
        'paymentName': name,
      });
      currentMaintenanceAmount.value = amount;
      currentUpiId.value = upiId;
      currentPaymentName.value = name;
      Get.snackbar('Success', 'Payment settings updated', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
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
        currentMaintenanceAmount.value = (data['maintenanceAmount'] ?? 0.0).toDouble();
        currentUpiId.value = data['upiId'] ?? '';
        currentPaymentName.value = data['paymentName'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching society settings: $e');
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
    double remaining = currentMaintenanceAmount.value - totalPaid;
    return remaining > 0 ? remaining : 0.0;
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
      Get.snackbar('Notice', 'Already paid for this month', backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }

    final String upiUrl = 'upi://pay?pa=${currentUpiId.value}&pn=${Uri.encodeComponent(currentPaymentName.value)}&am=${amountToPay.toStringAsFixed(2)}&cu=INR';
    final Uri uri = Uri.parse(upiUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        Get.snackbar('Error', 'No UPI app found on your device to handle the payment', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch UPI app', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
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
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    final adminName = _dashboardController.currentUserName.value;
    isActionLoading.value = true;
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
        'approvedAt': status == 'Approved' ? Timestamp.now() : null,
        'approvedBy': status == 'Approved' ? adminName : null,
      });
      Get.snackbar('Success', 'Status updated to $status', backgroundColor: Colors.green, colorText: Colors.white);
      Get.back(); // close detail screen
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isActionLoading.value = false;
    }
  }
}
