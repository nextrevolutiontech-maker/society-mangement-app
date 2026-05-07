import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard_controller.dart';

class AdminVisitorLogsScreen extends StatelessWidget {
  AdminVisitorLogsScreen({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF263238), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Visitor Logs',
          style: GoogleFonts.poppins(color: const Color(0xFF263238), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.allVisitors.length} total',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF00BFA5)),
                ),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.allVisitors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off_rounded, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No visitor records yet',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visitors will appear here after Guard check-in',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFB0BEC5)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.allVisitors.length,
          itemBuilder: (context, index) {
            final visitor = controller.allVisitors[index];
            final isIn = visitor['status'] == 'in';
            
            // Date Grouping Logic
            final currentDate = (visitor['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
            bool showHeader = false;
            if (index == 0) {
              showHeader = true;
            } else {
              final prevVisitor = controller.allVisitors[index - 1];
              final prevDate = (prevVisitor['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
              if (DateFormat('yyyy-MM-dd').format(currentDate) != DateFormat('yyyy-MM-dd').format(prevDate)) {
                showHeader = true;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader) _buildDateHeader(currentDate),
                _buildVisitorCard(visitor, isIn),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);

    String label;
    if (logDate == today) {
      label = 'Today';
    } else if (logDate == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('EEEE, dd MMM').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
            ),
          ),
          const Expanded(child: Divider(indent: 10, color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(Map<String, dynamic> visitor, bool isIn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIn ? const Color(0xFF00897B).withOpacity(0.2) : const Color(0xFFEF5350).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isIn ? const Color(0xFF00897B).withOpacity(0.1) : const Color(0xFFEF5350).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                (visitor['name'] ?? '?')[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isIn ? const Color(0xFF00897B) : const Color(0xFFEF5350),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor['name'] ?? 'Unknown',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
                Text(
                  'Flat ${visitor['flat'] ?? '-'}${(visitor['block'] ?? '').isNotEmpty ? " | Block ${visitor['block']}" : ""}',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                Row(
                  children: [
                    Text(
                      'In: ${visitor['time'] ?? '-'}',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF00897B), fontWeight: FontWeight.w600),
                    ),
                    if (!isIn && visitor['checkout_time'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Out: ${visitor['checkout_time']}',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFEF5350), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
                if ((visitor['purpose'] ?? '').isNotEmpty)
                  Text(
                    'Purpose: ${visitor['purpose']}',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isIn ? const Color(0xFF2E7D32).withOpacity(0.1) : const Color(0xFFEF5350).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isIn ? 'IN' : 'OUT',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isIn ? const Color(0xFF2E7D32) : const Color(0xFFEF5350),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
