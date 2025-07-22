import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quick_actions_controller.dart';

class QuickActionsView extends GetView<QuickActionsController> {
  const QuickActionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(controller.clientName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.blue[600]),
            onPressed: () => Get.toNamed('/care/history'),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.blue[600]),
            onSelected: (value) {
              switch (value) {
                case 'client_details':
                  Get.back(); // Go back to client dashboard
                  break;
                case 'settings':
                  Get.snackbar(
                    'Info',
                    'Settings coming soon',
                    backgroundColor: Colors.blue[100],
                    colorText: Colors.blue[800],
                  );
                  break;
                case 'help':
                  Get.snackbar(
                    'Help',
                    'Tap any action card to log care activities for this client',
                    backgroundColor: Colors.green[100],
                    colorText: Colors.green[800],
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'client_details',
                child: Row(
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 8),
                    Text('Client Details'),
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
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to log activities for ${controller.clientName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Quick actions grid
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    icon: Icons.medication,
                    title: 'Medication Given',
                    subtitle: 'Log medication as given',
                    color: Colors.green,
                    onTap: () => controller.showMedicationActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.cancel,
                    title: 'Medication Refused',
                    subtitle: 'Log medication as refused',
                    color: Colors.red,
                    onTap: () => controller.showMedicationActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.wc,
                    title: 'Toileting',
                    subtitle: 'Bathroom & stool',
                    color: Colors.orange,
                    onTap: () => controller.showToiletingActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.location_on,
                    title: 'Location & Presence',
                    subtitle: 'Where is the client?',
                    color: Colors.teal,
                    onTap: () => controller.showLocationActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.restaurant,
                    title: 'Meals',
                    subtitle: 'Nutrition & meals',
                    color: Colors.green,
                    onTap: () => controller.showMealActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.local_drink,
                    title: 'Hydration',
                    subtitle: 'Fluid intake',
                    color: Colors.blue,
                    onTap: () => controller.showHydrationActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.psychology,
                    title: 'Behavior/Mood',
                    subtitle: 'Behavior & mood',
                    color: Colors.purple,
                    onTap: () => controller.showBehaviorActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.note,
                    title: 'Note',
                    subtitle: 'General notes',
                    color: Colors.blue,
                    onTap: () => controller.showNoteDialog(),
                  ),
                  _buildActionCard(
                    icon: Icons.camera_alt,
                    title: 'Photo/Attachment',
                    subtitle: 'Photo documentation',
                    color: Colors.grey,
                    onTap: () => controller.takePhoto(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.toNamed('/home');
                break;
              case 1:
                Get.toNamed('/client/dashboard');
                break;
              case 2:
                Get.toNamed('/tasks');
                break;
              case 3:
                Get.snackbar(
                  'Info',
                  'Settings coming soon',
                  backgroundColor: Colors.blue[100],
                  colorText: Colors.blue[800],
                );
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[600],
          unselectedItemColor: Colors.grey[600],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 