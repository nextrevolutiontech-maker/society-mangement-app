import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'controllers/user_controller.dart';
import '../../core/models/user_model.dart';

class ManageUsersScreen extends StatelessWidget {
  ManageUsersScreen({super.key});

  final UserController controller = Get.put(UserController());

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
          'Manage Users',
          style: GoogleFonts.poppins(
            color: const Color(0xFF263238),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF1565C0), size: 26),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              switch (value) {
                case 'resident':
                  Get.toNamed('/add-resident');
                  break;
                case 'guard':
                  Get.toNamed('/add-guard');
                  break;
                case 'admin':
                  Get.toNamed('/add-admin');
                  break;
              }
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [
                PopupMenuItem(
                  value: 'resident',
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 20),
                      const SizedBox(width: 10),
                      Text('Add Resident', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'guard',
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: Color(0xFF283593), size: 20),
                      const SizedBox(width: 10),
                      Text('Add Guard', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ];

              // Only Super Admin can add Admins
              if (controller.currentAdminRole.value == 'super_admin') {
                items.add(
                  PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6A1B9A), size: 20),
                        const SizedBox(width: 10),
                        Text('Add Admin', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats Bar ─────────────────────────────────
          Obx(() => Container(
            margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Residents', controller.totalResidents.value.toString(), Icons.people_rounded),
                Container(width: 1, height: 35, color: Colors.white30),
                _statItem('Guards', controller.totalGuards.value.toString(), Icons.security_rounded),
                Container(width: 1, height: 35, color: Colors.white30),
                _statItem('Admins', controller.totalAdmins.value.toString(), Icons.admin_panel_settings_rounded),
              ],
            ),
          )),

          // ── Filter Chips ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All'),
                  const SizedBox(width: 10),
                  _filterChip('Residents'),
                  const SizedBox(width: 10),
                  _filterChip('Guards'),
                  const SizedBox(width: 10),
                  _filterChip('Admins'),
                ],
              ),
            )),
          ),

          // ── Users List ────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isUsersLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1565C0)),
                      SizedBox(height: 15),
                      Text('Loading users...', style: TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                );
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      Text(
                        'No users found',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tap + to add a new user',
                        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFBDBDBD)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  if (controller.currentAdminRole.value == 'super_admin') {
                    await controller.loadAllUsers();
                  } else {
                    await controller.loadSocietyUsers();
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return _userTile(user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _statItem(String label, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 5),
        Text(
          count,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = controller.selectedFilter.value == label;
    return GestureDetector(
      onTap: () => controller.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _userTile(UserModel user) {
    Color roleColor = _getRoleColor(user.role);
    String roleLabel = _getRoleLabel(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleLabel,
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: roleColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user.flatNo != null && user.flatNo!.isNotEmpty) ...[
                      Icon(Icons.home_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(
                        '${user.block != null && user.block!.isNotEmpty ? "${user.block}-" : ""}${user.flatNo}',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      user.mobile,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status + Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                      : const Color(0xFFD32F2F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: user.isActive ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // Action menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      controller.toggleUserStatus(user);
                      break;
                    case 'delete':
                      controller.deleteUser(user);
                      break;
                    case 'edit':
                      if (user.role == 'resident') {
                        Get.toNamed('/edit-resident', arguments: user);
                      }
                      break;
                  }
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> items = [];
                  if (user.role == 'resident') {
                    items.add(
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, color: Color(0xFF1565C0), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Edit Details',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  items.addAll([
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                            color: user.isActive ? Colors.orange : const Color(0xFF2E7D32),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            user.isActive ? 'Deactivate' : 'Activate',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Remove User',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ]);
                  return items;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFF6A1B9A);
      case 'guard':
        return const Color(0xFF283593);
      case 'resident':
        return const Color(0xFF1565C0);
      case 'super_admin':
        return const Color(0xFFEF6C00);
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'ADMIN';
      case 'guard':
        return 'GUARD';
      case 'resident':
        return 'RESIDENT';
      case 'super_admin':
        return 'SUPER ADMIN';
      default:
        return role.toUpperCase();
    }
  }
}
