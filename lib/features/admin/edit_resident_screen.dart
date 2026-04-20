import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'controllers/user_controller.dart';
import '../../core/models/user_model.dart';

class EditResidentScreen extends StatefulWidget {
  const EditResidentScreen({super.key});

  @override
  State<EditResidentScreen> createState() => _EditResidentScreenState();
}

class _EditResidentScreenState extends State<EditResidentScreen> {
  final UserController controller = Get.find<UserController>();
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = Get.arguments as UserModel;
    controller.setupEditResident(user);
  }

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
          'Edit Resident',
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
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
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
                    child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Details',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Modify information for ${user.name}',
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
            const SizedBox(height: 25),

            // Form Fields
            _sectionLabel('Personal Details'),
            const SizedBox(height: 12),

            _buildTextField(
              controller: controller.nameController,
              label: 'Full Name',
              hint: 'Enter resident name',
              icon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 15),

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

            _buildTextField(
              controller: controller.emailController,
              label: 'Email (Optional)',
              hint: 'Google Sign-In email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 25),
            _sectionLabel('Flat Details'),
            const SizedBox(height: 12),

            _buildTextField(
              controller: controller.flatNoController,
              label: 'Flat Number',
              hint: 'e.g. 101, 202',
              icon: Icons.home_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: controller.blockController,
              label: 'Block (Optional)',
              hint: 'e.g. A, B, Tower-1',
              icon: Icons.business_rounded,
            ),
            const SizedBox(height: 15),

            _buildFlatTypeDropdown(),

            const SizedBox(height: 35),
            
            // Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.updateResident(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
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
                          const Icon(Icons.save_rounded, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Save Changes',
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF263238),
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
                    const Icon(Icons.phone_android_rounded, color: Color(0xFF1565C0), size: 18),
                    const SizedBox(width: 4),
                    Text('+91', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0))),
                  ],
                ),
              )
            : Icon(icon, color: const Color(0xFF1565C0), size: 22),
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

  Widget _buildFlatTypeDropdown() {
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
      child: Obx(() => DropdownButtonFormField<String>(
        value: controller.flatTypes.contains(controller.selectedFlatType.value) 
            ? controller.selectedFlatType.value 
            : controller.flatTypes.first,
        decoration: InputDecoration(
          labelText: 'Flat Type',
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF1565C0), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        items: controller.flatTypes
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) controller.selectedFlatType.value = value;
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(15),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
      )),
    );
  }
}
