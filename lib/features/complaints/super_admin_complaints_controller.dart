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
    _fetchSocietyData(societyId);
  }

  Future<void> _fetchSocietyData(String societyId) async {
    isLoadingData.value = true;
    try {
      // Fetch users for this society
      final usersSnap = await _firestore
          .collection('users')
          .where('society_id', isEqualTo: societyId)
          .get();

      users.value = usersSnap.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      // Fetch all complaints for this society
      final complaintsSnap = await _firestore
          .collection('complaints')
          .where('societyId', isEqualTo: societyId)
          .get();

      complaints.value = complaintsSnap.docs
          .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      debugPrint('Error fetching society data: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  bool hasComplaint(String userId) {
    return complaints.any((c) => c.residentId == userId);
  }

  List<ComplaintModel> getUserComplaints(String userId) {
    return complaints.where((c) => c.residentId == userId).toList();
  }
}
