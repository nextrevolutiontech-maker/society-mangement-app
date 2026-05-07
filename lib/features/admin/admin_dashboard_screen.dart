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
            expandedHeight: 95,
            toolbarHeight: 95,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1565C0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Obx(() => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/profile'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.currentUserName.value,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${controller.societyName.value} | Admin',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Profile Button
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notification
                  if (controller.isNoticeEnabled.value)
                    GestureDetector(
                      onTap: () => Get.toNamed('/notices'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Logout
                  if (controller.currentUserRole.value == 'super_admin')
                    GestureDetector(
                      onTap: () => Get.find<AuthController>().logout(),
                      child: Container(
                        width: 40,
                        height: 40,
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

          // ── Body Content ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SUMMARY CARDS
                  Text(
                    'Summary',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
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

                  const SizedBox(height: 40),

                  // 2. MANAGE ACTIONS
                  Text(
                    'Manage Actions',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _actionButton('Add Resident', Icons.person_add_rounded, const Color(0xFF1565C0), '/add-resident'),
                      _actionButton('Add Guard', Icons.security_rounded, const Color(0xFF283593), '/add-guard'),

                      _actionButton('Complaints', Icons.list_alt_rounded, const Color(0xFFE65100), '/admin-complaints'),
                      _actionButton('Payment Approvals', Icons.payments_rounded, const Color(0xFF2E7D32), '/admin-payments'),
                      _actionButton('Payment Settings', Icons.payments_outlined, const Color(0xFF1B5E20), '/payment-settings'),
                      _actionButton('Notices', Icons.campaign_rounded, const Color(0xFF6A1B9A), '/notices'),
                      _actionButton('Visitor Logs', Icons.history_edu_rounded, const Color(0xFF00BFA5), '/admin-visitor-logs'),
                      _actionButton('All Users', Icons.people_alt_rounded, const Color(0xFF00897B), '/manage-users'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 3. RECENT ACTIVITY
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(12), // Reduced padding
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
            padding: const EdgeInsets.all(4), // Even smaller padding
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14), // Smaller icon
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
          ),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
