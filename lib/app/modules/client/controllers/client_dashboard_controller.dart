import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/database_service.dart';
import '../../../core/error_handler.dart';

class ClientDashboardController extends GetxController {
  final RxList<Client> clients = <Client>[].obs;
  final RxList<Client> filteredClients = <Client>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedHome = 'All Homes'.obs;
  final RxList<String> homes = <String>['All Homes'].obs;
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();

  @override
  void onInit() {
    super.onInit();
    loadClients();
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
} 