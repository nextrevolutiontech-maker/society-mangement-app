import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/storage_service.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.put(AuthService());

  final phoneNumberController = TextEditingController();
  final otpController = TextEditingController();

  var isLoading = false.obs;
  var isOtpSent = false.obs;

  // ──────────────────────────────────────────────
  // Google Sign-In
  // ──────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final User? user = await _authService.signInWithGoogle();
      if (user == null) return; // User cancelled

      final String? email = user.email?.toLowerCase();
      if (email == null) {
        await _handleUserNotFound();
        return;
      }

      // Fetch role from Firestore — NO auto-creation
      final String? role = await _authService.getUserRole(email);

      if (role != null) {
        await StorageService.saveUserSession(role, email);
        _navigateToDashboard(role);
      } else {
        await _handleUserNotFound();
      }
    } catch (e) {
      Get.snackbar(
        'Login Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  // Phone OTP – Step 1: Send OTP
  // ──────────────────────────────────────────────
  void sendOtp() async {
    if (isLoading.value) return;

    String phone = phoneNumberController.text.trim();
    if (!_isValidMobile(phone)) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid 10-digit mobile number starting with 6-9',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    String formattedPhone = '+91$phone';

    await _authService.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        isLoading.value = false;
        isOtpSent.value = true;
        Get.toNamed('/otp');
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Verification Failed',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // Phone OTP – Step 2: Verify OTP
  // ──────────────────────────────────────────────
  void verifyOtp() async {
    if (isLoading.value) return;

    String otp = otpController.text.trim();
    String phone = phoneNumberController.text.trim();

    if (otp.length != 6) {
      Get.snackbar('Invalid OTP', 'Please enter a 6-digit OTP');
      return;
    }

    isLoading.value = true;
    try {
      final User? user = await _authService.signInWithOtp(otp);

      if (user == null) {
        Get.snackbar(
          'Verification Error',
          'OTP verification failed. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // Lookup the user in Firestore — NO auto-creation
      String formattedPhone = phone.startsWith('+91') ? phone : '+91$phone';
      final userModel = await _authService.getUserByMobile(formattedPhone);

      if (userModel != null) {
        await StorageService.saveUserSession(userModel.role, formattedPhone);
        _navigateToDashboard(userModel.role);
      } else {
        // Firebase auth succeeded but user is NOT pre-registered → block access
        await _handleUserNotFound();
      }
    } catch (e) {
      Get.snackbar(
        'Verification Error',
        'Invalid OTP or session expired.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  // Auto-login check (called from main.dart)
  // ──────────────────────────────────────────────
  void checkLoginStatus() {
    if (StorageService.isLoggedIn() && FirebaseAuth.instance.currentUser != null) {
      final String? role = StorageService.getUserRole();
      if (role != null) {
        _navigateToDashboard(role);
        return;
      }
    }
    // No valid session — clear and stay on login
    StorageService.clearSession();
  }

  // ──────────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────────
  void logout() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
      await StorageService.clearSession();
      phoneNumberController.clear();
      otpController.clear();
      isOtpSent.value = false;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  // Private Helpers
  // ──────────────────────────────────────────────

  /// User authenticated with Firebase but has NO Firestore record.
  /// Signs them out immediately and shows an informative message.
  Future<void> _handleUserNotFound() async {
    await _authService.signOut();
    await StorageService.clearSession();

    Get.offAllNamed('/login');
    Get.snackbar(
      'Access Denied',
      'You are not registered. Please contact your society admin.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 5),
    );
  }

  void _navigateToDashboard(String role) {
    switch (role) {
      case 'super_admin':
        Get.offAllNamed('/super-admin-panel');
        break;
      case 'admin':
        Get.offAllNamed('/admin-dashboard');
        break;
      case 'guard':
        Get.offAllNamed('/guard-panel');
        break;
      case 'resident':
        Get.offAllNamed('/dashboard');
        break;
      default:
        Get.snackbar(
          'Access Denied',
          'Unrecognized role. Contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
    }
  }

  bool _isValidMobile(String phone) {
    return phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
