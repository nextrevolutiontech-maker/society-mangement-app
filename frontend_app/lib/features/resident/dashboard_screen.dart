import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ResidentDashboard extends StatelessWidget {
  const ResidentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // 1. Blue Header Background (Slimmer like reference)
          Container(
            height: 140, 
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Resident Dashboard',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Stack(
                      children: [
                        Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFFF5252)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. White Body (Started higher for slim header)
          Container(
            margin: const EdgeInsets.only(top: 100),
            padding: const EdgeInsets.only(top: 25),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Good Morning, Rajat',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('👋', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const Text('Flat: A-204', style: TextStyle(color: AppTheme.textGrey, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 25),

                  // Maintenance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3476B2), Color(0xFF4DB6AC)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Maintenance Due', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹1,200',
                              style: GoogleFonts.poppins(
                                color: Colors.white, 
                                fontSize: 36, 
                                fontWeight: FontWeight.w800
                              )
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/payment'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Text(
                                  'Pay Now',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF1976D2), 
                                    fontWeight: FontWeight.w800, 
                                    fontSize: 16
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text('Latest Notices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textBlack)),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        _noticeItem(Icons.check, Colors.blue, 'Water Supply Cut Today'),
                        const Divider(height: 1, indent: 70),
                        _noticeItem(Icons.priority_high, Colors.red.shade400, 'Event: Diwali Celebration'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textBlack)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _actionBtn(Icons.person_pin, 'Add Visitor', const Color(0xFFE0F2F1), Colors.teal.shade700, onTap: () => Navigator.pushNamed(context, '/visitor-management'))),
                      const SizedBox(width: 20),
                      Expanded(child: _actionBtn(Icons.campaign_outlined, 'Raise Complaint', const Color(0xFFFFF3E0), const Color(0xFFF57C00), onTap: () => Navigator.pushNamed(context, '/complaint'))),
                    ],
                  ),

                  const SizedBox(height: 25),
                  // Bottom Offer Banner (Generated Premium Image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/banner.png',
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeItem(IconData icon, Color color, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18), // Filled circle with white icon
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color bg, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 20), // Boxed Icon logic
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: GoogleFonts.poppins(color: iconColor, fontWeight: FontWeight.w700, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}
