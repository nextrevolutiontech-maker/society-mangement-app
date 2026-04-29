import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentReportsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var totalCollected = 0.0.obs;
  var thisMonthCollected = 0.0.obs;
  var societyReports = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      isLoading.value = true;
      String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

      // Fetch all societies
      final societySnapshot = await _firestore.collection('societies').get();
      List<Map<String, dynamic>> reports = [];
      double overallTotal = 0;
      double overallThisMonth = 0;

      for (var doc in societySnapshot.docs) {
        String societyId = doc.id;
        String societyName = doc.data()['name'] ?? 'Unknown Society';

        // Fetch payments for this society
        final paymentSnapshot = await _firestore
            .collection('payments')
            .where('societyId', isEqualTo: societyId)
            .where('status', isEqualTo: 'Approved')
            .get();

        double societyTotal = 0;
        int pendingCount = 0;

        for (var payDoc in paymentSnapshot.docs) {
          double amount = (payDoc.data()['amount'] ?? 0.0).toDouble();
          String month = payDoc.data()['month'] ?? '';
          
          societyTotal += amount;
          overallTotal += amount;
          
          if (month == currentMonth) {
            overallThisMonth += amount;
          }
        }

        // Fetch pending count
        final pendingSnapshot = await _firestore
            .collection('payments')
            .where('societyId', isEqualTo: societyId)
            .where('status', isEqualTo: 'Pending')
            .get();
        pendingCount = pendingSnapshot.docs.length;

        reports.add({
          'societyName': societyName,
          'totalCollected': societyTotal,
          'pendingCount': pendingCount,
        });
      }

      totalCollected.value = overallTotal;
      thisMonthCollected.value = overallThisMonth;
      societyReports.value = reports;
    } catch (e) {
      debugPrint('Error fetching payment reports: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class PaymentReportsScreen extends StatelessWidget {
  PaymentReportsScreen({super.key});

  final PaymentReportsController controller = Get.put(PaymentReportsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF263238), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Payment Reports',
          style: GoogleFonts.poppins(color: const Color(0xFF263238), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Summary Row
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _summaryBox('Total Collected', '₹${controller.totalCollected.value.toStringAsFixed(0)}', const Color(0xFF1565C0)),
                  const SizedBox(width: 15),
                  _summaryBox('This Month', '₹${controller.thisMonthCollected.value.toStringAsFixed(0)}', const Color(0xFF2E7D32)),
                ],
              ),
            ),
            
            // Reports List
            Expanded(
              child: controller.societyReports.isEmpty
                  ? Center(
                      child: Text('No reports available', style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.societyReports.length,
                      itemBuilder: (context, index) {
                        final report = controller.societyReports[index];
                        return _reportItem(
                          report['societyName'],
                          '₹${report['totalCollected'].toStringAsFixed(0)}',
                          '${report['pendingCount']} Pending',
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _summaryBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _reportItem(String society, String amount, String pendingText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(society, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(pendingText, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFEF6C00), fontWeight: FontWeight.w500)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1565C0))),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, size: 12, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Text('Collected', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
