import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/society_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';

class UserController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // ── Loading States ────────────────────────────────────────
  var isLoading = false.obs;
  var isUsersLoading = false.obs;
  var isSocietiesLoading = false.obs;

  // ── Current Admin Info ────────────────────────────────────
  var currentAdminSocietyId = ''.obs;
  var currentAdminRole = ''.obs;

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

  // ── Dropdown Observables ──────────────────────────────────
  var selectedFlatType = '2BHK'.obs;
  final List<String> flatTypes = ['1BHK', '2BHK', '3BHK', '4BHK', '5BHK'];

  var selectedSocietyId = ''.obs;

  // ── User Counts ───────────────────────────────────────────
  var totalResidents = 0.obs;
  var totalGuards = 0.obs;
  var totalAdmins = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentAdminInfo();
  }

  // ════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════════

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
      usersList.value = await _firestoreService.getAllUsers();
      _applyFilter();
      _updateCounts();
    } catch (e) {
      _showError('Failed to load users: $e');
    } finally {
      isUsersLoading.value = false;
    }
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

    // Validation
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

    isLoading.value = true;
    try {
      String? creatorId = StorageService.getUserIdentifier();

      UserModel newUser = UserModel(
        name: name,
        email: email,
        mobile: mobile,
        role: 'resident',
        societyId: societyId,
        flatNo: flatNo,
        flatType: selectedFlatType.value,
        block: block.isEmpty ? null : block,
        isActive: true,
        createdBy: creatorId,
      );

      await _firestoreService.addUser(newUser);

      _clearForm();
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

    isLoading.value = true;
    try {
      String? creatorId = StorageService.getUserIdentifier();

      UserModel newUser = UserModel(
        name: name,
        email: email,
        mobile: mobile,
        role: 'guard',
        societyId: societyId,
        isActive: true,
        createdBy: creatorId,
      );

      await _firestoreService.addUser(newUser);

      _clearForm();
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

    isLoading.value = true;
    try {
      String? creatorId = StorageService.getUserIdentifier();

      UserModel newUser = UserModel(
        name: name,
        email: email,
        mobile: mobile,
        role: 'admin',
        societyId: societyId,
        isActive: true,
        createdBy: creatorId,
      );

      await _firestoreService.addUser(newUser);

      _clearForm();
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
      bool newStatus = !user.isActive;
      await _firestoreService.toggleUserStatus(user.id!, newStatus);
      Get.snackbar(
        newStatus ? 'Activated' : 'Deactivated',
        '${user.name} is now ${newStatus ? "active" : "inactive"}',
        backgroundColor: newStatus ? const Color(0xFF2E7D32) : Colors.orange.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      _refreshUsers();
    } catch (e) {
      _showError(e.toString());
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

  Future<void> deleteSociety(SocietyModel society) async {
    try {
      if (society.id == null) return;

      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Society'),
          content: Text('Are you sure you want to delete "${society.name}"? This will NOT delete associated users.'),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestoreService.deleteSociety(society.id!);
        Get.snackbar(
          'Deleted',
          '${society.name} has been removed',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
        );
        await loadAllSocieties();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  void _refreshUsers() {
    if (currentAdminRole.value == 'super_admin') {
      loadAllUsers();
    } else {
      loadSocietyUsers();
    }
  }

  bool _isValidMobile(String phone) {
    return phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  void _clearForm() {
    nameController.clear();
    mobileController.clear();
    flatNoController.clear();
    blockController.clear();
    emailController.clear();
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
