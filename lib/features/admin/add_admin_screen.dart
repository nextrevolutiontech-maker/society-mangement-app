import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'controllers/user_controller.dart';

class AddAdminScreen extends StatelessWidget {
  AddAdminScreen({super.key});

  final UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF263238), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Admin',
          style: GoogleFonts.poppins(
            color: const Color(0xFF263238),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A1B9A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Admin',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Assign an admin to a society',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Select Society ───────────────────────────
            Text(
              'Select Society',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isSocietiesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.societiesList.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF6C00)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No societies found. Please add a society first.',
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFEF6C00)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: controller.selectedSocietyId.value.isEmpty
                      ? null
                      : controller.selectedSocietyId.value,
                  decoration: InputDecoration(
                    labelText: 'Society',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                    prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFF6A1B9A), size: 22),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  hint: Text('Choose a society', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8))),
                  items: controller.societiesList
                      .map((society) => DropdownMenuItem(
                            value: society.id,
                            child: Text(
                              society.name,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectedSocietyId.value = value;
                  },
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                ),
              );
            }),

            const SizedBox(height: 25),

            // ── Admin Details ────────────────────────────
            Text(
              'Admin Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 12),

            // Name Field
            _buildTextField(
              controller: controller.nameController,
              label: 'Full Name',
              hint: 'Enter admin name',
              icon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 15),

            // Mobile Field
            _buildTextField(
              controller: controller.mobileController,
              label: 'Mobile Number',
              hint: '10-digit number (e.g. 9876543210)',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              isPhone: true,
            ),
            const SizedBox(height: 15),

            // Email Field
            _buildTextField(
              controller: controller.emailController,
              label: 'Email (Optional)',
              hint: 'Google Sign-In email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 30),

            // ── Rules Info ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFAB47BC).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFF7B1FA2), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Super Admin Only',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Only Super Admin can create Admins\n• Admin gets full society management access\n• Admin can add Residents and Guards',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF4A148C),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Submit Button ───────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.addAdmin(controller.selectedSocietyId.value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFF6A1B9A).withOpacity(0.4),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.admin_panel_settings_rounded, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Create Admin',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8)),
          prefixIcon: isPhone 
            ? Container(
                width: 70,
                padding: const EdgeInsets.only(left: 15, right: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.phone_android_rounded, color: Color(0xFF6A1B9A), size: 18),
                    const SizedBox(width: 4),
                    Text('+91', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF6A1B9A))),
                  ],
                ),
              )
            : Icon(icon, color: const Color(0xFF6A1B9A), size: 22),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
