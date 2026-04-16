import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

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
          'Manage Users',
          style: GoogleFonts.poppins(color: const Color(0xFF263238), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF1565C0), size: 28),
            onPressed: () {}, // Add User logic
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                _filterChip('All', true),
                const SizedBox(width: 10),
                _filterChip('Admins', false),
                const SizedBox(width: 10),
                _filterChip('Staff', false),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _userTile('Hamza Sheikh', 'Super Admin', 'Active', 'assets/images/google_logo.png'),
                _userTile('Ali Khan', 'Society Admin', 'Active', ''),
                _userTile('Sara Ahmed', 'Staff', 'Inactive', ''),
                _userTile('Zainab Bibi', 'Accountant', 'Active', ''),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1565C0) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13, 
          fontWeight: FontWeight.w600, 
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _userTile(String name, String role, String status, String photoUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFF1F5F9),
            child: Text(name[0], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                Text(role, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 12, 
                  fontWeight: FontWeight.w700, 
                  color: status == 'Active' ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}
