import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_client_controller.dart';

class AddClientView extends GetView<AddClientController> {
  const AddClientView({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-focus the first field when the view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(controller.nameFocusNode);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add Client'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: controller.saveClient,
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
                    'Fill in the required fields (name is required) and tap Save to add the client',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  // Avatar placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 40,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Client Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Form fields
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  _buildTextField(
                    context: context,
                    controller: controller.nameController,
                    focusNode: controller.nameFocusNode,
                    label: 'Full Name',
                    icon: Icons.person,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: controller.phoneController,
                    focusNode: controller.phoneFocusNode,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: controller.addressController,
                    focusNode: controller.addressFocusNode,
                    label: 'Address',
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: controller.emergencyContactController,
                    focusNode: controller.emergencyContactFocusNode,
                    label: 'Emergency Contact',
                    icon: Icons.emergency,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: controller.medicalNotesController,
                    focusNode: controller.medicalNotesFocusNode,
                    label: 'Medical Notes',
                    icon: Icons.medical_services,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.done,
            onSubmitted: (_) {
              // Auto-focus next field or dismiss keyboard
              if (context.mounted) {
                FocusScope.of(context).nextFocus();
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter ${label.toLowerCase()}',
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
              suffixIcon: maxLines > 1 ? IconButton(
                icon: Icon(Icons.keyboard_hide, color: Colors.grey[600]),
                onPressed: () {
                  if (context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ) : null,
            ),
          ),
        ),
      ],
    );
  }
} 