import 'package:flutter/material.dart';
import '../../core/theme.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('No new notices', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
