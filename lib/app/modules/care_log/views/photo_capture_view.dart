import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/photo_capture_controller.dart';

class PhotoCaptureView extends GetView<PhotoCaptureController> {
  const PhotoCaptureView({super.key});

    @override
  Widget build(BuildContext context) {
    // Auto-focus the notes field when the view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(controller.notesFocusNode);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add Photo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (controller.selectedPhotoPath.value.isNotEmpty)
            TextButton(
              onPressed: controller.savePhoto,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.blue[600]),
            onSelected: (value) {
              switch (value) {
                case 'help':
                  Get.snackbar(
                    'Help',
                    'Take a photo or select from gallery, then add optional notes and save',
                    backgroundColor: Colors.green[100],
                    colorText: Colors.green[800],
                  );
                  break;
                case 'settings':
                  Get.snackbar(
                    'Info',
                    'Settings coming soon',
                    backgroundColor: Colors.blue[100],
                    colorText: Colors.blue[800],
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            // Photo preview
            Obx(() {
              if (controller.selectedPhotoPath.value.isNotEmpty) {
                return Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(controller.selectedPhotoPath.value),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              return Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Photo Selected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a photo or select from gallery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    color: Colors.blue[600]!,
                    onTap: controller.takePhoto,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: Colors.green[600]!,
                    onTap: controller.pickFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Notes field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                                     Container(
                                       width: double.infinity,
                                       child: TextField(
                                         controller: controller.notesController,
                                         focusNode: controller.notesFocusNode,
                                         maxLines: 3,
                                         textInputAction: TextInputAction.done,
                                         onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                         decoration: InputDecoration(
                                           hintText: 'Add notes about this photo...',
                                           border: OutlineInputBorder(
                                             borderRadius: BorderRadius.circular(12),
                                             borderSide: BorderSide(color: Colors.grey[300]!),
                                           ),
                                           enabledBorder: OutlineInputBorder(
                                             borderRadius: BorderRadius.circular(12),
                                             borderSide: BorderSide(color: Colors.grey[300]!),
                                           ),
                                           focusedBorder: OutlineInputBorder(
                                             borderRadius: BorderRadius.circular(12),
                                             borderSide: BorderSide(color: Colors.blue[600]!),
                                           ),
                                           filled: true,
                                           fillColor: Colors.grey[50],
                                           contentPadding: const EdgeInsets.symmetric(
                                             horizontal: 16,
                                             vertical: 12,
                                           ),
                                           suffixIcon: IconButton(
                                             icon: Icon(Icons.keyboard_hide, color: Colors.grey[600]),
                                             onPressed: () => FocusScope.of(context).unfocus(),
                                           ),
                                         ),
                                       ),
                                     ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 