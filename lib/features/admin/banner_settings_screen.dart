import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_keys.dart';
import '../dashboard_controller.dart';

class BannerSettingsScreen extends StatefulWidget {
  const BannerSettingsScreen({super.key});

  @override
  State<BannerSettingsScreen> createState() => _BannerSettingsScreenState();
}

class _BannerSettingsScreenState extends State<BannerSettingsScreen> {
  final DashboardController controller = Get.find<DashboardController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  late String targetSocietyId;
  late bool isGlobal;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final argSocietyId = Get.arguments?['societyId'];

    if (argSocietyId != null) {
      targetSocietyId = argSocietyId;
    } else if (controller.currentUserRole.value == 'super_admin') {
      targetSocietyId = '';
    } else {
      targetSocietyId = controller.currentUserSociety.value.isNotEmpty
          ? controller.currentUserSociety.value
          : controller.societyId.value;
    }

    isGlobal = targetSocietyId.isEmpty;
    debugPrint('BannerSettings: targetSocietyId=$targetSocietyId, isGlobal=$isGlobal');
    controller.loadBannerDataForSociety(targetSocietyId);

    // Safety net: retry after frame if societyId was empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isGlobal && targetSocietyId.isEmpty) {
        final retryId = controller.currentUserSociety.value.isNotEmpty
            ? controller.currentUserSociety.value
            : controller.societyId.value;
        if (retryId.isNotEmpty) {
          setState(() => targetSocietyId = retryId);
          debugPrint('BannerSettings retry: targetSocietyId=$retryId');
          controller.loadBannerDataForSociety(retryId);
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final String cloudName = ApiKeys.cloudinaryCloudName;
      final String uploadPreset = ApiKeys.cloudinaryUploadPreset;
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final request = http.MultipartRequest("POST", uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = utf8.decode(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        throw 'Cloudinary Upload Failed: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Cloudinary Error: $e');
      rethrow;
    }
  }

  Future<void> _addBanner() async {
    if (_imageFile == null && _titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide at least a photo or a title',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    try {
      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!) ?? '';
      }

      final collectionRef = isGlobal
          ? FirebaseFirestore.instance.collection('banners')
          : FirebaseFirestore.instance
              .collection('societies')
              .doc(targetSocietyId)
              .collection('banners');

      await collectionRef.add({
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'link': _linkController.text.trim(),
        'image_url': imageUrl,
        'order': DateTime.now().millisecondsSinceEpoch,
        'created_at': FieldValue.serverTimestamp(),
      });

      _imageFile = null;
      _titleController.clear();
      _subtitleController.clear();
      _linkController.clear();
      if (mounted) Navigator.pop(context);
      Get.snackbar('Success ✅', '${isGlobal ? "Global" : "Society"} Banner added!',
          backgroundColor: Colors.green.shade600, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteBanner(String id, String imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Banner', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove this banner?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final collectionRef = isGlobal
          ? FirebaseFirestore.instance.collection('banners')
          : FirebaseFirestore.instance
              .collection('societies')
              .doc(targetSocietyId)
              .collection('banners');

      await collectionRef.doc(id).delete();
      Get.snackbar('Deleted 🗑️', 'Banner removed successfully',
          backgroundColor: Colors.orange.shade700, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF1565C0)),
              const SizedBox(width: 8),
              Text('Add Banner', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (pickedFile != null) {
                      setDialogState(() => _imageFile = File(pickedFile.path));
                      setState(() {});
                    }
                  },
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3), width: 1.5),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(_imageFile!, fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, color: Colors.grey.shade400, size: 36),
                              const SizedBox(height: 8),
                              Text('Tap to select photo',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Banner Title',
                    hintText: 'e.g. Society Event',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  decoration: InputDecoration(
                    labelText: 'Subtitle',
                    hintText: 'e.g. Join us this Saturday',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    labelText: 'Link (Optional)',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: GoogleFonts.poppins())),
            ElevatedButton(
              onPressed: _isSaving ? null : _addBanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_upload_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Upload', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = controller.currentUserRole.value;
    
    // RESTRICTION: Only Super Admin can manage banners
    if (role != 'super_admin') {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('Banner Settings', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 24),
                Text('Access Restricted', 
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 12),
                Text('Only Super Admins have authority to add or manage banners.', 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
                const SizedBox(height: 32),
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Go Back', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGlobal ? 'Global Banners' : 'Banner Settings',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    isGlobal
                        ? '🌐 Visible to ALL societies'
                        : controller.societyName.value,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final List<Map<String, dynamic>> displayBanners =
            isGlobal ? controller.globalBanners : controller.societyBanners;

        if (displayBanners.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported_outlined, size: 70, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No Banners Found',
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Text('Tap "Add" to upload your first banner.',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add_photo_alternate_rounded),
                  label: Text('Add Banner', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: displayBanners.length,
          itemBuilder: (context, index) {
            final banner = displayBanners[index];
            final String imageUrl = banner['image_url'] ?? '';
            final String title = banner['title'] ?? 'No Title';
            final String subtitle = banner['subtitle'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                              errorBuilder: (c, e, s) => _fallbackGradient(),
                            )
                          : _fallbackGradient(),
                    ),
                  ),
                  // Banner Info + Delete
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: const Color(0xFF1E293B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: const Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteBanner(banner['id']!, imageUrl),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _fallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white38, size: 50),
      ),
    );
  }
}
