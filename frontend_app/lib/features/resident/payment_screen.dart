import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MaintenancePaymentScreen extends StatelessWidget {
  const MaintenancePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Maintenance Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Due Amount: ₹1,200',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
            ),
            const SizedBox(height: 8),
            const Text(
              'Late Fee: ₹0',
              style: TextStyle(fontSize: 15, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Pay via UPI Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C599D), // Dark Navy Blue from image
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Pay via UPI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Upload Screenshot Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_upload_outlined, color: Color(0xFF2C599D)),
                label: const Text(
                  'Upload Screenshot',
                  style: TextStyle(color: Color(0xFF2C599D), fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F4F9), // Light background from image
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            const Spacer(),
            
            _infoRow('Upload Proof', trailing: const Icon(Icons.chevron_right, size: 20)),
            const Divider(),
            _infoRow('Status:', trailing: const Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, {required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textBlack, fontWeight: FontWeight.w500)),
          trailing,
        ],
      ),
    );
  }
}
