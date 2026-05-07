import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/models/payment_model.dart';
import '../payments/payment_controller.dart';

class AdminPaymentDetailScreen extends StatelessWidget {
  final PaymentModel payment;

  AdminPaymentDetailScreen({super.key, required this.payment});

  final PaymentController controller = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    bool isPending = payment.status == 'Pending';

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
          'Payment Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPending ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                      color: isPending ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '₹${payment.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Text(
                    'Maintenance - ${payment.month}',
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  _detailRow('Resident Name', payment.userName),
                  _detailRow('Flat Number', payment.flatNumber),
                  _detailRow('Date Submitted', DateFormat('MMM dd, yyyy').format(payment.createdAt)),
                  _detailRow('Status', payment.status, isStatus: true),
                  if (payment.approvedAt != null)
                    _detailRow('Approved On', DateFormat('MMM dd, yyyy').format(payment.approvedAt!)),
                  if (payment.approvedBy != null)
                    _detailRow('Approved By', payment.approvedBy!),
                ],
              ),
            ),
            const SizedBox(height: 30),

            if (isPending)
              Obx(() => Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.isActionLoading.value
                          ? null
                          : () async {
                              final ok =
                                  await controller.updatePaymentStatus(payment.id!, 'Approved');
                              if (ok) Get.offNamed('/admin-payments');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: controller.isActionLoading.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Approve Payment', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: controller.isActionLoading.value
                          ? null
                          : () async {
                              final ok =
                                  await controller.updatePaymentStatus(payment.id!, 'Rejected');
                              if (ok) Get.offNamed('/admin-payments');
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Reject', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                    ),
                  ),
                ],
              )),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isStatus = false}) {
    Color valueColor = const Color(0xFF1E293B);
    if (isStatus) {
      valueColor = value == 'Approved' ? const Color(0xFF16A34A) : (value == 'Rejected' ? const Color(0xFFEF4444) : const Color(0xFFEA580C));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}
