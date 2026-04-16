import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageSocietiesScreen extends StatelessWidget {
  const ManageSocietiesScreen({super.key});

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
          'Manage Societies',
          style: GoogleFonts.poppins(color: const Color(0xFF263238), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1565C0), size: 28),
            onPressed: () {}, // Add Society logic
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  hintText: 'Search societies...',
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          // Societies List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _societyCard('Gulshan-e-Iqbal', 'Block 13D, Karachi', '450 Flats', 'Active', const Color(0xFF2E7D32)),
                _societyCard('DHA Phase 6', 'Khayaban-e-Muslim, Karachi', '1200 Flats', 'Active', const Color(0xFF2E7D32)),
                _societyCard('Bahria Town', 'Phase 2, Islamabad', '850 Flats', 'Pending', const Color(0xFFEF6C00)),
                _societyCard('Clifton Garden', 'Block 5, Karachi', '220 Flats', 'Inactive', const Color(0xFFD32F2F)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _societyCard(String name, String address, String capacity, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment_rounded, size: 16, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  Text(capacity, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('View Details', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
