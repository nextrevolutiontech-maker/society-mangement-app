import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class VisitorManagementScreen extends StatelessWidget {
  const VisitorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00BFA5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ),
        title: Text(
          'Visitor Management',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1976D2),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications, color: Color(0xFF1976D2), size: 30),
                Positioned(
                  right: 0,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Visitor Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Visitor',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF263238)),
                  ),
                  const SizedBox(height: 15),
                  const Divider(height: 1),
                  _visitorInputItem(Icons.work_rounded, 'Rahul', const Color(0xFF1565C0), Colors.white),
                  const Divider(height: 1),
                  _visitorInputItem(Icons.call_rounded, '9876543210', Colors.transparent, const Color(0xFF1976D2)),
                  const Divider(height: 1),
                  _visitorInputItem(Icons.article_rounded, 'A-204', const Color(0xFF81D4FA), Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons (Bigger and Bolder)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 65, // Even bigger
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB342),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Check In',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 65, 
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C599D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Check Out',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Visitor Logs Section
            Text(
              'Visitor Logs',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF263238)),
            ),
            const SizedBox(height: 15),
            _logItem('Rahul Checked In', '10:00 AM', const Color(0xFF00BFA5)),
            const SizedBox(height: 12),
            _logItem('Rahul Checked Out', '12:00 PM', const Color(0xFFFFB74D)),
          ],
        ),
      ),
    );
  }

  Widget _visitorInputItem(IconData icon, String value, Color bgColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _logItem(String title, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}
