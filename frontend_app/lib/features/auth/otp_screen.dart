import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Back Button
          Container(
            height: 180,
            width: double.infinity,
            color: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Enter OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance back button
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Title & Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Text(
                  'Enter OTP Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We have sent a code to +91 1234567890',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Inputs (5 Boxes)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          '●', // Using a bullet as placeholder
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Resend Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '00:58 - ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
