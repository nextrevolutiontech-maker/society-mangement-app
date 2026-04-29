import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme.dart';
import '../dashboard_controller.dart';

class VisitorManagementScreen extends StatelessWidget {
  VisitorManagementScreen({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00BFA5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ),
        title: Text(
          'Visitor Management',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1976D2),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications, color: Color(0xFF1976D2), size: 30),
                Positioned(
                  right: 0,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Visitor Logs Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Visitor Logs',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF263238)),
                ),
                Obx(() => Text(
                  '${controller.visitorHistory.length} Total',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1976D2)),
                )),
              ],
            ),
            const SizedBox(height: 15),
            Obx(() {
              if (controller.visitorHistory.isEmpty && controller.todayVisitors.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text('No visitor records yet', style: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                );
              }
              
              var allLogs = [...controller.todayVisitors, ...controller.visitorHistory];
              
              // If Resident, only show logs for their flat
              if (controller.currentUserRole.value == 'resident') {
                allLogs = allLogs.where((log) => 
                  log['flat'] == controller.currentUserFlat.value && 
                  log['block'] == controller.currentUserBlock.value
                ).toList();
              }

              // Remove duplicates if any
              final uniqueLogs = <Map<String, dynamic>>[];
              final seen = <String>{};
              for (var log in allLogs) {
                final key = log['id'] ?? '${log['name']}_${log['time']}';
                if (!seen.contains(key)) {
                  uniqueLogs.add(log);
                  seen.add(key);
                }
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: uniqueLogs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = uniqueLogs[index];
                  return _logItem(log);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _logItem(Map<String, dynamic> log) {
    bool isOut = log['status'] == 'out';
    Color color = isOut ? const Color(0xFF94A3B8) : const Color(0xFF00BFA5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isOut ? Icons.logout_rounded : Icons.login_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['name'] ?? 'Unknown',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
                Text(
                  isOut ? 'Out: ${log['checkout_time']}' : 'In: ${log['time']}',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                ),
                if (log['purpose'] != null && log['purpose'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Purpose: ${log['purpose']}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
          if (!isOut)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Still Inside',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00BFA5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
