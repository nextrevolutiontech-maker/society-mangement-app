import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/complaint_model.dart';

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

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
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

        // Now load the complaints for this user/society
        _fetchComplaints();
      }
    } catch (e) {
      debugPrint('ComplaintController._loadCurrentUser: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _fetchComplaints() {
    if (currentUserSocietyId.value.isEmpty) return;

    Query query = _firestore
        .collection('complaints')
        .where('societyId', isEqualTo: currentUserSocietyId.value);

    // Residents only see their own complaints
    if (currentUserRole.value == 'resident') {
      query = query.where('residentId', isEqualTo: currentUserId.value);
    }

    query.orderBy('createdAt', descending: true).snapshots().listen((snap) {
      complaints.value = snap.docs.map((doc) {
        return ComplaintModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    }, onError: (e) {
      debugPrint('ComplaintController._fetchComplaints stream error: $e');
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

      titleController.clear();
      descriptionController.clear();

      Get.snackbar(
        '✅ Complaint Submitted',
        'Your complaint has been submitted successfully.',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 3),
      );

      // Navigate to My Complaints
      Get.offNamed('/my-complaints');
    } catch (e) {
      _showError('Failed to submit complaint. Please try again.');
      debugPrint('submitComplaint error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Update complaint status (Admin only) ──────────────
  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    // Enforce forward-only flow
    const flow = ['Open', 'In Progress', 'Resolved'];
    final complaint = complaints.firstWhere((c) => c.id == complaintId);
    final currentIdx = flow.indexOf(complaint.status);
    final newIdx = flow.indexOf(newStatus);

    if (newIdx <= currentIdx) {
      _showError('Status can only move forward: Open → In Progress → Resolved');
      return;
    }

    try {
      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .update({'status': newStatus, 'updatedAt': DateTime.now().toIso8601String()});

      Get.snackbar(
        '✅ Status Updated',
        'Complaint status changed to $newStatus',
        backgroundColor: const Color(0xFF1565C0),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );

      Get.back();
    } catch (e) {
      _showError('Failed to update status. Please try again.');
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
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
