import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';
import '../../core/models/complaint_model.dart';

class SuperAdminComplaintsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoadingSocieties = false.obs;
  var societies = <Map<String, dynamic>>[].obs;
  var selectedSocietyId = ''.obs;

  var isLoadingData = false.obs;
  var users = <UserModel>[].obs;
  var complaints = <ComplaintModel>[].obs;

  // ── Stream Subscriptions ──────────────────────────────
  StreamSubscription? _usersSubscription;
  StreamSubscription? _complaintsSubscription;

  @override
  void onInit() {
    super.onInit();
    _fetchSocieties();
  }

  Future<void> _fetchSocieties() async {
    isLoadingSocieties.value = true;
    try {
      final snap = await _firestore.collection('societies').get();
      societies.value = snap.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'] ?? 'Unknown Society',
      }).toList();
    } catch (e) {
      debugPrint('Error fetching societies: $e');
    } finally {
      isLoadingSocieties.value = false;
    }
  }

  void onSocietySelected(String? societyId) {
    if (societyId == null || societyId.isEmpty) return;
    selectedSocietyId.value = societyId;
    _listenToSocietyData(societyId);
  }

  void _listenToSocietyData(String societyId) {
    isLoadingData.value = true;
    
    // Cancel existing subscriptions
    _usersSubscription?.cancel();
    _complaintsSubscription?.cancel();

    // 1. Listen to users for this society
    _usersSubscription = _firestore
        .collection('users')
        .where('society_id', isEqualTo: societyId)
        .snapshots()
        .listen((snap) {
      users.value = snap.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      isLoadingData.value = false; // Turn off loading when first batch arrives
    }, onError: (e) {
      debugPrint('Error listening to users: $e');
      isLoadingData.value = false;
    });

    // 2. Listen to all complaints for this society
    _complaintsSubscription = _firestore
        .collection('complaints')
        .where('societyId', isEqualTo: societyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      complaints.value = snap.docs
          .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
          .toList();
    }, onError: (e) {
      debugPrint('Error listening to complaints: $e');
    });
  }

  bool hasComplaint(String userId) {
    return complaints.any((c) => c.residentId == userId);
  }

  List<ComplaintModel> getUserComplaints(String userId) {
    return complaints.where((c) => c.residentId == userId).toList();
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    _complaintsSubscription?.cancel();
    super.onClose();
  }
}
