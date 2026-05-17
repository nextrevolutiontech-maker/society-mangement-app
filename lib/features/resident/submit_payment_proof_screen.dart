import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../payments/payment_controller.dart';

class SubmitPaymentProofScreen extends StatefulWidget {
  final String month;
  final double amount;

  const SubmitPaymentProofScreen({
    super.key,
    required this.month,
    required this.amount,
  });

  @override
  State<SubmitPaymentProofScreen> createState() => _SubmitPaymentProofScreenState();
}

class _SubmitPaymentProofScreenState extends State<SubmitPaymentProofScreen> {
  final PaymentController controller = Get.find<PaymentController>();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
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
          'Submit Payment Proof',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month & Amount Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  _buildSummaryItem('MONTH', widget.month, Icons.calendar_month_rounded),
                  Container(width: 1, height: 40, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(horizontal: 20)),
                  _buildSummaryItem('AMOUNT', '₹${widget.amount.toStringAsFixed(0)}', Icons.payments_rounded),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Payment Method', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.paymentModes.map((mode) {
                final isSelected = controller.selectedPaymentMode.value == mode;
                return GestureDetector(
                  onTap: () => controller.selectedPaymentMode.value = mode,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade200, width: 1.5),
                    ),
                    child: Text(
                      mode,
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF1565C0) : const Color(0xFF64748B)
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 32),

            Text('Upload Screenshot (Mandatory)', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            const SizedBox(height: 12),
            Obx(() => GestureDetector(
              onTap: () => _showImageSourceOptions(),
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.15), style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: controller.selectedImagePath.value.isEmpty 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                          child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF1565C0), size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text('Tap to select screenshot', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        Text('Proof of payment is required', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(controller.selectedImagePath.value), fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF1565C0)),
                                  const SizedBox(width: 4),
                                  Text('Change', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            )),
            const SizedBox(height: 32),

            Text('Note (Optional)', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Paid via ATM, Transaction ID: 123...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1565C0))),
              ),
            ),
            const SizedBox(height: 40),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: controller.isActionLoading.value 
                  ? null 
                  : () => controller.submitManualPayment(
                      month: widget.month, 
                      amount: widget.amount, 
                      mode: controller.selectedPaymentMode.value,
                      note: noteController.text.trim(),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                ),
                child: controller.isActionLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Submit Proof Now', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Source', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceItem(Icons.camera_alt_rounded, 'Camera', () { Get.back(); controller.pickProofImage(ImageSource.camera); }),
                _sourceItem(Icons.photo_library_rounded, 'Gallery', () { Get.back(); controller.pickProofImage(ImageSource.gallery); }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sourceItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
