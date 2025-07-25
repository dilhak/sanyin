import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';
import '../../facility_logs/models/facility_log_model.dart';
import '../../../widgets/enhanced_text_field.dart';
import '../../../services/keyboard_service.dart';
import '../../../utils/spacing_constants.dart';

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
      await _updateHomesList();
      _filterClients();
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateHomesList() async {
    final homeSet = <String>{'All Homes'};
    
    // Add homes from existing clients
    for (final client in clients) {
      if (client.address != null && client.address!.isNotEmpty) {
        homeSet.add(client.address!);
      }
    }
    
    // Load homes from database
    try {
      final dbHomes = await _databaseService.getAllHomes();
      for (final home in dbHomes) {
        homeSet.add(home);
      }
    } catch (e) {
      // If database fails, continue with client homes only
      print('Failed to load homes from database: $e');
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
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController emergencyController = TextEditingController();
    final TextEditingController medicalNotesController = TextEditingController();
    
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode phoneFocusNode = FocusNode();
    final FocusNode addressFocusNode = FocusNode();
    final FocusNode emergencyFocusNode = FocusNode();
    final FocusNode medicalNotesFocusNode = FocusNode();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          padding: SpacingConstants.dialogPadding,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add client icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                Spacing.lg,
                // Title
                const Text(
                  'Add New Client',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacing.sm,
                Text(
                  'Enter client information to create a new profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacing.lg,
                // Name field
                EnhancedTextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  hintText: 'Client Name',
                  prefixIcon: Icons.person,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => phoneFocusNode.requestFocus(),
                ),
                Spacing.md,
                // Phone field
                EnhancedTextField(
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  hintText: 'Phone Number (Optional)',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => addressFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                // Home dropdown field
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: addressController.text.isNotEmpty ? addressController.text : null,
                      decoration: InputDecoration(
                        hintText: 'Select Home (Optional)',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.home,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Select a home...'),
                        ),
                        ...homes.map((home) => DropdownMenuItem<String>(
                          value: home,
                          child: Text(home),
                        )),
                      ],
                      onChanged: (String? value) {
                        addressController.text = value ?? '';
                      },
                      dropdownColor: Colors.white,
                      icon: const SizedBox.shrink(),
                      isExpanded: true,
                    ),
                  ),
                ),
                Spacing.md,
                // Emergency contact field
                EnhancedTextField(
                  controller: emergencyController,
                  focusNode: emergencyFocusNode,
                  hintText: 'Emergency Contact (Optional)',
                  prefixIcon: Icons.emergency,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => medicalNotesFocusNode.requestFocus(),
                ),
                Spacing.md,
                // Medical notes field
                EnhancedTextField(
                  controller: medicalNotesController,
                  focusNode: medicalNotesFocusNode,
                  hintText: 'Medical Notes (Optional)',
                  prefixIcon: Icons.medical_services,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => KeyboardService.to.dismissKeyboard(),
                ),
                Spacing.lg,
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
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isNotEmpty) {
                              Get.back();
                              await _addNewClient(
                                name: name,
                                phoneNumber: phoneController.text.trim(),
                                address: addressController.text.trim(),
                                emergencyContact: emergencyController.text.trim(),
                                medicalNotes: medicalNotesController.text.trim(),
                              );
                            } else {
                              _errorHandler.showWarningSnackbar('Please enter a client name');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Client',
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
      ),
    );
  }

  Future<void> _addNewClient({
    required String name,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? medicalNotes,
  }) async {
    try {
      final client = Client(
        name: name,
        phoneNumber: phoneNumber?.isNotEmpty == true ? phoneNumber : null,
        address: address?.isNotEmpty == true ? address : null,
        emergencyContact: emergencyContact?.isNotEmpty == true ? emergencyContact : null,
        medicalNotes: medicalNotes?.isNotEmpty == true ? medicalNotes : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

             final id = await _databaseService.insertClient(client);

      // Reload clients to update the list
      await loadClients();
      
      // Show success message
      _errorHandler.showSuccessSnackbar('Client "$name" added successfully');
      
      // Log the action
      addLog(
        'Client Added',
        'Added new client: $name',
        'other',
        additionalData: {'clientName': name},
      );
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
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
    final TextEditingController homeNameController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.7,
          ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add home icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Add New Home',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the name of the new home location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Home name input field
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: homeNameController,
                    enableInteractiveSelection: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g., Maple Street Home, Oak Avenue Facility',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.home,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
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
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final homeName = homeNameController.text.trim();
                            if (homeName.isNotEmpty) {
                              Get.back();
                              await _addNewHome(homeName);
                            } else {
                              _errorHandler.showWarningSnackbar('Please enter a home name');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Home',
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
      ),
    );
  }

  Future<void> _addNewHome(String homeName) async {
    // Check if home already exists
    if (homes.contains(homeName)) {
      _errorHandler.showWarningSnackbar('Home "$homeName" already exists');
      return;
    }

    try {
      // Save home to database
      await _databaseService.insertHome(homeName);
      
      // Add the new home to the list
      homes.add(homeName);
      homes.sort(); // Keep the list sorted
      
      // Show success message
      _errorHandler.showSuccessSnackbar('Home "$homeName" added successfully');
      
      // Log the action
      addLog(
        'Home Added',
        'Added new home: $homeName',
        'other',
        additionalData: {'homeName': homeName},
      );
    } catch (e) {
      _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
    }
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
      _errorHandler.showSuccessSnackbar('Client "${client.name}" deleted successfully');
      
      // Log the action
      addLog(
        'Client Deleted',
        'Deleted client: ${client.name}',
        'other',
        additionalData: {'clientName': client.name},
      );
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

  void editClient(Client client) {
    Get.toNamed(Routes.EDIT_CLIENT, arguments: client);
  }
} 