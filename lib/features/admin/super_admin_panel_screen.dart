import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../dashboard_controller.dart';
import '../auth/controllers/auth_controller.dart';

class SuperAdminPanel extends StatelessWidget {
  SuperAdminPanel({super.key});

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
            backgroundColor: const Color(0xFF0D47A1),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: GetBuilder<DashboardController>(
              builder: (controller) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Super Admin Panel',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          controller.currentUserName.value,
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
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

          // ── Body ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. GLOBAL SUMMARY
                  Obx(() => Column(
                    children: [
                      Row(
                        children: [
                          _globalStat('Societies', controller.totalSocieties.value.toString(), Icons.business_rounded, const Color(0xFF1565C0)),
                          const SizedBox(width: 12),
                          _globalStat('Total Users', controller.totalUsers.value.toString(), Icons.people_rounded, const Color(0xFF283593)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _globalStat('DAU', controller.dauCount.value.toString(), Icons.bolt_rounded, const Color(0xFF2E7D32)),
                          const SizedBox(width: 12),
                          _globalStat('WAU', controller.wauCount.value.toString(), Icons.trending_up_rounded, const Color(0xFF0D47A1)),
                          const SizedBox(width: 12),
                          _globalStat('MAU', controller.mauCount.value.toString(), Icons.analytics_rounded, const Color(0xFF6A1B9A)),
                        ],
                      ),
                    ],
                  )),

                  const SizedBox(height: 32),

                  // 2. PLATFORM CONTROLS
                  Text(
                    'Platform Controls',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 12,
                    children: [
                      _controlAction('Manage Societies', Icons.add_business_rounded, const Color(0xFF1565C0), () => Get.toNamed('/manage-societies')),
                      _controlAction('Add Admin', Icons.admin_panel_settings_rounded, const Color(0xFF6A1B9A), () => Get.toNamed('/add-admin')),
                      _controlAction('Manage Users', Icons.people_alt_rounded, const Color(0xFF00897B), () => Get.toNamed('/manage-users')),
                      _controlAction('Banner Control', Icons.image_rounded, const Color(0xFFAD1457), () => Get.toNamed('/banner-settings')),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 3. PUSH NOTIFICATION
                  Text(
                    'Push Notification',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  _buildPushNotificationCard(),

                  const SizedBox(height: 40),

                  const SizedBox(height: 10),

                  const SizedBox(height: 40),

                  // 5. RECENT ACTIVITY
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
  // GLOBAL STATS
  // ══════════════════════════════════════════════════════════

  Widget _globalStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            ),
            Text(
              label, 
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // CONTROL ACTIONS
  // ══════════════════════════════════════════════════════════

  Widget _controlAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // PUSH NOTIFICATION CARD
  // ══════════════════════════════════════════════════════════

  Widget _buildPushNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.notificationTitleController,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Notification title',
              labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFFE65100), size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.notificationMessageController,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Message',
              hintText: 'Write your message...',
              labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.message_rounded, color: Color(0xFFE65100), size: 20),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: controller.isSendingNotification.value
                  ? null
                  : () => controller.sendPushNotification(),
              icon: controller.isSendingNotification.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(
                controller.isSendingNotification.value ? 'Sending...' : 'Send to All Users',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                shadowColor: const Color(0xFFE65100).withOpacity(0.4),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FEATURE TOGGLES
  // ══════════════════════════════════════════════════════════



  // ══════════════════════════════════════════════════════════
  // RECENT ACTIVITY
  // ══════════════════════════════════════════════════════════

  Widget _buildRecentActivity() {
    return Obx(() {
      if (controller.recentActivities.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text('No recent activity', style: GoogleFonts.poppins(color: const Color(0xFF94A3B8)))),
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
      case 'society': return const Color(0xFF1565C0);
      case 'user': return const Color(0xFF6A1B9A);
      case 'setting': return const Color(0xFFE65100);
      case 'banner': return const Color(0xFFAD1457);
      case 'notification': return const Color(0xFF00897B);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'society': return Icons.business_rounded;
      case 'user': return Icons.person_add_rounded;
      case 'setting': return Icons.settings_rounded;
      case 'banner': return Icons.image_rounded;
      case 'notification': return Icons.send_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
