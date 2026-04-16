import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminPanel extends StatelessWidget {
  const SuperAdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Super Admin Panel',
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
            // 1. Top Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildBannerVector(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _topStatCard('5068', Icons.assignment_turned_in_rounded, Colors.white, const Color(0xFF26A69A)),
                          const SizedBox(height: 10),
                          _topInfoCard('Monthly Revenue', '₹2,50,000'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 25),
            
            // 2. Menu List
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _menuItem(context, 'Manage Societies', 'assets/images/total-flats.png', const Color(0xFFE3F2FD), const Color(0xFF1565C0), '/manage-societies'),
                  const Divider(height: 1, indent: 80),
                  _menuItem(context, 'Manage Users', 'assets/images/manage-user.png', const Color(0xFFE3F2FD), const Color(0xFF1565C0), '/manage-users'),
                  const Divider(height: 1, indent: 80),
                  _menuItem(context, 'Payment Reports', 'assets/images/manage-payment.png', const Color(0xFFE8F5E9), const Color(0xFF2E7D32), '/payment-reports'),
                  const Divider(height: 1, indent: 80),
                  _menuItem(context, 'Banner Settings', 'assets/images/open.png', const Color(0xFFFFF3E0), const Color(0xFFEF6C00), '/banner-settings'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _topStatCard(String value, dynamic icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon is String 
            ? Image.asset(icon, height: 26, width: 26, color: Colors.white)
            : Icon(icon as IconData, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _topInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String label, dynamic icon, Color bgColor, Color iconColor, String routeName) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      leading: Container(
        width: 75, // Much larger size
        height: 75,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: icon is String 
          ? Image.asset(icon, height: 70, width: 70, fit: BoxFit.contain)
          : Icon(icon as IconData, color: iconColor, size: 45),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF334155)),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 30),
      onTap: () => Navigator.pushNamed(context, routeName),
    );
  }

  Widget _buildBannerVector() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Sky Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Clouds
            Positioned(top: 15, left: 30, child: _buildCloud(40, 20)),
            Positioned(top: 30, right: 40, child: _buildCloud(50, 25)),
            
            // Background Buildings (Lighter)
            Positioned(bottom: 0, left: 10, child: _buildBuilding(35, 70, const Color(0xFF90CAF9))),
            Positioned(bottom: 0, right: 20, child: _buildBuilding(40, 50, const Color(0xFFA5D6A7))),
            
            // Main Buildings (Detailed)
            Positioned(
              bottom: 0,
              left: 50,
              child: _buildBuilding(45, 110, const Color(0xFF2196F3), hasWindows: true),
            ),
            Positioned(
              bottom: 0,
              left: 95,
              child: _buildBuilding(30, 85, const Color(0xFF1976D2), hasWindows: true),
            ),
            
            // Foreground Trees
            Positioned(bottom: 5, left: 40, child: _buildTree(25)),
            Positioned(bottom: 5, left: 130, child: _buildTree(30)),
          ],
        ),
      ),
    );
  }

  Widget _buildBuilding(double width, double height, Color color, {bool hasWindows = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)],
      ),
      child: hasWindows ? Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(2, (index) => Container(width: 6, height: 6, color: Colors.white24)),
        )),
      ) : null,
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildTree(double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: size, height: size, decoration: const BoxDecoration(color: Color(0xFF66BB6A), shape: BoxShape.circle)),
        Container(width: 4, height: 8, color: const Color(0xFF5D4037)),
      ],
    );
  }
}
