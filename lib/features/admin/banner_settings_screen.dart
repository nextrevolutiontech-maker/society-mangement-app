import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerSettingsScreen extends StatefulWidget {
  const BannerSettingsScreen({super.key});

  @override
  State<BannerSettingsScreen> createState() => _BannerSettingsScreenState();
}

class _BannerSettingsScreenState extends State<BannerSettingsScreen> {
  bool _isBannerActive = true;

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
          'Banner Settings',
          style: GoogleFonts.poppins(color: const Color(0xFF263238), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Active Banner',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 15),
            
            // Banner Preview
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/banner.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (!_isBannerActive)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        alignment: Alignment.center,
                        child: Text(
                          'INACTIVE',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Banner Visibility', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    subtitle: Text('Show or hide the banner on user dashboards', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                    value: _isBannerActive,
                    activeColor: const Color(0xFF1565C0),
                    onChanged: (val) => setState(() => _isBannerActive = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Update Banner Image', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    leading: const Icon(Icons.image_outlined, color: Color(0xFF1565C0)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {}, // Pick image logic
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text('Save Changes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
