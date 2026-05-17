import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../payments/payment_controller.dart';
import '../dashboard_controller.dart';

class ResidentPaymentDashboard extends StatelessWidget {
  ResidentPaymentDashboard({super.key});

  final PaymentController controller = Get.put(PaymentController());
  final DashboardController dashboardController = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

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
          'My Payments',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Month Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Obx(() {
                    double amount = controller.currentMaintenanceAmount.value;
                    double remaining = controller.getRemainingDues();
                    final flatType = dashboardController.currentUserFlatType.value.isEmpty
                        ? 'N/A'
                        : dashboardController.currentUserFlatType.value;
                    
                    bool isSetupMissing = amount == 0 || controller.currentUpiId.value.isEmpty;
                    
                    if (isSetupMissing) {
                      return Column(
                        children: [
                          Text(
                            'Maintenance Setup',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            currentMonth,
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
                          const SizedBox(height: 15),
                          Text(
                            'Admin Setup Pending',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            amount == 0 
                                ? 'Maintenance amount not set for $flatType'
                                : 'Society UPI ID not configured by Admin',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      );
                    }

                    bool isPartiallyPaid = remaining > 0 && remaining < amount;

                    return Column(
                      children: [
                        Text(
                          isPartiallyPaid ? 'Remaining Dues' : 'Maintenance Dues',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          currentMonth,
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Flat Type: $flatType | Monthly: ₹${amount.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '₹${remaining.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),
                        
                        if (remaining <= 0)
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('Paid for this month', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _showUPIPaymentDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1565C0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(isPartiallyPaid ? 'Pay Remaining ₹${remaining.toStringAsFixed(0)}' : 'Pay Now', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    );
                  }),

                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            Text(
              'Payment History',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 15),

            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.myPayments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(Icons.history_rounded, size: 50, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('No payment history', style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.myPayments.length,
                itemBuilder: (context, index) {
                  final payment = controller.myPayments[index];
                  bool isApproved = payment.status == 'Approved';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isApproved ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                            color: isApproved ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.month,
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy').format(payment.createdAt),
                                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${payment.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1565C0)),
                            ),
                            Text(
                              payment.status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isApproved ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showUPIPaymentDialog(BuildContext context) async {
    // New logic handles its own dialogs
    await controller.initiateUPIPayment();
  }

  Widget _buildSummaryCard() {
    return Container();
  }
}
