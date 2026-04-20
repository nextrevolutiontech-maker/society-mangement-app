import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../dashboard_controller.dart';
import '../auth/controllers/auth_controller.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ─────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1565C0),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Dashboard',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              Obx(() => Text(
                                controller.currentUserName.value,
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                              )),
                            ],
                          ),
                        ),
                        // Notification
                        GestureDetector(
                          onTap: () => Get.toNamed('/notices'),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                Positioned(
                                  right: 9,
                                  top: 9,
                                  child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFFF5252)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Logout
                        GestureDetector(
                          onTap: () => Get.find<AuthController>().logout(),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body Content ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SUMMARY CARDS
                  Text(
                    'Summary',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 15),
                  Obx(() => GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.45,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _summaryCard(
                        'Total Residents',
                        controller.totalResidents.value.toString(),
                        Icons.people_rounded,
                        const Color(0xFF1565C0),
                        const Color(0xFFE3F2FD),
                      ),
                      _summaryCard(
                        'Complaints',
                        controller.pendingComplaints.value.toString(),
                        Icons.report_problem_rounded,
                        const Color(0xFFE65100),
                        const Color(0xFFFFF3E0),
                      ),
                      _summaryCard(
                        'Payments',
                        controller.totalPaymentsCollected.value,
                        Icons.account_balance_wallet_rounded,
                        const Color(0xFF2E7D32),
                        const Color(0xFFE8F5E9),
                      ),
                      _summaryCard(
                        'Visitors Today',
                        controller.totalVisitorsToday.value.toString(),
                        Icons.group_rounded,
                        const Color(0xFF00897B),
                        const Color(0xFFE0F2F1),
                      ),
                    ],
                  )),

                  const SizedBox(height: 28),

                  // 2. MANAGE ACTIONS
                  Text(
                    'Manage Actions',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _actionButton('Add Resident', Icons.person_add_rounded, const Color(0xFF1565C0), '/add-resident'),
                      _actionButton('Add Guard', Icons.security_rounded, const Color(0xFF283593), '/add-guard'),
                      _actionButton('Complaints', Icons.list_alt_rounded, const Color(0xFFE65100), '/complaint'),
                      _actionButton('Payments', Icons.payments_rounded, const Color(0xFF2E7D32), '/payment-reports'),
                      _actionButton('Notices', Icons.campaign_rounded, const Color(0xFF6A1B9A), '/notices'),
                      _actionButton('All Users', Icons.people_alt_rounded, const Color(0xFF00897B), '/manage-users'),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 3. RECENT ACTIVITY
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 15),
                  _buildRecentActivity(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _summaryCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      if (controller.recentActivities.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text('No recent activity', style: GoogleFonts.poppins(color: const Color(0xFF94A3B8))),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: controller.recentActivities.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
          itemBuilder: (context, index) {
            final activity = controller.recentActivities[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getActivityIcon(activity['type']!), color: _getActivityColor(activity['type']!), size: 18),
              ),
              title: Text(activity['title']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(activity['time']!, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
            );
          },
        ),
      );
    });
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'visitor': return const Color(0xFF00897B);
      case 'payment': return const Color(0xFF2E7D32);
      case 'complaint': return const Color(0xFFE65100);
      case 'user': return const Color(0xFF1565C0);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'visitor': return Icons.group_rounded;
      case 'payment': return Icons.payment_rounded;
      case 'complaint': return Icons.report_problem_rounded;
      case 'user': return Icons.person_add_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
