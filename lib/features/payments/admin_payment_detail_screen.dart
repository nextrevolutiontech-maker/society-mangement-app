import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/models/payment_model.dart';
import '../payments/payment_controller.dart';

class AdminPaymentDetailScreen extends StatefulWidget {
  final PaymentModel payment;

  AdminPaymentDetailScreen({super.key, required this.payment});

  @override
  State<AdminPaymentDetailScreen> createState() => _AdminPaymentDetailScreenState();
}

class _AdminPaymentDetailScreenState extends State<AdminPaymentDetailScreen> {
  final PaymentController controller = Get.find<PaymentController>();
  final remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    remarksController.text = widget.payment.adminRemarks ?? '';
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.payment.status;
    // All statuses that admin can act upon
    bool isPending = status == 'Pending' || status == 'Pending Verification' || status == 'Processing';
    bool isRejected = status == 'Rejected';
    bool isApproved = status == 'Approved' || status == 'Paid';
    bool canEdit = isPending || isRejected; // Approved is final; everything else is editable

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
                borderRadius: BorderRadius.circular(24),
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
                      color: isApproved
                          ? const Color(0xFFF0FDF4)
                          : isRejected
                              ? Colors.red.shade50
                              : isPending
                                  ? const Color(0xFFFFF7ED)
                                  : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.check_circle_rounded
                          : isRejected
                              ? Icons.cancel_rounded
                              : status == 'Processing'
                                  ? Icons.autorenew_rounded
                                  : Icons.hourglass_top_rounded,
                      color: isApproved
                          ? const Color(0xFF16A34A)
                          : isRejected
                              ? Colors.redAccent
                              : status == 'Processing'
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFEA580C),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '₹${widget.payment.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Text(
                    'Maintenance - ${widget.payment.month}',
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  _detailRow('Resident Name', widget.payment.userName),
                  _detailRow('Flat Details', '${widget.payment.flatNumber} (${widget.payment.flatType})'),
                  _detailRow('Billing Period', '${widget.payment.month} ${widget.payment.year}'),
                  _detailRow('Payment Mode', widget.payment.paymentMode ?? 'Online'),
                  _detailRow('Date Submitted', DateFormat('MMM dd, yyyy • hh:mm a').format(widget.payment.createdAt)),
                  _detailRow('Status', widget.payment.status, isStatus: true),
                  if (widget.payment.residentNote != null && widget.payment.residentNote!.isNotEmpty)
                    _detailRow('Resident Note', widget.payment.residentNote!),
                  if (widget.payment.adminRemarks != null && widget.payment.adminRemarks!.isNotEmpty)
                    _detailRow('Admin Remarks', widget.payment.adminRemarks!),
                  if (widget.payment.approvedAt != null)
                    _detailRow('Approved On', DateFormat('MMM dd, yyyy').format(widget.payment.approvedAt!)),
                  if (widget.payment.approvedBy != null)
                    _detailRow('Approved By', widget.payment.approvedBy!),
                  
                  if (widget.payment.proofUrl != null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF1565C0), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Payment Proof Screenshot', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _viewFullImage(widget.payment.proofUrl!),
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(widget.payment.proofUrl!, fit: BoxFit.cover, 
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Tap to View Full Screen', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            if (canEdit)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRejected ? 'Corrective Action' : 'Admin Feedback (Optional)', 
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: isRejected ? 'Update remarks before approving...' : 'e.g. Screenshot unclear, or Payment verified...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.isActionLoading.value
                                ? null
                                : () async {
                                    final ok = await controller.updatePaymentStatus(
                                      widget.payment.id!, 
                                      'Approved', 
                                      remarks: remarksController.text.trim()
                                    );
                                    if (ok) Get.back();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: controller.isActionLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(isRejected ? 'Approve Now (Corrected)' : 'Approve Payment', 
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        if (isPending) ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: controller.isActionLoading.value
                                  ? null
                                  : () async {
                                      final ok = await controller.updatePaymentStatus(
                                        widget.payment.id!, 
                                        'Rejected', 
                                        remarks: remarksController.text.trim()
                                      );
                                      if (ok) Get.back();
                                    },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFEF4444)),
                                foregroundColor: const Color(0xFFEF4444),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text('Reject Payment', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isStatus = false}) {
    Color valueColor = const Color(0xFF1E293B);
    if (isStatus) {
      switch (value) {
        case 'Approved': case 'Paid': valueColor = const Color(0xFF16A34A); break;
        case 'Rejected': valueColor = const Color(0xFFEF4444); break;
        case 'Processing': valueColor = const Color(0xFF7C3AED); break;
        case 'Pending Verification': case 'Pending': valueColor = const Color(0xFFD97706); break;
        case 'Partially Paid': valueColor = const Color(0xFFEA580C); break;
        default: valueColor = const Color(0xFF64748B);
      }
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
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor),
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
