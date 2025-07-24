import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_dashboard_controller.dart';
import '../models/client_model.dart';
import '../../../widgets/universal_popup.dart';
import '../../../widgets/universal_bottom_navigation.dart';

class ClientDashboardView extends GetView<ClientDashboardController> {
  const ClientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Clients',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.blue[600]),
              onSelected: (value) {
                switch (value) {
                  case 'refresh':
                    controller.refreshClients();
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
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refresh'),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced location selector
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[50]!, Colors.blue[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _showLocationSelector(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, color: Colors.blue[700], size: 18),
                          const SizedBox(width: 10),
                          Obx(() => Text(
                            controller.selectedHome.value,
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          )),
                          const SizedBox(width: 10),
                          Icon(Icons.keyboard_arrow_down, color: Colors.blue[700], size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Clients Section Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const Text(
                    'Clients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage and view client information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Client list
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading clients...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.filteredClients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.blue[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No clients yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first client to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: controller.showAddOptionsDrawer,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Client'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: controller.filteredClients.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final client = controller.filteredClients[index];
                  return _buildClientCard(client, index);
                },
              );
            }),
            
            // Quick Actions Section - Only show when a specific home is selected
            Obx(() {
              // Only show quick actions when a specific home is selected (not "All Homes")
              if (controller.selectedHome.value == 'All Homes') {
                return const SizedBox.shrink(); // Hide the section
              }
              
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          'Quick Actions - ${controller.selectedHome.value}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to log facility activities and manage shift',
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
                        icon: Icons.access_time,
                        title: 'Clock In/Out',
                        subtitle: 'Toggle shift status',
                        color: Colors.blue,
                        onTap: () => _showClockInOutDialog(),
                      ),
                      _buildActionCard(
                        icon: Icons.coffee,
                        title: 'Break',
                        subtitle: 'Start/End break',
                        color: Colors.orange,
                        onTap: () => _showBreakDialog(),
                      ),
                      _buildActionCard(
                        icon: Icons.note,
                        title: 'House Note',
                        subtitle: 'Quick facility notes',
                        color: Colors.green,
                        onTap: () => _showHouseNoteDialog(),
                      ),
                      _buildActionCard(
                        icon: Icons.inventory,
                        title: 'Supplies',
                        subtitle: 'Check supply status',
                        color: Colors.purple,
                        onTap: () => _showSuppliesDialog(),
                      ),
                      _buildActionCard(
                        icon: Icons.report_problem,
                        title: 'Complaint/Concern',
                        subtitle: 'Report issues',
                        color: Colors.red,
                        onTap: () => _showComplaintDialog(),
                      ),
                      _buildActionCard(
                        icon: Icons.checklist,
                        title: 'Shift Checklist',
                        subtitle: 'Complete shift tasks',
                        color: Colors.teal,
                        onTap: () => _showChecklistDialog(),
                      ),
                      _buildActionCard(
                        icon: Icons.history,
                        title: 'Facility History',
                        subtitle: 'View activity logs',
                        color: Colors.indigo,
                        onTap: () => controller.viewFacilityHistory(),
                      ),
                    ],
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 100), // Bottom padding for bottom navigation
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: controller.showAddOptionsDrawer,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      bottomNavigationBar: const UniversalBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildClientCard(Client client, int index) {
    final colors = [
      [Colors.blue[400]!, Colors.blue[600]!],
      [Colors.green[400]!, Colors.green[600]!],
      [Colors.purple[400]!, Colors.purple[600]!],
      [Colors.orange[400]!, Colors.orange[600]!],
      [Colors.teal[400]!, Colors.teal[600]!],
      [Colors.pink[400]!, Colors.pink[600]!],
    ];
    
    final colorPair = colors[index % colors.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewClientDetails(client),
          onLongPress: () => _showClientOptions(client),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colorPair,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorPair[0].withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      client.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    client.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
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
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationSelector() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Home',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            ...controller.homes.map((home) => _buildLocationOption(home, home == controller.selectedHome.value)),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildLocationOption(String home, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
          ? Border.all(color: Colors.blue[200]!, width: 2)
          : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.home,
            color: isSelected ? Colors.blue[600] : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          home,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue[800] : Colors.grey[700],
            fontSize: 16,
          ),
        ),
        trailing: isSelected 
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            )
          : null,
        onTap: () {
          Get.back();
          controller.selectHome(home);
          Get.snackbar(
            'Home Filter Changed',
            'Showing clients from $home',
            backgroundColor: Colors.green[100],
            colorText: Colors.green[800],
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          );
        },
      ),
    );
  }

  void _showClockInOutDialog() {
    UniversalPopup.show(
      title: 'Clock In/Out',
      subtitle: 'Toggle your shift status',
      icon: Icons.access_time,
      color: Colors.blue,
      actions: [
        PopupAction(
          title: 'Cancel',
          icon: Icons.close,
          color: Colors.grey,
          onTap: () => Get.back(),
        ),
        PopupAction(
          title: controller.isOnShift.value ? 'Clock Out' : 'Clock In',
          icon: controller.isOnShift.value ? Icons.logout : Icons.login,
          color: Colors.blue,
          onTap: () {
            Get.back();
            controller.clockInOut();
          },
        ),
      ],
    );
  }

  void _showBreakDialog() {
    UniversalPopup.show(
      title: 'Break Management',
      subtitle: 'Start or end your break',
      icon: Icons.coffee,
      color: Colors.orange,
      actions: [
        PopupAction(
          title: 'Cancel',
          icon: Icons.close,
          color: Colors.grey,
          onTap: () => Get.back(),
        ),
        PopupAction(
          title: controller.isOnBreak.value ? 'End Break' : 'Start Break',
          icon: controller.isOnBreak.value ? Icons.stop : Icons.play_arrow,
          color: Colors.orange,
          onTap: () {
            Get.back();
            controller.startEndBreak();
          },
        ),
      ],
    );
  }

  void _showHouseNoteDialog() {
    UniversalPopup.showInputDialog(
      title: 'House Note',
      hintText: 'Enter your house note here...',
      maxLines: 3,
      onConfirm: (note) {
        controller.saveHouseNote(note);
      },
    );
  }

  void _showSuppliesDialog() {
    UniversalPopup.showSubOptions(
      title: 'Supplies Check',
      options: [
        'Cleaning Supplies',
        'Medical Supplies', 
        'Food & Beverages',
        'Personal Care Items',
        'Safety Equipment',
        'Office Supplies',
      ],
      onSelect: (supply) {
        controller.addLog(
          'Supplies Check',
          'Checked $supply',
          'supplies',
          additionalData: {'supply': supply},
        );
        Get.snackbar(
          'Supplies Check',
          '$supply status recorded',
          backgroundColor: Colors.purple[100],
          colorText: Colors.purple[800],
        );
      },
    );
  }

  void _showComplaintDialog() {
    UniversalPopup.showInputDialog(
      title: 'Complaint/Concern',
      hintText: 'Describe your complaint or concern...',
      maxLines: 4,
      onConfirm: (complaint) {
        controller.submitComplaint(complaint);
      },
    );
  }

  void _showChecklistDialog() {
    UniversalPopup.showSubOptions(
      title: 'Shift Checklist',
      options: [
        'Trash emptied',
        'Bathrooms checked',
        'Lights off',
        'Clients stable',
        'Security check',
        'Documentation complete',
      ],
      onSelect: (task) {
        controller.addLog(
          'Checklist Item',
          'Completed: $task',
          'checklist',
          additionalData: {'task': task},
        );
        Get.snackbar(
          'Checklist Updated',
          '$task marked as complete',
          backgroundColor: Colors.teal[100],
          colorText: Colors.teal[800],
        );
      },
    );
  }

  void _showClientOptions(Client client) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    client.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                client.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select an action',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Edit option
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      controller.editClient(client);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Client',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Text(
                                  'Modify client information',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Delete option
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      _showDeleteConfirmation(client);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete Client',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[800],
                                  ),
                                ),
                                Text(
                                  'Remove client permanently',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Client client) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red[200]!, width: 2),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red[600],
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Delete Client',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${client.name}"?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteClient(client);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 