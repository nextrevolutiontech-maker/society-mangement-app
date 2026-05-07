import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme.dart';
import '../dashboard_controller.dart';
import '../payments/payment_controller.dart';

class AdminPaymentSettingsScreen extends StatefulWidget {
  AdminPaymentSettingsScreen({super.key});

  @override
  State<AdminPaymentSettingsScreen> createState() => _AdminPaymentSettingsScreenState();
}

class _AdminPaymentSettingsScreenState extends State<AdminPaymentSettingsScreen> {
  final PaymentController controller = Get.put(PaymentController());

  final _upiController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _upiController.text = controller.currentUpiId.value;
    _nameController.text = controller.currentPaymentName.value;
  }

  @override
  void dispose() {
    _upiController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = Get.find<DashboardController>().currentUserRole.value;
    if (role == 'super_admin') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('Payment Settings',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 70, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Access Restricted',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text('Only Society Admins can manage\npayment settings.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
            ],
          ),
        ),
      );
    }

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
                    'UPI & display name',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'These details will be shown to residents during payment.',
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 18),
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
                  const SizedBox(height: 22),
                  Obx(() => Column(
                    children: [
                      if (controller.currentUpiId.value.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Current: ${controller.currentUpiId.value} (${controller.currentPaymentName.value})',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () => controller.savePaymentIdentifiers(upiId: '', name: ''),
                                tooltip: 'Clear UPI Details',
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isSettingsLoading.value
                              ? null
                              : () {
                                  final upiId = _upiController.text.trim();
                                  final name = _nameController.text.trim();
                                  if (upiId.isEmpty) {
                                    Get.snackbar('Invalid', 'UPI ID is required',
                                        backgroundColor: Colors.orange, colorText: Colors.white);
                                    return;
                                  }
                                  if (name.isEmpty) {
                                    Get.snackbar('Invalid', 'Display name is required',
                                        backgroundColor: Colors.orange, colorText: Colors.white);
                                    return;
                                  }
                                  controller.savePaymentIdentifiers(upiId: upiId, name: name);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isSettingsLoading.value
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Save UPI details',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  )),

                  const SizedBox(height: 28),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 20),

                  Text(
                    'Flat type slabs',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Set different monthly amounts for each flat/BHK type. Residents will see the amount matching their profile flat type (e.g. 1BHK or 3BHK).',
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddFlatTypeDialog(),
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF1565C0)),
                      label: Text('Add Flat Type & Amount',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1565C0))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  Text(
                    'Saved slab cards',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final entries = controller.currentFlatTypeAmounts.entries.where((e) => e.value > 0).toList()
                      ..sort((a, b) => a.key.compareTo(b.key));

                    if (entries.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'No slabs saved yet. Use "+ Add Flat Type & Amount" to create one.',
                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                      );
                    }

                    return Column(
                      children: entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${entry.value.toStringAsFixed(0)} / month',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: const Color(0xFF1565C0), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showEditAmountDialog(entry.key, entry.value),
                                icon: const Icon(Icons.edit_rounded, size: 16),
                                label: const Text('Edit'),
                              ),
                              TextButton.icon(
                                onPressed: () => _confirmDelete(entry.key),
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFlatTypeDialog() {
    String selectedType = '1BHK';
    final List<String> standardTypes = ['1BHK', '2BHK', '3BHK', '4BHK', 'Penthouse', 'Shop', 'Others', 'Custom (Add New)'];
    final customTypeCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Flat Type & Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Select Flat / BHK Type', 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                      items: standardTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    ),
                  ),
                ),
                if (selectedType == 'Custom (Add New)') ...[
                  const SizedBox(height: 15),
                  TextField(
                    controller: customTypeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Custom Flat Type Name',
                      hintText: 'e.g. DUPLEX, VILLA...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monthly amount (₹)',
                    hintText: 'e.g. 2500',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                String finalType = selectedType;
                if (selectedType == 'Custom (Add New)') {
                  finalType = customTypeCtrl.text.trim().toUpperCase();
                  if (finalType.isEmpty) {
                    Get.snackbar('Incomplete', 'Please enter custom type name',
                        backgroundColor: Colors.orange, colorText: Colors.white);
                    return;
                  }
                }

                final amtTxt = amountCtrl.text.trim();
                if (amtTxt.isEmpty) {
                  Get.snackbar('Incomplete', 'Amount is required',
                      backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                final amt = double.tryParse(amtTxt);
                if (amt == null || amt <= 0) {
                  Get.snackbar('Invalid', 'Please enter a valid amount',
                      backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                Get.back();
                await controller.upsertFlatTypeAmount(finalType, amt);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAmountDialog(String flatType, double currentAmount) {
    final amountController = TextEditingController(text: currentAmount.toStringAsFixed(0));
    Get.dialog(
      AlertDialog(
        title: Text('Edit amount — $flatType', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly Amount (₹)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newAmount = double.tryParse(amountController.text.trim()) ?? 0;
              if (newAmount <= 0) {
                Get.snackbar('Invalid', 'Please enter a valid amount', backgroundColor: Colors.orange);
                return;
              }
              Get.back();
              await controller.upsertFlatTypeAmount(flatType, newAmount);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String flatType) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete $flatType?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'The saved amount for this flat type will be removed.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.deleteFlatTypeAmount(flatType);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
