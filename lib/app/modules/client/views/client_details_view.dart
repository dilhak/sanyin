import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_details_controller.dart';

class ClientDetailsView extends GetView<ClientDetailsController> {
  const ClientDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(controller.client.name),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
          onPressed: () => controller.goBack(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.blue[600]),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  controller.editClient();
                  break;
                case 'reminders':
                  controller.showReminderManagement();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text('Edit Client'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reminders',
                child: Row(
                  children: [
                    Icon(Icons.notifications, size: 18, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    const Text('Manage Reminders'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Quick actions header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to log activities for ${controller.client.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick actions grid
              GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionCard(
                    icon: Icons.favorite,
                    title: 'Vitals',
                    subtitle: 'Blood pressure, pulse, etc.',
                    color: Colors.pink,
                    onTap: () => controller.showVitalsForm(),
                  ),
                  _buildActionCard(
                    icon: Icons.sick,
                    title: 'Pain & Discomfort',
                    subtitle: 'Pain assessment',
                    color: Colors.red,
                    onTap: () => controller.showPainActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.medication,
                    title: 'Medication',
                    subtitle: 'Log medication status',
                    color: Colors.green,
                    onTap: () => controller.showMedicationActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.location_on,
                    title: 'Location & Presence',
                    subtitle: 'Where is the client?',
                    color: Colors.teal,
                    onTap: () => controller.showLocationActions(),
                  ),
                  _buildActionCard(
                    icon: Icons.wc,
                    title: 'Toileting',
                    subtitle: 'Bathroom & stool',
                    color: Colors.orange,
                    onTap: () => controller.showToiletingActions(),
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
                  _buildActionCard(
                    icon: Icons.history,
                    title: 'Care History',
                    subtitle: 'View care logs',
                    color: Colors.indigo,
                    onTap: () => controller.openCareHistory(),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Bottom padding for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
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
            color: Colors.grey.withValues(alpha: 0.1),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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