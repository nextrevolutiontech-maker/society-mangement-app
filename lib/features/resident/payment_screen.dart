import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../payments/payment_controller.dart';
import '../../core/models/payment_model.dart';
import 'submit_payment_proof_screen.dart';

class MaintenancePaymentScreen extends StatefulWidget {
  const MaintenancePaymentScreen({super.key});

  @override
  State<MaintenancePaymentScreen> createState() => _MaintenancePaymentScreenState();
}

class _MaintenancePaymentScreenState extends State<MaintenancePaymentScreen> {
  final PaymentController controller = Get.find<PaymentController>();

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
          'Society Maintenance',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => controller.onInit(),
          ),
        ],
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => controller.onInit(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentMonthCard(),
                const SizedBox(height: 30),
                Text(
                  'Payment History',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                _buildHistoryList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentMonthCard() {
    return Obx(() {
      final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
      final totalAmount = controller.currentMaintenanceAmount.value;
      final paidAmount = controller.getTotalPaidForMonth(currentMonth);
      final remaining = controller.getRemainingDues();
      final status = controller.getDetailedStatus(currentMonth);

      Color statusColor = const Color(0xFF1565C0);
      if (status == 'Paid') statusColor = const Color(0xFF16A34A);
      else if (status == 'Partially Paid') statusColor = const Color(0xFFEA580C);
      else if (status == 'Pending Verification') statusColor = const Color(0xFFD97706);
      else if (status == 'Processing') statusColor = const Color(0xFF7C3AED);
      else if (status == 'Rejected') statusColor = const Color(0xFFEF4444);

      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentMonth, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmountCol('TOTAL', totalAmount, const Color(0xFF64748B)),
                      _buildAmountCol('PAID', paidAmount, const Color(0xFF16A34A)),
                      _buildAmountCol('DUE', remaining, remaining > 0 ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                   if (totalAmount <= 0 && paidAmount <= 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.shade200)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Maintenance not yet configured by Admin for your Flat Type.', 
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    )
                  else if (status == 'Paid')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                            const SizedBox(width: 8),
                            Text('Month Fully Paid ✓', style: GoogleFonts.poppins(color: const Color(0xFF16A34A), fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    )
                  else if (status == 'Processing')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDDD6FE))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED))),
                              const SizedBox(width: 12),
                              Text('UPI Payment In Progress', style: GoogleFonts.poppins(color: const Color(0xFF7C3AED), fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('If you completed the payment, tap "I Have Paid" to upload your screenshot for Admin verification.', 
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.to(() => SubmitPaymentProofScreen(month: currentMonth, amount: remaining)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF7C3AED),
                                side: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('I Have Paid — Upload Proof', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (status == 'Pending Verification')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706))),
                          const SizedBox(width: 12),
                          Text('Payment Under Admin Review', style: GoogleFonts.poppins(color: const Color(0xFFD97706), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => controller.initiateUPIPayment(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(status == 'Partially Paid' ? 'Pay Remaining ₹${remaining.toStringAsFixed(0)}' : 'Pay via UPI', 
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => Get.to(() => SubmitPaymentProofScreen(month: currentMonth, amount: remaining)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1565C0),
                                side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('I Have Paid', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAmountCol(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (controller.myPayments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No payment history found', style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.myPayments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final payment = controller.myPayments[index];
        final isApproved = payment.status == 'Approved' || payment.status == 'Paid';
        final isRejected = payment.status == 'Rejected';
        final isProcessing = payment.status == 'Processing';
        final isPending = payment.status == 'Pending Verification' || payment.status == 'Pending';

        Color iconBg, iconColor;
        IconData iconData;
        Color statusColor;

        if (isApproved) {
          iconBg = const Color(0xFFE8F5E9); iconColor = const Color(0xFF2E7D32);
          iconData = Icons.check_circle_rounded; statusColor = const Color(0xFF2E7D32);
        } else if (isRejected) {
          iconBg = const Color(0xFFFFEBEE); iconColor = Colors.red;
          iconData = Icons.cancel_rounded; statusColor = Colors.red;
        } else if (isProcessing) {
          iconBg = const Color(0xFFEDE9FE); iconColor = const Color(0xFF7C3AED);
          iconData = Icons.autorenew_rounded; statusColor = const Color(0xFF7C3AED);
        } else if (isPending) {
          iconBg = const Color(0xFFFFFBEB); iconColor = const Color(0xFFD97706);
          iconData = Icons.pending_actions_rounded; statusColor = const Color(0xFFD97706);
        } else {
          iconBg = Colors.grey.shade100; iconColor = Colors.grey;
          iconData = Icons.receipt_long_rounded; statusColor = Colors.grey;
        }

        return GestureDetector(
          onTap: () => _showPaymentDetails(payment),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(iconData, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.month,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                      ),
                      Text(
                        '₹${payment.amount.toStringAsFixed(0)} • ${payment.paymentMode ?? "Online"}',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      payment.status,
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () { Get.back(); controller.pickProofImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () { Get.back(); controller.pickProofImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  void _showPaymentDetails(PaymentModel payment) {
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
                Text('Payment Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Month', payment.month),
            _buildDetailRow('Amount', '₹${payment.amount.toStringAsFixed(0)}'),
            _buildDetailRow('Mode', payment.paymentMode ?? 'Online'),
            _buildDetailRow('Status', payment.status),
            _buildDetailRow('Date', DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt)),
            if (payment.adminRemarks != null) _buildDetailRow('Remarks', payment.adminRemarks!, isValueBold: false),
            if (payment.proofUrl != null) ...[
              const SizedBox(height: 20),
              Text('Proof Screenshot', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _viewFullImage(payment.proofUrl!),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(payment.proofUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isValueBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B))),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: isValueBold ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF1E293B))
            ),
          ),
        ],
      ),
    );
  }

  void _viewFullImage(String url) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
      body: Center(child: InteractiveViewer(child: Image.network(url))),
    ));
  }
}
