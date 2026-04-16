import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            color: const Color(0xFF263238),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none_outlined, color: Color(0xFF1565C0), size: 30),
                Positioned(
                  right: 2,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Stats Row
            Row(
              children: [
                _statCard('Total Flats', '120', 'assets/images/total-flats.png', const Color(0xFF1565C0), const Color(0xFFE3F2FD), isAsset: true),
                const SizedBox(width: 12),
                _statCard('Payments ', 'Pending', 'assets/images/pending-payment.png', const Color(0xFFFFA000), const Color(0xFFFFF3E0), isAsset: true),
                const SizedBox(width: 12),
                _statCard('Complaints', '5', 'assets/images/complaints.png', const Color(0xFFD32F2F), const Color(0xFFFFEBEE), isAsset: true),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // 2. Action Grid
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _actionGridItem('Residents', 'assets/images/resident.png', const Color(0xFFD1E9FF), const Color(0xFF1565C0)),
                      const SizedBox(width: 15),
                      _actionGridItem('Open', 'assets/images/open.png', const Color(0xFFFFECB3), const Color(0xFFEF6C00)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _actionGridItem('Manage Users', 'assets/images/manage-user.png', const Color(0xFFC8E6C9), const Color(0xFF2E7D32)),
                      const SizedBox(width: 15),
                      _actionGridItem('Manage Payments', 'assets/images/manage-payment.png', const Color(0xFFFFCDD2), const Color(0xFFC62828)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _actionGridItem('View Complaints', 'assets/images/f358446c-8d5a-448a-be5b-340b06b0b82b.png', const Color(0xFFFFF9C4), const Color(0xFFFBC02D)),
                      const SizedBox(width: 15),
                      _actionGridItem('Sent Notices', 'assets/images/seed.png', const Color(0xFFB3E5FC), const Color(0xFF0277BD)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // 3. Bottom Illustration
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/banner.png', // Using the existing building banner
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, dynamic icon, Color iconColor, Color bgColor, {bool isAsset = false}) {
    return Expanded(
      child: Container(
        height: 185, // Increased height to prevent overflow
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, // Fixed large size for circle
              height: 90,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: isAsset 
                ? Image.asset(icon as String, height: 120, width: 120, fit: BoxFit.contain)
                : Icon(icon as IconData, color: iconColor, size: 50),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF263238)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: value.length > 5 ? 14 : 20, 
                fontWeight: FontWeight.w800, 
                color: const Color(0xFF455A64),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionGridItem(String label, dynamic icon, Color bgColor, Color iconColor) {
    bool isAsset = icon is String;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.02), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 55, // Fixed size for action icon box
              height: 55,
              decoration: BoxDecoration(
                color: isAsset ? Colors.transparent : iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: isAsset 
                ? Image.asset(icon, height: 120, width: 120, fit: BoxFit.contain)
                : Icon(icon as IconData, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15, 
                  fontWeight: FontWeight.w700, 
                  color: const Color(0xFF263238),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
