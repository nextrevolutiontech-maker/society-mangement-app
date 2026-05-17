import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/society_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';

class UserController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // ── Loading States ────────────────────────────────────────
  var isLoading = false.obs;
  var isUsersLoading = true.obs;
  var isSocietiesLoading = true.obs;

  // ── Current Admin Info ────────────────────────────────────
  var currentAdminSocietyId = ''.obs;
  var currentAdminRole = ''.obs;
  var isShowingSpecificSociety = false.obs;
  var specificSocietyId = ''.obs;
  var specificSocietyName = ''.obs;

  // ── User List State ───────────────────────────────────────
  var usersList = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;
  var selectedFilter = 'All'.obs;

  // ── Society List State ────────────────────────────────────
  var societiesList = <SocietyModel>[].obs;

  // ── Form Controllers ─────────────────────────────────────
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final flatNoController = TextEditingController();
  final blockController = TextEditingController();
  final emailController = TextEditingController();

  // Society form controllers
  final societyNameController = TextEditingController();
  final societyAddressController = TextEditingController();
  final societyFlatsController = TextEditingController();
  final customFlatTypeController = TextEditingController();

  // ── Dropdown Observables ──────────────────────────────────
  var selectedFlatType = '2BHK'.obs;
  var flatTypes = <String>['1BHK', '2BHK', '3BHK', '4BHK', '5BHK', 'Custom / Other'].obs;
  var isCustomFlatType = false.obs;

  var selectedSocietyId = ''.obs;

  // ── User Counts ───────────────────────────────────────────
  var totalResidents = 0.obs;
  var totalGuards = 0.obs;
  var totalAdmins = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentAdminInfo();
    
    // Auto-fetch flat types when society ID changes
    ever(currentAdminSocietyId, (sId) {
      if (sId.isNotEmpty) fetchSocietyFlatTypes(sId);
    });
    
    ever(selectedSocietyId, (sId) {
      if (sId.isNotEmpty) fetchSocietyFlatTypes(sId);
    });
  }

  // ════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════════

  Future<void> fetchSocietyFlatTypes(String sId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('societies').doc(sId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['maintenanceByFlatType'] != null) {
          final Map<String, dynamic> slabs = Map<String, dynamic>.from(data['maintenanceByFlatType']);
          
          // Start with standard types
          final Set<String> allTypes = {'1BHK', '2BHK', '3BHK', '4BHK', '5BHK'};
          
          // Add types from existing slabs
          allTypes.addAll(slabs.keys.map((k) => k.toString()));
          
          // Sort and add 'Custom / Other' at the end
          final sortedList = allTypes.toList()..sort();
          sortedList.add('Custom / Other');
          
          flatTypes.assignAll(sortedList);
          
          // Update selected if current one isn't in the new list
          if (!flatTypes.contains(selectedFlatType.value)) {
            selectedFlatType.value = flatTypes.first;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching flat types: $e');
    }
  }

  Future<void> _loadCurrentAdminInfo() async {
    try {
      String? identifier = StorageService.getUserIdentifier();
      String? role = StorageService.getUserRole();
      currentAdminRole.value = role ?? '';

      if (identifier != null && identifier.isNotEmpty) {
        UserModel? currentUser;
        if (identifier.contains('@')) {
          currentUser = await _firestoreService.getUserByEmail(identifier);
        } else {
          currentUser = await _firestoreService.getUserByMobile(identifier);
        }

        if (currentUser != null) {
          currentAdminSocietyId.value = currentUser.societyId;
        }
      }

      // Load data based on role
      if (role == 'super_admin') {
        await loadAllSocieties();
        await loadAllUsers();
      } else if (role == 'admin') {
        await loadSocietyUsers();
      }
    } catch (e) {
      debugPrint('Error loading admin info: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // LOAD USERS
  // ════════════════════════════════════════════════════════════

  /// Load all users for the admin's society
  Future<void> loadSocietyUsers() async {
    if (currentAdminSocietyId.value.isEmpty) return;
    isUsersLoading.value = true;
    try {
      if (isShowingSpecificSociety.value) return; // Don't overwrite if showing specific society
      usersList.value = await _firestoreService.getUsersBySociety(currentAdminSocietyId.value);
      _applyFilter();
      _updateCounts();
    } catch (e) {
      _showError('Failed to load users: $e');
    } finally {
      isUsersLoading.value = false;
    }
  }

  /// Load all users across all societies (Super Admin)
  Future<void> loadAllUsers() async {
    isUsersLoading.value = true;
    try {
      if (isShowingSpecificSociety.value) return; // Don't overwrite if showing specific society
      usersList.value = await _firestoreService.getAllUsers();
      _applyFilter();
      _updateCounts();
    } catch (e) {
      _showError('Failed to load users: $e');
    } finally {
      isUsersLoading.value = false;
    }
  }

  /// Load users for a specific society (used by Super Admin)
  Future<void> loadUsersBySpecificSociety(String societyId, [String? societyName]) async {
    isUsersLoading.value = true;
    isShowingSpecificSociety.value = true;
    specificSocietyId.value = societyId;
    if (societyName != null) specificSocietyName.value = societyName;
    
    try {
      usersList.clear(); // Clear old data
      usersList.value = await _firestoreService.getUsersBySociety(societyId);
      _applyFilter();
      _updateCounts();
    } catch (e) {
      _showError('Failed to load society users: $e');
    } finally {
      isUsersLoading.value = false;
    }
  }

  /// Clear the specific society filter and show all users (Super Admin)
  Future<void> clearSpecificSocietyFilter() async {
    isShowingSpecificSociety.value = false;
    specificSocietyId.value = '';
    specificSocietyName.value = '';
    await loadAllUsers();
  }

  /// Apply role filter on the users list
  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedFilter.value == 'All') {
      filteredUsers.value = List.from(usersList);
    } else {
      String roleFilter = selectedFilter.value.toLowerCase();
      // Handle plural labels → singular role keys
      if (roleFilter == 'residents') roleFilter = 'resident';
      if (roleFilter == 'guards') roleFilter = 'guard';
      if (roleFilter == 'admins') roleFilter = 'admin';
      filteredUsers.value = usersList.where((u) => u.role == roleFilter).toList();
    }
  }

  void _updateCounts() {
    totalResidents.value = usersList.where((u) => u.role == 'resident').length;
    totalGuards.value = usersList.where((u) => u.role == 'guard').length;
    totalAdmins.value = usersList.where((u) => u.role == 'admin').length;
  }

  // ════════════════════════════════════════════════════════════
  // ADD RESIDENT (Admin capability)
  // ════════════════════════════════════════════════════════════

  Future<void> addResident() async {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();
    String flatNo = flatNoController.text.trim();
    String block = blockController.text.trim();

    // Determine society ID
    String societyId = currentAdminSocietyId.value;
    if (currentAdminRole.value == 'super_admin' && selectedSocietyId.value.isNotEmpty) {
      societyId = selectedSocietyId.value;
    }

    if (societyId.isEmpty) {
      _showError('No society assigned. Please contact Super Admin.');
      return;
    }

    if (name.isEmpty) {
      _showError('Name is required');
      return;
    }
    if (!_isValidMobile(mobile)) {
      _showError('Enter a valid 10-digit mobile number starting with 6-9');
      return;
    }
    if (flatNo.isEmpty) {
      _showError('Flat number is required');
      return;
    }
    if (email.isEmpty) {
      _showError('Email is required');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      String? creatorId = StorageService.getUserIdentifier();

      UserModel newUser = UserModel(
        name: name,
        email: email,
        mobile: '+91$mobile',
        role: 'resident',
        societyId: societyId,
        flatNo: flatNo,
        flatType: selectedFlatType.value == 'Custom / Other' 
            ? customFlatTypeController.text.trim() 
            : selectedFlatType.value,
        block: block.isEmpty ? null : block,
        isActive: true,
        createdBy: creatorId,
      );

      await _firestoreService.addUser(newUser);

      clearForm();
      Get.back();
      Get.snackbar(
        '✅ Resident Added',
        '$name has been registered to Flat $flatNo',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 3),
      );

      // Refresh list
      _refreshUsers();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // EDIT RESIDENT
  // ════════════════════════════════════════════════════════════

  void setupEditResident(UserModel user) {
    nameController.text = user.name;
    // Strip +91 for UI editing
    mobileController.text = user.mobile.startsWith('+91') ? user.mobile.substring(3) : user.mobile;
    emailController.text = user.email;
    flatNoController.text = user.flatNo ?? '';
    blockController.text = user.block ?? '';
    
    final ft = user.flatType ?? '2BHK';
    if (flatTypes.contains(ft)) {
      selectedFlatType.value = ft;
      isCustomFlatType.value = false;
      customFlatTypeController.clear();
    } else {
      selectedFlatType.value = 'Custom / Other';
      isCustomFlatType.value = true;
      customFlatTypeController.text = ft;
    }
  }

  void setupEditAdmin(UserModel user) {
    nameController.text = user.name;
    mobileController.text = user.mobile.startsWith('+91') ? user.mobile.substring(3) : user.mobile;
    emailController.text = user.email;
    selectedSocietyId.value = user.societyId;
    loadAllSocieties(); // Ensure list is loaded for dropdown
  }

  Future<void> updateAdmin(UserModel user) async {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || mobile.isEmpty || email.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (!_isValidMobile(mobile)) {
      _showError('Invalid mobile number');
      return;
    }

    try {
      isLoading.value = true;

      // Use user.id if available, otherwise fallback to mobile
      final docId = user.id ?? user.mobile;

      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'name': name,
        'mobile': '+91$mobile',
        'email': email.toLowerCase(),
        'society_id': selectedSocietyId.value,
      });

      Get.back();
      Get.snackbar(
        'Success',
        'Admin updated successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      
      // Refresh list
      if (isShowingSpecificSociety.value) {
        await loadUsersBySpecificSociety(specificSocietyId.value);
      } else {
        await loadAllUsers();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateResident(UserModel user) async {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();
    String flatNo = flatNoController.text.trim();
    String block = blockController.text.trim();

    if (name.isEmpty) {
      _showError('Name is required');
      return;
    }
    if (!_isValidMobile(mobile)) {
      _showError('Enter a valid 10-digit mobile number starting with 6-9');
      return;
    }
    if (user.role == 'resident' && flatNo.isEmpty) {
      _showError('Flat number is required');
      return;
    }

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      String fullMobile = '+91$mobile';
      if (fullMobile != user.mobile && await _firestoreService.isMobileDuplicated(fullMobile)) {
        _showError('Mobile number already registered');
        isLoading.value = false;
        return;
      }

      if (flatNo != user.flatNo || block != user.block) {
        if (await _firestoreService.isFlatDuplicated(user.societyId, flatNo, block)) {
          _showError('Flat is already assigned');
          isLoading.value = false;
          return;
        }
      }

      // NOTE: Case insensitivity for email is also maintained here by the server handling.
      Map<String, dynamic> updateData = {
        'name': name,
        'mobile': '+91$mobile',
        'email': email.toLowerCase(),
        'flat_no': flatNo,
        'flat_type': selectedFlatType.value == 'Custom / Other' 
            ? customFlatTypeController.text.trim() 
            : selectedFlatType.value,
        'block': block.isEmpty ? null : block,
      };

      await _firestoreService.updateUser(user.id!, updateData);

      clearForm();
      Get.back();
      Get.snackbar(
        '✅ Resident Updated',
        '$name details have been updated',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 3),
      );

      _refreshUsers();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // ADD GUARD (Admin capability)
  // ════════════════════════════════════════════════════════════

  Future<void> addGuard() async {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();

    String societyId = currentAdminSocietyId.value;
    if (currentAdminRole.value == 'super_admin' && selectedSocietyId.value.isNotEmpty) {
      societyId = selectedSocietyId.value;
    }

    if (societyId.isEmpty) {
      _showError('No society assigned. Please contact Super Admin.');
      return;
    }

    if (name.isEmpty) {
      _showError('Name is required');
      return;
    }
    if (!_isValidMobile(mobile)) {
      _showError('Enter a valid 10-digit mobile number starting with 6-9');
      return;
    }
    if (email.isEmpty) {
      _showError('Email is required');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      String? creatorId = StorageService.getUserIdentifier();

      UserModel newUser = UserModel(
        name: name,
        email: email,
        mobile: '+91$mobile',
        role: 'guard',
        societyId: societyId,
        isActive: true,
        createdBy: creatorId,
      );

      await _firestoreService.addUser(newUser);

      clearForm();
      Get.back();
      Get.snackbar(
        '✅ Guard Added',
        '$name has been registered as a guard',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 3),
      );

      _refreshUsers();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // ADD ADMIN (Super Admin capability only)
  // ════════════════════════════════════════════════════════════

  Future<void> addAdmin(String societyId) async {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty) {
      _showError('Name is required');
      return;
    }
    if (!_isValidMobile(mobile)) {
      _showError('Enter a valid 10-digit mobile number starting with 6-9');
      return;
    }
    if (societyId.isEmpty) {
      _showError('Please select a society for the admin');
      return;
    }
    if (email.isEmpty) {
      _showError('Email is required');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      String? creatorId = StorageService.getUserIdentifier();

      UserModel newUser = UserModel(
        name: name,
        email: email,
        mobile: '+91$mobile',
        role: 'admin',
        societyId: societyId,
        isActive: true,
        createdBy: creatorId,
      );

      await _firestoreService.addUser(newUser);

      clearForm();
      Get.back();
      Get.snackbar(
        '✅ Admin Created',
        '$name is now admin for the society',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );

      _refreshUsers();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // DELETE USER
  // ════════════════════════════════════════════════════════════

  Future<void> deleteUser(UserModel user) async {
    try {
      if (user.id == null) return;

      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Remove User'),
          content: Text('Are you sure you want to remove ${user.name} (${user.role})?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestoreService.deleteUser(user.id!);
        Get.snackbar(
          'Removed',
          '${user.name} has been removed',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
        );
        _refreshUsers();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ════════════════════════════════════════════════════════════
  // TOGGLE USER STATUS
  // ════════════════════════════════════════════════════════════

  Future<void> toggleUserStatus(UserModel user) async {
    try {
      if (user.id == null) return;

      // 1. ROLE CHECK
      if (currentAdminRole.value != 'admin' && currentAdminRole.value != 'super_admin') {
        _showError('Unauthorized action.');
        return;
      }

      bool newStatus = !user.isActive;
      
      // OPTIMISTIC UPDATE: Update local list immediately for instant UI response
      int index = usersList.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        usersList[index] = usersList[index].copyWith(isActive: newStatus);
        _applyFilter();
        update(); 
      }

      await _firestoreService.toggleUserStatus(user.id!, newStatus);
      
      Get.snackbar(
        newStatus ? 'Activated' : 'Deactivated',
        '${user.name} is now ${newStatus ? "active" : "inactive"}',
        backgroundColor: newStatus ? const Color(0xFF2E7D32) : Colors.orange.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );
      
      // Still refresh from server to ensure sync
      _refreshUsers();
    } catch (e) {
      _showError('Failed to update status: $e');
      // Rollback on error
      _refreshUsers();
    }
  }

  // ════════════════════════════════════════════════════════════
  // SOCIETY MANAGEMENT (Super Admin)
  // ════════════════════════════════════════════════════════════

  Future<void> loadAllSocieties() async {
    isSocietiesLoading.value = true;
    try {
      societiesList.value = await _firestoreService.getAllSocieties();
    } catch (e) {
      _showError('Failed to load societies: $e');
    } finally {
      isSocietiesLoading.value = false;
    }
  }

  Future<void> addSociety() async {
    String name = societyNameController.text.trim();
    String address = societyAddressController.text.trim();
    String flats = societyFlatsController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      _showError('Society name and address are required');
      return;
    }

    isLoading.value = true;
    try {
      await _firestoreService.createSociety(name, address, totalFlats: flats.isEmpty ? null : flats);
      _clearSocietyForm();
      Get.back();
      Get.snackbar(
        '✅ Society Created',
        '$name has been added',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      await loadAllSocieties();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSocietyStatus(SocietyModel society) async {
    try {
      if (society.id == null) return;

      String newStatus = society.status == 'active' ? 'inactive' : 'active';
      
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(newStatus == 'inactive' ? 'Deactivate Society' : 'Activate Society'),
          content: Text(newStatus == 'inactive' 
            ? 'Are you sure you want to deactivate "${society.name}"? This will also deactivate ALL users in this society.'
            : 'Are you sure you want to activate "${society.name}"?'),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'inactive' ? Colors.redAccent : const Color(0xFF2E7D32)
              ),
              child: Text(newStatus == 'inactive' ? 'Deactivate' : 'Activate', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;
        await _firestoreService.updateSocietyStatus(society.id!, newStatus);
        Get.snackbar(
          newStatus == 'active' ? 'Activated' : 'Deactivated',
          '${society.name} is now ${newStatus == 'active' ? "Active" : "Inactive"}',
          backgroundColor: newStatus == 'active' ? const Color(0xFF2E7D32) : Colors.orange.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
        );
        await loadAllSocieties();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSociety(String societyId) async {
    String name = societyNameController.text.trim();
    String address = societyAddressController.text.trim();
    String flats = societyFlatsController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      _showError('Society name and address are required');
      return;
    }

    isLoading.value = true;
    try {
      await _firestoreService.updateSociety(societyId, {
        'name': name,
        'address': address,
        'total_flats': flats.isEmpty ? null : flats,
      });
      _clearSocietyForm();
      Get.back();
      Get.snackbar(
        '✅ Updated',
        'Society details updated successfully',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      await loadAllSocieties();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void setupEditSociety(SocietyModel society) {
    societyNameController.text = society.name;
    societyAddressController.text = society.address;
    societyFlatsController.text = society.totalFlats ?? '';
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  String getSocietyName(String id) {
    if (id.isEmpty) return 'No Society';
    try {
      final society = societiesList.firstWhere((s) => s.id == id);
      return society.name;
    } catch (_) {
      return 'Unknown';
    }
  }

  void _refreshUsers() {
    if (isShowingSpecificSociety.value) {
      loadUsersBySpecificSociety(specificSocietyId.value, specificSocietyName.value);
    } else if (currentAdminRole.value == 'super_admin') {
      loadAllUsers();
    } else {
      loadSocietyUsers();
    }
  }

  bool _isValidMobile(String phone) {
    return phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  void clearForm() {
    nameController.clear();
    mobileController.clear();
    flatNoController.clear();
    blockController.clear();
    emailController.clear();
    customFlatTypeController.clear();
    isCustomFlatType.value = false;
    selectedFlatType.value = '2BHK';
  }

  void _clearSocietyForm() {
    societyNameController.clear();
    societyAddressController.clear();
    societyFlatsController.clear();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    flatNoController.dispose();
    blockController.dispose();
    emailController.dispose();
    societyNameController.dispose();
    societyAddressController.dispose();
    societyFlatsController.dispose();
    super.onClose();
  }
}
