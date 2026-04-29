import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme.dart';
import '../payments/payment_controller.dart';

class AdminPaymentSettingsScreen extends StatefulWidget {
  AdminPaymentSettingsScreen({super.key});

  @override
  State<AdminPaymentSettingsScreen> createState() => _AdminPaymentSettingsScreenState();
}

class _AdminPaymentSettingsScreenState extends State<AdminPaymentSettingsScreen> {
  final PaymentController controller = Get.put(PaymentController());

  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = controller.currentMaintenanceAmount.value.toStringAsFixed(0);
    _upiController.text = controller.currentUpiId.value;
    _nameController.text = controller.currentPaymentName.value;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _nameController.dispose();
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
          'Payment Settings',
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maintenance Configuration',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Set the monthly amount for all residents',
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Monthly Amount (₹)',
                      labelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF1565C0), size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // UPI ID
                  TextField(
                    controller: _upiController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Society UPI ID (Required)',
                      labelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.qr_code_rounded, color: Color(0xFF1565C0), size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Display Name
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Display Name (Required)',
                      labelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.account_balance_rounded, color: Color(0xFF1565C0), size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSettingsLoading.value
                          ? null
                          : () {
                              double amount = double.tryParse(_amountController.text) ?? 0;
                              if (amount <= 0) {
                                Get.snackbar('Invalid', 'Please enter a valid amount', backgroundColor: Colors.orange);
                                return;
                              }
                              String upiId = _upiController.text.trim();
                              if (upiId.isEmpty) {
                                Get.snackbar('Invalid', 'Please enter a valid UPI ID', backgroundColor: Colors.orange, colorText: Colors.white);
                                return;
                              }
                              if (_nameController.text.trim().isEmpty) {
                                Get.snackbar('Invalid', 'Please enter a valid Display Name', backgroundColor: Colors.orange);
                                return;
                              }
                              controller.updatePaymentSettings(amount, _upiController.text.trim(), _nameController.text.trim());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isSettingsLoading.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Save Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
