import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../payments/payment_controller.dart';
import 'admin_payment_detail_screen.dart';
import '../../core/models/payment_model.dart';

class AdminPaymentListScreen extends StatelessWidget {
  AdminPaymentListScreen({super.key});

  final PaymentController controller = Get.put(PaymentController());

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
          'Payment Records',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => Get.toNamed('/payment-settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFFF8FAFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => controller.adminFilterFlat.value = val,
                      decoration: InputDecoration(
                        hintText: 'Search Flat Number...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1565C0)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Obx(() {
                      bool hasFilter = controller.adminFilterMonth.value != 'All' || controller.adminFilterStatus.value != 'All';
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.filter_list_rounded, color: hasFilter ? const Color(0xFF1565C0) : Colors.grey.shade600),
                          if (hasFilter)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ── Results List ───────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)));
              }

              if (controller.filteredPayments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      Text(
                        'No matching records',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                      ),
                      TextButton(
                        onPressed: () => controller.resetAdminFilters(),
                        child: Text('Clear All Filters', style: GoogleFonts.poppins(color: const Color(0xFF1565C0), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.filteredPayments.length,
                itemBuilder: (context, index) {
                  final payment = controller.filteredPayments[index];
                  return _buildPaymentCard(payment);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    final status = payment.status;
    Color statusColor = Colors.orange;
    if (status == 'Approved') statusColor = const Color(0xFF16A34A);
    if (status == 'Rejected') statusColor = const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () => Get.to(() => AdminPaymentDetailScreen(payment: payment)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: statusColor.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                status == 'Approved' ? Icons.verified_rounded : (status == 'Rejected' ? Icons.cancel_rounded : Icons.pending_rounded),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.userName,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${payment.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Flat ${payment.flatNumber} • ${payment.month}',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      _buildStatusBadge(payment.status, statusColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final List<String> statuses = ['All', 'Pending', 'Approved', 'Rejected'];
    // Generate months for filter
    final List<String> months = ['All'];
    final now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      months.add(DateFormat('MMMM yyyy').format(DateTime(now.year, now.month - i)));
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Records', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => controller.resetAdminFilters(), child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 24),
            Text('Payment Status', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 10,
              children: statuses.map((s) => ChoiceChip(
                label: Text(s),
                selected: controller.adminFilterStatus.value == s,
                onSelected: (val) => controller.adminFilterStatus.value = s,
                selectedColor: const Color(0xFF1565C0).withOpacity(0.1),
                labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: controller.adminFilterStatus.value == s ? const Color(0xFF1565C0) : const Color(0xFF64748B)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                showCheckmark: false,
              )).toList(),
            )),
            const SizedBox(height: 24),
            Text('Select Month', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: Obx(() => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: months.length,
                separatorBuilder: (c, i) => const SizedBox(width: 10),
                itemBuilder: (c, i) {
                  final m = months[i];
                  final isSel = controller.adminFilterMonth.value == m;
                  return GestureDetector(
                    onTap: () => controller.adminFilterMonth.value = m,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1565C0) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(m, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? Colors.white : const Color(0xFF64748B))),
                    ),
                  );
                },
              )),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Apply Filters', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
