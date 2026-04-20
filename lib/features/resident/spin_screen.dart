import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SpinScreen extends StatelessWidget {
  const SpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin & Win'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Play Spin & Win here!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
