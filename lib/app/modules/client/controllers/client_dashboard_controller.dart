import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';

class ClientDashboardController extends GetxController {
  final RxList<Client> clients = <Client>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  Future<void> loadClients() async {
    isLoading.value = true;
    try {
      // TODO: Load clients from local database
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      clients.value = [
        Client(
          id: 1,
          name: 'John Smith',
          phoneNumber: '+1-555-0123',
          address: '123 Main St, City, State',
          emergencyContact: 'Jane Smith +1-555-0124',
          medicalNotes: 'Diabetic, requires insulin',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
        Client(
          id: 2,
          name: 'Mary Johnson',
          phoneNumber: '+1-555-0125',
          address: '456 Oak Ave, City, State',
          emergencyContact: 'Bob Johnson +1-555-0126',
          medicalNotes: 'Heart condition, low sodium diet',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addNewClient() {
    Get.toNamed('/client/add');
  }

  void viewClientDetails(Client client) {
    Get.toNamed('/client/details', arguments: client);
  }

  void handleClientAction(String action, Client client) {
    switch (action) {
      case 'view':
        viewClientDetails(client);
        break;
      case 'edit':
        Get.toNamed('/client/edit', arguments: client);
        break;
      case 'care':
        Get.toNamed(Routes.QUICK_ACTIONS, arguments: client);
        break;
    }
  }

  void refreshClients() {
    loadClients();
  }
} 