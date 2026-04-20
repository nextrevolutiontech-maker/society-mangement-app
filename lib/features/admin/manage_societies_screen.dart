import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'controllers/user_controller.dart';
import '../../core/models/society_model.dart';

class ManageSocietiesScreen extends StatelessWidget {
  ManageSocietiesScreen({super.key});

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
          'Manage Societies',
          style: GoogleFonts.poppins(
            color: const Color(0xFF263238),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1565C0), size: 28),
            onPressed: () => _showAddSocietyDialog(context),
          ),
        ],
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isSocietiesLoading.value) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1565C0)),
                SizedBox(height: 15),
                Text('Loading societies...', style: TextStyle(color: Color(0xFF64748B))),
              ],
            ),
          );
        }

        if (controller.societiesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 15),
                Text(
                  'No societies yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tap + to add a society',
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFBDBDBD)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showAddSocietyDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('Add Society', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAllSocieties(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.societiesList.length,
            itemBuilder: (context, index) {
              final society = controller.societiesList[index];
              return _societyCard(society);
            },
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ADD SOCIETY DIALOG
  // ══════════════════════════════════════════════════════════

  void _showAddSocietyDialog(BuildContext context) {
    controller.societyNameController.clear();
    controller.societyAddressController.clear();
    controller.societyFlatsController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_business_rounded, color: Color(0xFF1565C0), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add Society',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF263238)),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Name
                TextField(
                  controller: controller.societyNameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Society Name',
                    hintText: 'e.g. Green Valley Apartments',
                    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFF1565C0), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                  ),
                ),
                const SizedBox(height: 15),

                // Address
                TextField(
                  controller: controller.societyAddressController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Full society address',
                    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF1565C0), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                  ),
                ),
                const SizedBox(height: 15),

                // Total Flats
                TextField(
                  controller: controller.societyFlatsController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Total Flats (Optional)',
                    hintText: 'e.g. 200',
                    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF1565C0), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                  ),
                ),

                const SizedBox(height: 25),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () => controller.addSociety(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Create', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SOCIETY CARD
  // ══════════════════════════════════════════════════════════

  Widget _societyCard(SocietyModel society) {
    Color statusColor;
    switch (society.status) {
      case 'active':
        statusColor = const Color(0xFF2E7D32);
        break;
      case 'pending':
        statusColor = const Color(0xFFEF6C00);
        break;
      default:
        statusColor = const Color(0xFFD32F2F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  society.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  society.status.capitalizeFirst ?? society.status,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  society.address,
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          if (society.totalFlats != null && society.totalFlats!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.apartment_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  '${society.totalFlats} Flats',
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],

          const Divider(height: 25),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View Users
              TextButton.icon(
                onPressed: () {
                  // Navigate to manage users for this society
                  Get.toNamed('/manage-users');
                },
                icon: const Icon(Icons.people_rounded, size: 16, color: Color(0xFF1565C0)),
                label: Text(
                  'View Users',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0)),
                ),
              ),

              // Delete
              IconButton(
                onPressed: () => controller.deleteSociety(society),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF5350), size: 22),
                tooltip: 'Delete Society',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
