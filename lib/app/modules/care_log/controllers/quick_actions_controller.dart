import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/care_log_model.dart';
import '../../client/models/client_model.dart';
import '../../../services/database_service.dart';
import '../controllers/care_log_history_controller.dart';
import '../../../widgets/universal_popup.dart';

class QuickActionsController extends GetxController {
  late Client client;
  String get clientName => client.name;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
  }

  void showMedicationActions() {
    UniversalPopup.showInputDialog(
      title: 'Medication',
      hintText: 'Enter medicine name...',
      onConfirm: (medicineName) {
        UniversalPopup.show(
          title: 'Medication',
          subtitle: 'Select action for $medicineName',
          icon: Icons.medication,
          color: Colors.green,
          actions: [
            PopupAction(
              title: 'Given',
              icon: Icons.check_circle,
              color: Colors.green,
              onTap: () => _logMedication(MedicationAction.given, medicineName),
            ),
            PopupAction(
              title: 'Refused',
              icon: Icons.cancel,
              color: Colors.red,
              onTap: () => _logMedication(MedicationAction.refused, medicineName),
            ),
          ],
        );
      },
    );
  }

  void showToiletingActions() {
    UniversalPopup.show(
      title: 'Toileting',
      subtitle: 'Select an option for $clientName',
      icon: Icons.wc,
      color: Colors.orange,
      actions: [
        PopupAction(
          title: 'Urination',
          icon: Icons.water_drop,
          color: Colors.blue,
          onTap: () => _showUrinationOptions(),
        ),
        PopupAction(
          title: 'Defecation',
          icon: Icons.wc,
          color: Colors.orange,
          onTap: () => _showBowelMovementOptions(),
        ),
        PopupAction(
          title: 'Shower',
          icon: Icons.shower,
          color: Colors.blue,
          onTap: () => _logToileting('shower', 'Shower'),
        ),
      ],
    );
  }

  void showHydrationActions() {
    UniversalPopup.show(
      title: 'Hydration',
      subtitle: 'Select an option for $clientName',
      icon: Icons.local_drink,
      color: Colors.blue,
      actions: [
        PopupAction(
          title: 'Good Intake',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () => _logHydration(HydrationType.goodIntake),
        ),
        PopupAction(
          title: 'Poor Intake',
          icon: Icons.warning,
          color: Colors.orange,
          onTap: () => _logHydration(HydrationType.poorIntake),
        ),
        PopupAction(
          title: 'Refused',
          icon: Icons.cancel,
          color: Colors.red,
          onTap: () => _logHydration(HydrationType.refused),
        ),
      ],
    );
  }

  void showMealActions() {
    UniversalPopup.show(
      title: 'Meals',
      subtitle: 'Select an option for $clientName',
      icon: Icons.restaurant,
      color: Colors.green,
      actions: [
        PopupAction(
          title: 'Breakfast',
          icon: Icons.wb_sunny,
          color: Colors.orange,
          onTap: () => _showMealOptions(MealType.breakfast),
        ),
        PopupAction(
          title: 'Lunch',
          icon: Icons.wb_sunny_outlined,
          color: Colors.yellow,
          onTap: () => _showMealOptions(MealType.lunch),
        ),
        PopupAction(
          title: 'Dinner',
          icon: Icons.nightlight,
          color: Colors.indigo,
          onTap: () => _showMealOptions(MealType.dinner),
        ),
        PopupAction(
          title: 'Snacks',
          icon: Icons.cake,
          color: Colors.pink,
          onTap: () => _showMealOptions(MealType.snacks),
        ),
      ],
    );
  }

  void showBehaviorActions() {
    UniversalPopup.show(
      title: 'Behavior/Mood',
      subtitle: 'Select an option for $clientName',
      icon: Icons.psychology,
      color: Colors.purple,
      actions: [
        PopupAction(
          title: 'Mood',
          icon: Icons.psychology,
          color: Colors.purple,
          onTap: () => _showMoodOptions(),
        ),
        PopupAction(
          title: 'Activity Level',
          icon: Icons.directions_run,
          color: Colors.blue,
          onTap: () => _showActivityLevelOptions(),
        ),
        PopupAction(
          title: 'Social Interaction',
          icon: Icons.people,
          color: Colors.green,
          onTap: () => _showSocialInteractionOptions(),
        ),
      ],
    );
  }

  void _showBowelMovementOptions() {
    Get.back();
    UniversalPopup.showSubOptions(
      title: 'Defecation',
      options: [
        'Normal',
        'Constipated',
        'Diarrhea',
        'Incontinent',
      ],
      onSelect: (option) => _logToileting('bowel', option),
    );
  }

  void _showUrinationOptions() {
    Get.back();
    UniversalPopup.showSubOptions(
      title: 'Urination',
      options: [
        'Clear',
        'Light Yellow',
        'Dark Yellow',
        'Bloody',
        'Painful',
        'Frequent',
        'Incontinent',
      ],
      onSelect: (option) => _logToileting('urination', option),
    );
  }

  void _showMealOptions(MealType mealType) {
    Get.back();
    UniversalPopup.showSubOptions(
      title: '${mealType.name.toUpperCase()} Intake',
      options: [
        'Ate All',
        'Ate Some',
        'Refused',
      ],
      onSelect: (option) => _logMeal(mealType, option),
    );
  }

  void _showMoodOptions() {
    Get.back();
    UniversalPopup.showSubOptions(
      title: 'Mood',
      options: [
        'Happy',
        'Sad',
        'Anxious',
        'Agitated',
        'Calm',
      ],
      onSelect: (option) => _logBehavior('mood', option),
    );
  }

  void _showActivityLevelOptions() {
    Get.back();
    UniversalPopup.showSubOptions(
      title: 'Activity Level',
      options: [
        'Active',
        'Resting',
        'Sleeping',
        'Unresponsive',
      ],
      onSelect: (option) => _logBehavior('activity', option),
    );
  }

  void _showSocialInteractionOptions() {
    Get.back();
    UniversalPopup.showSubOptions(
      title: 'Social Interaction',
      options: [
        'Engaged',
        'Withdrawn',
        'Cooperative',
        'Uncooperative',
      ],
      onSelect: (option) => _logBehavior('social', option),
    );
  }

  void _logMedication(MedicationAction action, String medicineName) {
    Get.back();
    _saveCareLog(
      CareActivityType.medication,
      action.name,
      medicineName,
      'Medicine: $medicineName - ${action.name}',
    );
  }

  void _logToileting(String type, String option) {
    Get.back();
    _saveCareLog(
      CareActivityType.toileting,
      type,
      option,
      'Toileting: $type - $option',
    );
  }

  void _logHydration(HydrationType type) {
    Get.back();
    _saveCareLog(
      CareActivityType.hydration,
      type.name,
      null,
      'Hydration: ${type.name}',
    );
  }

  void _logMeal(MealType mealType, String intake) {
    Get.back();
    _saveCareLog(
      CareActivityType.meal,
      mealType.name,
      intake,
      'Meal: ${mealType.name} - $intake',
    );
  }

  void _logBehavior(String type, String option) {
    Get.back();
    _saveCareLog(
      CareActivityType.behavior,
      type,
      option,
      'Behavior: $type - $option',
    );
  }

  void _saveCareLog(CareActivityType activityType, String action, [String? subAction, String? details]) async {
    try {
      final careLog = CareLog(
        clientId: client.id!,
        activityType: activityType,
        action: action,
        subAction: subAction,
        details: details,
        timestamp: DateTime.now(),
      );

      await _databaseService.insertCareLog(careLog);
      
      // Refresh care log history if it exists
      try {
        final careLogHistoryController = Get.find<CareLogHistoryController>();
        await careLogHistoryController.loadCareLogs();
      } catch (e) {
        // Care log history controller not found, that's okay
      }
      
      Get.snackbar(
        'Success',
        'Care activity logged successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log care activity: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void takePhoto() {
    Get.toNamed('/care/photo', arguments: client);
  }

  void showNoteDialog() {
    UniversalPopup.showInputDialog(
      title: 'Add Note',
      hintText: 'Enter your notes here...',
      maxLines: 3,
      onConfirm: (note) {
        _saveCareLog(
          CareActivityType.note,
          'general',
          note,
          'Note: $note',
        );
      },
    );
  }
} 