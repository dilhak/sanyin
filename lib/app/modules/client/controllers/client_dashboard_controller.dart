import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../facility_logs/models/facility_log_model.dart';

class ClientDashboardController extends GetxController {
  final RxList<Client> clients = <Client>[].obs;
  final RxList<Client> filteredClients = <Client>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedHome = 'All Homes'.obs;
  final RxList<String> homes = <String>['All Homes'].obs;
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();

  // Quick Actions Controllers
  final TextEditingController houseNoteController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();
  final RxBool isOnShift = false.obs;
  final RxBool isOnBreak = false.obs;
  final Rx<DateTime?> clockInTime = Rx<DateTime?>(null);
  final Rx<DateTime?> breakStartTime = Rx<DateTime?>(null);

  // Facility History Logs
  final RxList<FacilityLog> facilityLogs = <FacilityLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  @override
  void onClose() {
    houseNoteController.dispose();
    complaintController.dispose();
    
    // Clear all reactive variables to prevent memory leaks
    clients.clear();
    filteredClients.clear();
    homes.clear();
    facilityLogs.clear();
    
    super.onClose();
  }

  Future<void> loadClients() async {
    isLoading.value = true;
    try {
      final clientsList = await _databaseService.getClients();
      clients.value = clientsList;
      _updateHomesList();
      _filterClients();
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _updateHomesList() {
    final homeSet = <String>{'All Homes'};
    for (final client in clients) {
      if (client.address != null && client.address!.isNotEmpty) {
        homeSet.add(client.address!);
      }
    }
    homes.value = homeSet.toList()..sort();
  }

  void _filterClients() {
    if (selectedHome.value == 'All Homes') {
      filteredClients.value = clients;
    } else {
      filteredClients.value = clients.where((client) => 
        client.address == selectedHome.value
      ).toList();
    }
  }

  void selectHome(String home) {
    selectedHome.value = home;
    _filterClients();
  }

  void addNewClient() {
    Get.toNamed(Routes.ADD_CLIENT);
  }

  void showAddOptionsDrawer() {
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
              'Add New',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAddOption(
                    icon: Icons.person_add,
                    title: 'Add Client',
                    subtitle: 'Create a new client profile',
                    color: Colors.blue,
                    onTap: () {
                      Get.back();
                      addNewClient();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAddOption(
                    icon: Icons.home,
                    title: 'Add Home',
                    subtitle: 'Create a new home location',
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      addNewHome();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
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

  void addNewHome() {
    // TODO: Implement add home functionality
    Get.snackbar(
      'Coming Soon',
      'Add home functionality will be implemented soon',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void viewClientDetails(Client client) {
    Get.toNamed(Routes.CLIENT_DETAILS, arguments: client);
  }

  void handleClientAction(String action, Client client) {
    switch (action) {
      case 'view':
        viewClientDetails(client);
        break;
      case 'edit':
        Get.toNamed(Routes.EDIT_CLIENT, arguments: client);
        break;
      case 'care':
        Get.toNamed(Routes.QUICK_ACTIONS, arguments: client);
        break;
    }
  }

  void refreshClients() {
    loadClients();
  }

  Future<void> deleteClient(Client client) async {
    try {
      await _databaseService.deleteClient(client.id!);
      await loadClients();
      _errorHandler.showSuccessSnackbar('Client deleted successfully');
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
  }

  // Logging Methods
  void _addLog(String action, String description, String type, {Map<String, dynamic>? additionalData}) {
    // Convert string type to FacilityLogType
    FacilityLogType logType;
    switch (type) {
      case 'clock_in_out':
        logType = FacilityLogType.clockInOut;
        break;
      case 'break':
        logType = FacilityLogType.breakTime;
        break;
      case 'house_note':
        logType = FacilityLogType.houseNote;
        break;
      case 'complaint':
        logType = FacilityLogType.complaint;
        break;
      default:
        logType = FacilityLogType.other;
    }

    // Get homeId from selected home
    int homeId = 0;
    if (selectedHome.value != 'All Homes') {
      final clientWithAddress = clients.firstWhereOrNull(
        (client) => client.address == selectedHome.value
      );
      if (clientWithAddress != null) {
        homeId = clientWithAddress.id!;
      }
    }

    final log = FacilityLog(
      homeId: homeId,
      action: action,
      description: description,
      timestamp: DateTime.now(),
      type: logType,
      additionalData: additionalData,
    );
    
    // In a real app, you would save this to a database
    print('Facility Log: $action - $description at ${_formatDateTime(DateTime.now())}');
  }

  void addLog(String action, String description, String type, {Map<String, dynamic>? additionalData}) {
    _addLog(action, description, type, additionalData: additionalData);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Quick Actions Methods
  void clockInOut() {
    if (isOnShift.value) {
      _clockOut();
    } else {
      _clockIn();
    }
  }

  void _clockIn() {
    isOnShift.value = true;
    clockInTime.value = DateTime.now();
    _addLog(
      'Clock In',
      'Successfully clocked in at ${_formatTime(DateTime.now())}',
      'clock_in_out',
      additionalData: {'time': _formatTime(DateTime.now())},
    );
    _errorHandler.showSuccessSnackbar('Successfully clocked in at ${_formatTime(DateTime.now())}');
  }

  void _clockOut() {
    isOnShift.value = false;
    clockInTime.value = null;
    _addLog(
      'Clock Out',
      'Successfully clocked out at ${_formatTime(DateTime.now())}',
      'clock_in_out',
      additionalData: {'time': _formatTime(DateTime.now())},
    );
    _errorHandler.showSuccessSnackbar('Successfully clocked out at ${_formatTime(DateTime.now())}');
  }

  void startEndBreak() {
    if (isOnBreak.value) {
      _endBreak();
    } else {
      _startBreak();
    }
  }

  void _startBreak() {
    isOnBreak.value = true;
    breakStartTime.value = DateTime.now();
    _addLog(
      'Break Started',
      'Break started at ${_formatTime(DateTime.now())}',
      'break',
      additionalData: {'time': _formatTime(DateTime.now())},
    );
    _errorHandler.showSuccessSnackbar('Break started at ${_formatTime(DateTime.now())}');
  }

  void _endBreak() {
    isOnBreak.value = false;
    breakStartTime.value = null;
    _addLog(
      'Break Ended',
      'Break ended at ${_formatTime(DateTime.now())}',
      'break',
      additionalData: {'time': _formatTime(DateTime.now())},
    );
    _errorHandler.showSuccessSnackbar('Break ended at ${_formatTime(DateTime.now())}');
  }

  void saveHouseNote(String note) {
    if (note.trim().isNotEmpty) {
      _addLog(
        'House Note',
        note,
        'house_note',
        additionalData: {'note': note},
      );
      _errorHandler.showSuccessSnackbar('House note saved successfully');
    } else {
      _errorHandler.showWarningSnackbar('Please enter a note');
    }
  }

  void submitComplaint(String complaint) {
    if (complaint.trim().isNotEmpty) {
      _addLog(
        'Complaint/Concern',
        complaint,
        'complaint',
        additionalData: {'complaint': complaint},
      );
      _errorHandler.showSuccessSnackbar('Complaint submitted successfully');
    } else {
      _errorHandler.showWarningSnackbar('Please describe your complaint');
    }
  }

  void viewFacilityHistory() {
    // Get homeId based on selected home
    int homeId = 0;
    if (selectedHome.value != 'All Homes') {
      // Find a client with this address to get the homeId
      final clientWithAddress = clients.firstWhereOrNull(
        (client) => client.address == selectedHome.value
      );
      if (clientWithAddress != null) {
        homeId = clientWithAddress.id!;
      }
    }
    
    Get.toNamed(Routes.FACILITY_LOGS, arguments: {'homeId': homeId});
  }

  String getCurrentStatus() {
    if (isOnShift.value) {
      return 'On Shift';
    } else {
      return 'Off Shift';
    }
  }

  String getBreakStatus() {
    if (isOnBreak.value) {
      return 'On Break';
    } else {
      return 'Not on break';
    }
  }
} 