import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_client_controller.dart';
import '../../../widgets/enhanced_text_field.dart';
import '../../../widgets/keyboard_aware_wrapper.dart';
import '../../../services/keyboard_service.dart';
import '../../../utils/spacing_constants.dart';

class EditClientView extends GetView<EditClientController> {
  const EditClientView({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-focus the first field when the view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(controller.nameFocusNode);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Edit Client'),
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
            onPressed: controller.updateClient,
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
                    'Edit the client name and home, then tap Save to update',
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
      body: KeyboardAwareWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Container(
              padding: SpacingConstants.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
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
                      Icons.person,
                      size: 40,
                      color: Colors.blue[600],
                    ),
                  ),
                  Spacing.md,
                  const Text(
                    'Edit Client Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Spacing.lg,
            
            // Form fields
            Container(
              padding: SpacingConstants.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  EnhancedTextField(
                    controller: controller.nameController,
                    focusNode: controller.nameFocusNode,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person,
                    isRequired: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => KeyboardService.to.dismissKeyboard(),
                  ),
                  Spacing.md,
                  _buildHomeDropdown(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildHomeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.home, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Home',
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
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedHome.value.isEmpty ? null : controller.selectedHome.value,
                    hint: const Text('Select a home'),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    items: [
                      ...controller.availableHomes.map((home) => DropdownMenuItem<String>(
                        value: home,
                        child: Text(home),
                      )),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectHome(value);
                      }
                    },
                  ),
                )),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: IconButton(
                  onPressed: controller.showAddNewHomeDialog,
                  icon: Icon(Icons.add, color: Colors.blue[600]),
                  tooltip: 'Add new home',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 