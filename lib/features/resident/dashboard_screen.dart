import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../dashboard_controller.dart';
import '../payments/payment_controller.dart';
import '../auth/controllers/auth_controller.dart';

class ResidentDashboard extends StatelessWidget {
  ResidentDashboard({super.key});

  final DashboardController controller = Get.find<DashboardController>();
  final PaymentController paymentController = Get.put(PaymentController());
  final PageController _bannerPageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _buildBody(),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.payment_rounded), label: 'Payments'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Complaints'),
            BottomNavigationBarItem(icon: Icon(Icons.group_rounded), label: 'Visitors'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      )),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // ── Sticky Header ───────────────────────────────
        SliverAppBar(
          expandedHeight: 110,
          toolbarHeight: 110,
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
          title: Obx(() => Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        controller.currentUserName.value.isNotEmpty
                            ? controller.currentUserName.value[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                          controller.societyName.value,
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Resident • Flat ${controller.currentUserFlat.value.isNotEmpty ? controller.currentUserFlat.value : "N/A"}',
                          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed('/notices'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (controller.currentUserRole.value == 'super_admin')
                        GestureDetector(
                          onTap: () => Get.find<AuthController>().logout(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Content Area ──────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerSlider(),
                const SizedBox(height: 40),

                // Maintenance Card
                _buildMaintenanceCard(),
                const SizedBox(height: 40),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 0),
                _buildQuickActions(),

                const SizedBox(height: 40),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 40),
                _buildRecentActivity(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Banner Slider Widget
  Widget _buildBannerSlider() {
    final List<List<Color>> fallbackGradients = [
      [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
      [const Color(0xFF00897B), const Color(0xFF4DB6AC)],
      [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
    ];

    return Obx(() {
      if (controller.bannerImages.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: 220, // Increased height to 220
            child: PageView.builder(
              controller: _bannerPageController,
              itemCount: controller.bannerImages.length,
              onPageChanged: (index) => controller.currentBannerIndex.value = index,
              itemBuilder: (context, index) {
                final banner = controller.bannerImages[index];
                final colors = fallbackGradients[index % fallbackGradients.length];
                final String imageUrl = banner['image_url'] ?? '';
                final String link = banner['link'] ?? '';

                return GestureDetector(
                  onTap: () async {
                    String finalLink = link.trim().replaceAll(' ', '');
                    if (finalLink.isEmpty) return;

                    // Show Loading
                    controller.isOpeningLink.value = true;
                    Get.dialog(
                      const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Color(0xFF1565C0)),
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );

                    // Ensure link has a protocol
                    if (!finalLink.startsWith('http://') && !finalLink.startsWith('https://')) {
                      finalLink = 'https://$finalLink';
                    }
                    
                    try {
                      final Uri url = Uri.parse(finalLink);
                      final bool launched = await launchUrl(
                        url, 
                        mode: LaunchMode.externalApplication,
                      );
                      
                      if (!launched) {
                        Get.snackbar('Error', 'No application found to open this link', 
                          backgroundColor: Colors.redAccent, colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM);
                      }
                    } catch (e) {
                      Get.snackbar('Error', 'Invalid link format: $finalLink', 
                        backgroundColor: Colors.redAccent, colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM);
                    } finally {
                      controller.isOpeningLink.value = false;
                      if (Get.isDialogOpen ?? false) Get.back();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          // 1. Background (Gradient or Network Image)
                          Positioned.fill(
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: colors),
                                        ),
                                        child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: colors),
                                      ),
                                      child: const Icon(Icons.image_not_supported_rounded, color: Colors.white30, size: 40),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: colors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                          ),
                          
                          // 2. Dark Overlay for text readability
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),

                          // 3. Text Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (banner['title'] != null && banner['title']!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      banner['title']!,
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  banner['subtitle'] ?? '',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18, // Slightly larger font for larger banner
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.bannerImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: controller.currentBannerIndex.value == index ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: controller.currentBannerIndex.value == index
                      ? const Color(0xFF1565C0)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMaintenanceCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.isMaintenancePaid.value
              ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
              : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (controller.isMaintenancePaid.value
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF1565C0))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  controller.isMaintenancePaid.value
                      ? Icons.check_circle_rounded
                      : Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                controller.isMaintenancePaid.value ? 'Maintenance Paid' : 'Maintenance Due',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${paymentController.currentMaintenanceAmount.value.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Due: ${controller.maintenanceDueDate.value}',
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (!controller.isMaintenancePaid.value)
                GestureDetector(
                  onTap: () => Get.toNamed('/payment'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Pay Now',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildQuickActions() {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 0.95,
      children: [
        if (controller.isPaymentsEnabled.value)
          _quickAction(Icons.payment_rounded, 'Pay Now', const Color(0xFF1565C0), '/payment'),
        if (controller.isComplaintEnabled.value)
          _quickAction(Icons.campaign_rounded, 'Complaint', const Color(0xFFE65100), '/my-complaints'),
        if (controller.isVisitorsEnabled.value)
          _quickAction(Icons.group_rounded, 'Visitors', const Color(0xFF00897B), '/visitor-management'),
        if (controller.isNoticeEnabled.value)
          _quickAction(Icons.notifications_active_rounded, 'Notices', const Color(0xFF6A1B9A), '/notices'),
        if (controller.isSosEnabled.value)
          _quickAction(Icons.emergency_rounded, 'SOS', const Color(0xFFD32F2F), '/sos'),
        if (controller.isSpinEnabled.value)
          _quickAction(Icons.casino_rounded, 'Spin & Win', const Color(0xFFF9A825), '/spin'),
      ],
    ));
  }

  Widget _quickAction(IconData icon, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              'No recent activity',
              style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActivityIcon(activity['type']!),
                  color: _getActivityColor(activity['type']!),
                  size: 20,
                ),
              ),
              title: Text(
                activity['title']!,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
              subtitle: Text(
                activity['time']!,
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
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
      case 'notice': return const Color(0xFF6A1B9A);
      case 'sos': return const Color(0xFFD32F2F);
      case 'spin': return const Color(0xFFF9A825);
      default: return const Color(0xFF1565C0);
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'visitor': return Icons.group_rounded;
      case 'payment': return Icons.payment_rounded;
      case 'complaint': return Icons.report_problem_rounded;
      case 'notice': return Icons.notifications_active_rounded;
      case 'sos': return Icons.emergency_rounded;
      case 'spin': return Icons.casino_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
