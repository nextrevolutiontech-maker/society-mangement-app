import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme.dart';
import '../dashboard_controller.dart';
import '../auth/controllers/auth_controller.dart';

class GuardPanelScreen extends StatelessWidget {
  GuardPanelScreen({super.key});

  final DashboardController controller = Get.put(DashboardController());

  // Form controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _flatController = TextEditingController();
  final _blockController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 95,
            toolbarHeight: 95,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF00897B),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF00695C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: GetBuilder<DashboardController>(
              builder: (controller) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.security_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.currentUserName.value,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${controller.societyName.value} | Guard',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.find<AuthController>().logout(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Visitor Entry Form ─────────────────
                  Text(
                    'Visitor Entry',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fill visitor details and check-in',
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  _buildField(_nameController, 'Visitor Name', Icons.person_rounded, TextInputType.text),
                  const SizedBox(height: 10),

                  // Mobile
                  _buildField(_mobileController, 'Mobile Number', Icons.phone_android_rounded, TextInputType.phone,
                      maxLength: 10, formatters: [FilteringTextInputFormatter.digitsOnly], isPhone: true),
                  const SizedBox(height: 10),

                  // Flat + Block Row
                  Row(
                    children: [
                      Expanded(child: _buildField(_flatController, 'Flat No', Icons.home_rounded, TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly])),
                      const SizedBox(width: 10),
                      Expanded(child: _buildField(_blockController, 'Block', Icons.business_rounded, TextInputType.text)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Purpose
                  _buildField(_purposeController, 'Purpose of Visit', Icons.info_outline_rounded, TextInputType.text),

                  const SizedBox(height: 22),

                  // ── Check-In / Check-Out Buttons ───────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.checkInVisitor(
                                name: _nameController.text.trim(),
                                mobile: _mobileController.text.trim(),
                                flat: _flatController.text.trim(),
                                block: _blockController.text.trim(),
                                purpose: _purposeController.text.trim(),
                              );
                              _clearForm();
                            },
                            icon: const Icon(Icons.login_rounded, size: 20),
                            label: Text('Check-In', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 3,
                              shadowColor: const Color(0xFF00897B).withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Show checkout dialog
                              _showCheckoutDialog();
                            },
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: Text('Check-Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF5350),
                              side: const BorderSide(color: Color(0xFFEF5350), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ── Today's Entries ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Entries',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                      ),
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.allVisitors.length} visitors',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF00897B)),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Obx(() {
                    if (controller.allVisitors.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.group_off_rounded, size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text('No visitors today', style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.allVisitors.length,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                        itemBuilder: (context, index) {
                          final visitor = controller.allVisitors[index];
                          bool isIn = visitor['status'] == 'in';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isIn
                                    ? const Color(0xFF00897B).withOpacity(0.1)
                                    : const Color(0xFFEF5350).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  visitor['name'][0].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: isIn ? const Color(0xFF00897B) : const Color(0xFFEF5350),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              visitor['name'],
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Flat ${visitor['flat']}${visitor['block'].isNotEmpty ? " | Block ${visitor['block']}" : ""}',
                                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      'In: ${visitor['time']}',
                                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                    ),
                                    if (!isIn && visitor['checkout_time'] != null)
                                      Text(
                                        'Out: ${visitor['checkout_time']}',
                                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFEF5350), fontWeight: FontWeight.w600),
                                      ),
                                  ],
                                ),
                                if (visitor['purpose'] != null && visitor['purpose'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Purpose: ${visitor['purpose']}',
                                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF00897B), fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isIn
                                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                                    : const Color(0xFFEF5350).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isIn ? 'IN' : 'OUT',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isIn ? const Color(0xFF2E7D32) : const Color(0xFFEF5350),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 100), // Extra space at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _buildField(
    TextEditingController fieldController,
    String hint,
    IconData icon,
    TextInputType keyboardType, {
    int? maxLength,
    List<TextInputFormatter>? formatters,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: fieldController,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: formatters,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF00897B), size: 22),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 15),
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _mobileController.clear();
    _flatController.clear();
    _blockController.clear();
    _purposeController.clear();
  }

  void _showCheckoutDialog() {
    final visitors = controller.todayVisitors.where((v) => v['status'] == 'in').toList();

    if (visitors.isEmpty) {
      Get.snackbar('No Active Visitors', 'All visitors have already checked out',
          backgroundColor: Colors.orange.shade700, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(15));
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Visitor to Check-Out',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: visitors.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100, height: 1),
                  itemBuilder: (context, index) {
                    final v = visitors[index];
                    return ListTile(
                      onTap: () async {
                        Get.back();
                        await controller.checkOutVisitor(v['id'], v['name']);
                      },
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00897B).withOpacity(0.1),
                        child: Text(v['name'][0], style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF00897B))),
                      ),
                      title: Text(v['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Flat ${v['flat']} | ${v['time']}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
                      trailing: const Icon(Icons.logout_rounded, color: Color(0xFFEF5350), size: 20),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
