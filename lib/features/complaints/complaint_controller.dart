import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/complaint_model.dart';
import '../dashboard_controller.dart';

class ComplaintController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── State ─────────────────────────────────────────────
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var complaints = <ComplaintModel>[].obs;

  // ── Form Controllers ──────────────────────────────────
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ── Current user info (populated on init) ─────────────
  var currentUserName = ''.obs;
  var currentUserFlat = ''.obs;
  var currentUserSocietyId = ''.obs;
  var currentUserId = ''.obs;
  var currentUserRole = ''.obs;

  // ── Stream Subscriptions ──────────────────────────────
  StreamSubscription? _complaintSubscription;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  /// Clears Firestore listeners and cached list (call on logout).
  void clearForLogout() {
    _complaintSubscription?.cancel();
    _complaintSubscription = null;
    complaints.clear();
    currentUserName.value = '';
    currentUserFlat.value = '';
    currentUserSocietyId.value = '';
    currentUserId.value = '';
    currentUserRole.value = '';
    titleController.clear();
    descriptionController.clear();
    formKey.currentState?.reset();
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      final identifier = StorageService.getUserIdentifier();
      final role = StorageService.getUserRole();
      currentUserRole.value = role ?? '';

      if (identifier == null || identifier.isEmpty) return;

      QuerySnapshot snap;
      if (identifier.contains('@')) {
        snap = await _firestore
            .collection('users')
            .where('email', isEqualTo: identifier.toLowerCase())
            .limit(1)
            .get();
      } else {
        snap = await _firestore
            .collection('users')
            .where('mobile', isEqualTo: identifier)
            .limit(1)
            .get();
      }

      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data() as Map<String, dynamic>;
        currentUserName.value = data['name'] ?? '';
        currentUserFlat.value = '${data['block'] ?? ''}${data['flat_no'] ?? ''}';
        currentUserSocietyId.value = data['society_id'] ?? '';
        currentUserId.value = snap.docs.first.id;

        // Now load the complaints for this user/society (Real-time)
        _listenToComplaints();
      }
    } catch (e) {
      debugPrint('ComplaintController.loadCurrentUser: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToComplaints() {
    // Try to get society ID from local state, fallback to DashboardController
    String sId = currentUserSocietyId.value;
    if (sId.isEmpty) {
      try {
        final dbController = Get.find<DashboardController>();
        sId = dbController.currentUserSociety.value;
      } catch (_) {}
    }

    if (sId.isEmpty) {
      debugPrint('ComplaintController: No society ID found. Skipping listener.');
      return;
    }

    // Cancel existing subscription if any
    _complaintSubscription?.cancel();

    final Query query = _firestore
        .collection('complaints')
        .where('societyId', isEqualTo: sId)
        .orderBy('createdAt', descending: true);

    _complaintSubscription = query.snapshots().listen((snap) {
      var list = snap.docs.map((doc) {
        return ComplaintModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (currentUserRole.value == 'resident') {
        final String rid = currentUserId.value;
        list = list.where((c) => c.residentId == rid).toList();
      }

      complaints.value = list;
    }, onError: (e) {
      debugPrint('ComplaintController._listenToComplaints error: $e');
    });
  }

  // ── Submit a new complaint (Resident only) ─────────────
  Future<void> submitComplaint() async {
    if (!formKey.currentState!.validate()) return;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (currentUserSocietyId.value.isEmpty) {
      _showError('Unable to get your society info. Please re-login.');
      return;
    }

    isSubmitting.value = true;
    try {
      final docRef = _firestore.collection('complaints').doc();
      final complaint = ComplaintModel(
        id: docRef.id,
        title: title,
        description: description,
        residentName: currentUserName.value,
        flatNumber: currentUserFlat.value,
        residentId: currentUserId.value,
        societyId: currentUserSocietyId.value,
        status: 'Open',
        createdAt: DateTime.now(),
      );

      await docRef.set(complaint.toMap());

      // Immediate UI feedback before the Firestore snapshot round-trip (and safe if snapshot is delayed).
      if (currentUserRole.value != 'resident' ||
          complaint.residentId == currentUserId.value) {
        complaints.removeWhere((c) => c.id == complaint.id);
        complaints.insert(0, complaint);
      }

      titleController.clear();
      descriptionController.clear();

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 60),
              const SizedBox(height: 15),
              const Text('Submitted!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Your complaint has been filed.', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back(); // Close dialog
        Get.back(); // Go back to list
      });
    } catch (e) {
      _showError('Failed to submit complaint. Please try again.');
      debugPrint('submitComplaint error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Update complaint status (Admin only) ──────────────
  Future<bool> updateComplaintStatus(String complaintId, String newStatus) async {
    // Enforce forward-only flow
    const flow = ['Open', 'In Progress', 'Resolved'];
    final complaint = complaints.firstWhere((c) => c.id == complaintId);
    final currentIdx = flow.indexOf(complaint.status);
    final newIdx = flow.indexOf(newStatus);

    if (newIdx <= currentIdx) {
      _showError('Status can only move forward: Open → In Progress → Resolved');
      return false;
    }

    try {
      final now = DateTime.now();
      Map<String, dynamic> updateData = {
        'status': newStatus,
        'updatedAt': now.toIso8601String(),
      };

      if (newStatus == 'In Progress') {
        updateData['inProgressAt'] = now.toIso8601String();
      } else if (newStatus == 'Resolved') {
        updateData['resolvedAt'] = now.toIso8601String();
      }

      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .update(updateData);

      // Keep admin list instantly in sync
      final index = complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        final current = complaints[index];
        complaints[index] = ComplaintModel(
          id: current.id,
          title: current.title,
          description: current.description,
          residentName: current.residentName,
          flatNumber: current.flatNumber,
          residentId: current.residentId,
          societyId: current.societyId,
          status: newStatus,
          createdAt: current.createdAt,
          updatedAt: now,
          inProgressAt: newStatus == 'In Progress' ? now : current.inProgressAt,
          resolvedAt: newStatus == 'Resolved' ? now : current.resolvedAt,
        );
      }

      Get.snackbar(
        '✅ Status Updated',
        'Complaint status changed to $newStatus',
        backgroundColor: const Color(0xFF1565C0),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );

      // Auto-back after 1 second
      Future.delayed(const Duration(milliseconds: 1000), () {
        Get.back();
      });

      return true;
    } catch (e) {
      _showError('Failed to update status. Please try again.');
      return false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
    );
  }

  @override
  void onClose() {
    _complaintSubscription?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
