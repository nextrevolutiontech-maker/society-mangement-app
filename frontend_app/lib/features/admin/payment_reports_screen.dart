import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentReportsScreen extends StatelessWidget {
  const PaymentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF263238), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Reports',
          style: GoogleFonts.poppins(color: const Color(0xFF263238), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _summaryBox('Total Collected', '₹8,50,000', const Color(0xFF1565C0)),
                const SizedBox(width: 15),
                _summaryBox('This Month', '₹2,50,000', const Color(0xFF2E7D32)),
              ],
            ),
          ),
          
          // Reports List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _reportItem('Gulshan-e-Iqbal', '₹45,000', '12 April 2026', 'Verified'),
                _reportItem('DHA Phase 6', '₹1,20,000', '10 April 2026', 'Verified'),
                _reportItem('Bahria Town', '₹85,000', '08 April 2026', 'Pending'),
                _reportItem('Clifton Garden', '₹22,000', '05 April 2026', 'Verified'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
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

  Widget _reportItem(String society, String amount, String date, String status) {
    bool isVerified = status == 'Verified';
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
              Text(date, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1565C0))),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(isVerified ? Icons.check_circle_rounded : Icons.pending_rounded, size: 12, color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00)),
                  const SizedBox(width: 4),
                  Text(status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
