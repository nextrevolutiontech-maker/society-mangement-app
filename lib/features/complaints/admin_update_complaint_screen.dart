import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import 'complaint_controller.dart';
import '../../core/models/complaint_model.dart';

class AdminUpdateComplaintScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const AdminUpdateComplaintScreen({super.key, required this.complaint});

  @override
  State<AdminUpdateComplaintScreen> createState() => _AdminUpdateComplaintScreenState();
}

class _AdminUpdateComplaintScreenState extends State<AdminUpdateComplaintScreen> {
  final ComplaintController controller = Get.find<ComplaintController>();
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.complaint.status;
  }

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
          'Complaint Details',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Resident', widget.complaint.residentName, Icons.person_rounded),
                  const SizedBox(height: 16),
                  _buildInfoRow('Flat Number', widget.complaint.flatNumber, Icons.home_rounded),
                  const SizedBox(height: 16),
                  _buildInfoRow('Date', DateFormat('MMM dd, yyyy - hh:mm a').format(widget.complaint.createdAt), Icons.calendar_today_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Complaint Details
            Text(
              'Complaint Details',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.complaint.title,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        ),
                      ),
                      _buildStatusBadge(selectedStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      widget.complaint.description,
                      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF475569), height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Update Status
            Text(
              'Change Status',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildRadioOption('Open', const Color(0xFFEA580C)),
                  _buildRadioOption('In Progress', const Color(0xFF2563EB)),
                  _buildRadioOption('Resolved', const Color(0xFF16A34A)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF94A3B8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedStatus == widget.complaint.status) {
                        Get.snackbar('Info', 'Status is already $selectedStatus', 
                          backgroundColor: Colors.blueGrey, colorText: Colors.white);
                        return;
                      }

                      final ok = await controller.updateComplaintStatus(
                        widget.complaint.id,
                        selectedStatus,
                      );
                      if (ok) {
                        // Show success dialog before going back
                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
                            content: Text(
                              'Complaint status updated to $selectedStatus!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                        
                        Future.delayed(const Duration(seconds: 2), () {
                          Get.back(); // close dialog
                          Get.back(); // go back to list
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                    ),
                    child: Text(
                      'Update',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E293B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value, Color activeColor) {
    bool isCurrentStatus = widget.complaint.status == value;
    bool isDisabled = _isStatusDisabled(widget.complaint.status, value);

    return RadioListTile<String>(
      title: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDisabled ? Colors.grey.shade400 : const Color(0xFF334155),
        ),
      ),
      value: value,
      groupValue: selectedStatus,
      activeColor: activeColor,
      contentPadding: EdgeInsets.zero,
      onChanged: isDisabled
          ? null
          : (String? val) {
              setState(() {
                selectedStatus = val!;
              });
            },
    );
  }

  bool _isStatusDisabled(String currentStatus, String targetStatus) {
    const flow = ['Open', 'In Progress', 'Resolved'];
    final currentIdx = flow.indexOf(currentStatus);
    final targetIdx = flow.indexOf(targetStatus);
    return targetIdx < currentIdx; // Can't go backwards
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Open':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFEA580C);
        break;
      case 'In Progress':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        break;
      case 'Resolved':
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
