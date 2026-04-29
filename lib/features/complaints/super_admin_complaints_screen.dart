import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme.dart';
import 'super_admin_complaints_controller.dart';
import 'super_admin_view_complaint_screen.dart';

class SuperAdminComplaintsScreen extends StatelessWidget {
  SuperAdminComplaintsScreen({super.key});

  final SuperAdminComplaintsController controller = Get.put(SuperAdminComplaintsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Super Admin Complaints',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Society Selection Dropdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Society',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.isLoadingSocieties.value) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                  }
                  
                  if (controller.societies.isEmpty) {
                    return Text('No societies available.', style: GoogleFonts.poppins(color: Colors.redAccent));
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                    ),
                    hint: Text('Select a society', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                    value: controller.selectedSocietyId.value.isEmpty ? null : controller.selectedSocietyId.value,
                    items: controller.societies.map((society) {
                      return DropdownMenuItem<String>(
                        value: society['id'],
                        child: Text(society['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: controller.onSocietySelected,
                  );
                }),
              ],
            ),
          ),
          
          // User List
          Expanded(
            child: Obx(() {
              if (controller.selectedSocietyId.value.isEmpty) {
                return Center(
                  child: Text('Please select a society to view users.', style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                );
              }

              if (controller.isLoadingData.value) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
              }

              if (controller.users.isEmpty) {
                return Center(
                  child: Text('No users found in this society.', style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  final bool hasComplaint = controller.hasComplaint(user.id!);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1565C0)),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      ),
                      subtitle: Text(
                        'Role: ${user.role.capitalizeFirst}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: hasComplaint
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFB74D)),
                              ),
                              child: Text(
                                'Has Complaint',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
                              ),
                            )
                          : null,
                      onTap: () {
                        if (hasComplaint) {
                          final userComplaints = controller.getUserComplaints(user.id!);
                          Get.to(() => SuperAdminViewComplaintScreen(complaints: userComplaints, userName: user.name));
                        } else {
                          Get.snackbar(
                            'No Complaints',
                            '${user.name} has not raised any complaints.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.grey.shade800,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(15),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
