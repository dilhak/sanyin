import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/care_log_model.dart';
import '../../client/models/client_model.dart';

class QuickActionsController extends GetxController {
  late Client client;
  String get clientName => client.name;

  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
  }

  void showMedicationActions() {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication,
                color: Colors.green[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medication',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option for $clientName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            _buildActionButton(
              'Given',
              Icons.check_circle,
              Colors.green,
              () => _logMedication(MedicationAction.given),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Refused',
              Icons.cancel,
              Colors.red,
              () => _logMedication(MedicationAction.refused),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void showToiletingActions() {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wc,
                color: Colors.orange[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Toileting',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option for $clientName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            _buildActionButton(
              'Urination',
              Icons.water_drop,
              Colors.blue,
              () => _showUrinationOptions(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Defecation',
              Icons.wc,
              Colors.orange,
              () => _showBowelMovementOptions(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Shower',
              Icons.shower,
              Colors.blue,
              () => _logToileting('shower', 'Shower'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void showHydrationActions() {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_drink,
                color: Colors.blue[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hydration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option for $clientName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            _buildActionButton(
              'Good Intake',
              Icons.check_circle,
              Colors.green,
              () => _logHydration(HydrationType.goodIntake),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Poor Intake',
              Icons.warning,
              Colors.orange,
              () => _logHydration(HydrationType.poorIntake),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Refused',
              Icons.cancel,
              Colors.red,
              () => _logHydration(HydrationType.refused),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void showMealActions() {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.green[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Meals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option for $clientName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            _buildActionButton(
              'Breakfast',
              Icons.wb_sunny,
              Colors.orange,
              () => _showMealOptions(MealType.breakfast),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Lunch',
              Icons.wb_sunny_outlined,
              Colors.yellow,
              () => _showMealOptions(MealType.lunch),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Dinner',
              Icons.nightlight,
              Colors.indigo,
              () => _showMealOptions(MealType.dinner),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Snacks',
              Icons.cake,
              Colors.pink,
              () => _showMealOptions(MealType.snacks),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void showBehaviorActions() {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.purple[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Behavior/Mood',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an option for $clientName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            _buildActionButton(
              'Mood',
              Icons.psychology,
              Colors.purple,
              () => _showMoodOptions(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Activity Level',
              Icons.directions_run,
              Colors.blue,
              () => _showActivityLevelOptions(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Social Interaction',
              Icons.people,
              Colors.green,
              () => _showSocialInteractionOptions(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showBowelMovementOptions() {
    Get.back();
    _showSubOptions('Defecation', [
      'Normal',
      'Constipated',
      'Diarrhea',
      'Incontinent',
    ], (option) => _logToileting('bowel', option));
  }

  void _showUrinationOptions() {
    Get.back();
    _showSubOptions('Urination', [
      'Clear',
      'Light Yellow',
      'Dark Yellow',
      'Bloody',
      'Painful',
      'Frequent',
      'Incontinent',
    ], (option) => _logToileting('urination', option));
  }

  void _showMealOptions(MealType mealType) {
    Get.back();
    _showSubOptions('${mealType.name.toUpperCase()} Intake', [
      'Ate All',
      'Ate Some',
      'Refused',
    ], (option) => _logMeal(mealType, option));
  }

  void _showMoodOptions() {
    Get.back();
    _showSubOptions('Mood', [
      'Happy',
      'Sad',
      'Anxious',
      'Agitated',
      'Calm',
    ], (option) => _logBehavior('mood', option));
  }

  void _showActivityLevelOptions() {
    Get.back();
    _showSubOptions('Activity Level', [
      'Active',
      'Resting',
      'Sleeping',
      'Unresponsive',
    ], (option) => _logBehavior('activity', option));
  }

  void _showSocialInteractionOptions() {
    Get.back();
    _showSubOptions('Social Interaction', [
      'Engaged',
      'Withdrawn',
      'Cooperative',
      'Uncooperative',
    ], (option) => _logBehavior('social', option));
  }

  void _showSubOptions(String title, List<String> options, Function(String) onSelect) {
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
            // Handle bar
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
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            ...options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onSelect(option);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _logMedication(MedicationAction action) {
    Get.back();
    _saveCareLog(CareActivityType.medication, action.name);
  }

  void _logToileting(String type, String option) {
    _saveCareLog(CareActivityType.toileting, type, option);
  }

  void _logHydration(HydrationType type) {
    Get.back();
    _saveCareLog(CareActivityType.hydration, type.name);
  }

  void _logMeal(MealType mealType, String intake) {
    _saveCareLog(CareActivityType.meal, mealType.name, intake);
  }

  void _logBehavior(String type, String option) {
    _saveCareLog(CareActivityType.behavior, type, option);
  }

  void _saveCareLog(CareActivityType activityType, String action, [String? subAction]) {
    // TODO: Save to local database
    Get.snackbar(
      'Success',
      'Care activity logged successfully',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void takePhoto() {
    // TODO: Implement camera functionality
    Get.snackbar(
      'Info',
      'Camera functionality coming soon',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void showNoteDialog() {
    final TextEditingController noteController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your notes here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                Get.back();
                _saveCareLog(CareActivityType.note, 'general', noteController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 