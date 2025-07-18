import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/universal_popup.dart';
import '../../care_log/models/care_log_model.dart';
import '../../../services/database_service.dart';

class ClientDetailsController extends GetxController {
  late Client client;
  final DatabaseService _databaseService = DatabaseService();
  
  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
  }

  void showMedicationActions() {
    UniversalPopup.show(
      title: 'Medication',
      subtitle: 'Select action for medication',
      icon: Icons.medication,
      color: Colors.green,
      actions: [
        PopupAction(
          title: 'Given',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () => _showMedicationInput(MedicationAction.given),
        ),
        PopupAction(
          title: 'Refused',
          icon: Icons.cancel,
          color: Colors.red,
          onTap: () => _showMedicationInput(MedicationAction.refused),
        ),
        PopupAction(
          title: 'Add Multiple',
          icon: Icons.add_circle,
          color: Colors.blue,
          onTap: () => _showMultipleMedicationInput(),
        ),
      ],
    );
  }

  void showToiletingActions() {
    UniversalPopup.show(
      title: 'Toileting',
      subtitle: 'Select an option for ${client.name}',
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
      subtitle: 'Select an option for ${client.name}',
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
      subtitle: 'Select an option for ${client.name}',
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
      subtitle: 'Select an option for ${client.name}',
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

  void showPainActions() {
    UniversalPopup.show(
      title: 'Pain & Discomfort',
      subtitle: 'Select pain assessment for ${client.name}',
      icon: Icons.sick,
      color: Colors.red,
      actions: [
        PopupAction(
          title: 'Pain Reported',
          icon: Icons.report,
          color: Colors.orange,
          onTap: () => _logPain('reported', 'Pain reported'),
        ),
        PopupAction(
          title: 'Pain Meds Given',
          icon: Icons.medication,
          color: Colors.green,
          onTap: () => _logPain('meds_given', 'Pain medication given'),
        ),
        PopupAction(
          title: 'Nonverbal Signs',
          icon: Icons.visibility,
          color: Colors.red,
          onTap: () => _logPain('nonverbal', 'Nonverbal signs of pain observed'),
        ),
        PopupAction(
          title: 'Pain Relieved',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () => _logPain('relieved', 'Pain relieved'),
        ),
        PopupAction(
          title: 'Pain Unresolved',
          icon: Icons.cancel,
          color: Colors.red,
          onTap: () => _logPain('unresolved', 'Pain unresolved'),
        ),
      ],
    );
  }

  void showVitalsForm() {
    Get.back();
    _showVitalsInputDialog();
  }

  void showLocationActions() {
    UniversalPopup.show(
      title: 'Location & Presence',
      subtitle: 'Where is ${client.name}?',
      icon: Icons.location_on,
      color: Colors.teal,
      actions: [
        PopupAction(
          title: 'In Room',
          icon: Icons.bed,
          color: Colors.blue,
          onTap: () => _logLocation('in_room', 'In Room'),
        ),
        PopupAction(
          title: 'Common Area',
          icon: Icons.tv,
          color: Colors.green,
          onTap: () => _logLocation('common_area', 'In Facility - Common Area'),
        ),
        PopupAction(
          title: 'Activity Room',
          icon: Icons.sports_esports,
          color: Colors.orange,
          onTap: () => _logLocation('activity_room', 'In Facility - Activity Room'),
        ),
        PopupAction(
          title: 'Courtyard',
          icon: Icons.park,
          color: Colors.green,
          onTap: () => _logLocation('courtyard', 'Outside in Courtyard'),
        ),
        PopupAction(
          title: 'Out - Accompanied',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => _logLocation('out_accompanied', 'Out of Facility - Accompanied'),
        ),
        PopupAction(
          title: 'Out - Unaccompanied',
          icon: Icons.person,
          color: Colors.orange,
          onTap: () => _logLocation('out_unaccompanied', 'Out of Facility - Unaccompanied'),
        ),
        PopupAction(
          title: 'Other Company Site',
          icon: Icons.business,
          color: Colors.grey,
          onTap: () => _logLocation('other_company', 'Out of Facility - Other Company Site'),
        ),
        PopupAction(
          title: 'Therapeutic Leave',
          icon: Icons.beach_access,
          color: Colors.cyan,
          onTap: () => _logLocation('therapeutic_leave', 'On Therapeutic Leave'),
        ),
        PopupAction(
          title: 'Medical Appointment',
          icon: Icons.medical_services,
          color: Colors.purple,
          onTap: () => _logLocation('medical_appointment', 'At Medical Appointment'),
        ),
        PopupAction(
          title: 'Hospitalized',
          icon: Icons.local_hospital,
          color: Colors.red,
          onTap: () => _logLocation('hospitalized', 'Hospitalized'),
        ),
        PopupAction(
          title: 'Returned from Leave',
          icon: Icons.home,
          color: Colors.green,
          onTap: () => _logLocation('returned_leave', 'Returned from Leave'),
        ),
        PopupAction(
          title: 'Bedbound',
          icon: Icons.bed,
          color: Colors.grey,
          onTap: () => _logLocation('bedbound', 'Bedbound'),
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

  void _logPain(String action, String details) {
    Get.back();
    _saveCareLog(
      CareActivityType.pain,
      action,
      null,
      'Pain: $details',
    );
  }

  void _showVitalsInputDialog() {
    final TextEditingController bpController = TextEditingController();
    final TextEditingController pulseController = TextEditingController();
    final TextEditingController tempController = TextEditingController();
    final TextEditingController respController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Vitals Assessment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bpController,
                decoration: const InputDecoration(
                  labelText: 'Blood Pressure (e.g., 120/80)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pulseController,
                decoration: const InputDecoration(
                  labelText: 'Pulse (beats per minute)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tempController,
                decoration: const InputDecoration(
                  labelText: 'Temperature (°F) - Optional',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: respController,
                decoration: const InputDecoration(
                  labelText: 'Respirations (per minute) - Optional',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Call Nurse If:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• BP: Systolic >150 or <90, Diastolic >90 or <50\n'
                      '• Pulse: >100 or <50\n'
                      '• Temp: >100°F or <95°F\n'
                      '• Respirations: >24 or <12',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final bp = bpController.text.trim();
              final pulse = pulseController.text.trim();
              final temp = tempController.text.trim();
              final resp = respController.text.trim();
              
              if (bp.isEmpty && pulse.isEmpty && temp.isEmpty && resp.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter at least one vital sign',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }
              
              // Validate and check for nurse call thresholds
              final warnings = <String>[];
              
              if (bp.isNotEmpty) {
                final bpParts = bp.split('/');
                if (bpParts.length == 2) {
                  final systolic = int.tryParse(bpParts[0]);
                  final diastolic = int.tryParse(bpParts[1]);
                  if (systolic != null && diastolic != null) {
                    if (systolic > 150 || systolic < 90 || diastolic > 90 || diastolic < 50) {
                      warnings.add('Blood Pressure: ${systolic}/${diastolic}');
                    }
                  }
                }
              }
              
              if (pulse.isNotEmpty) {
                final pulseValue = int.tryParse(pulse);
                if (pulseValue != null && (pulseValue > 100 || pulseValue < 50)) {
                  warnings.add('Pulse: $pulseValue');
                }
              }
              
              if (temp.isNotEmpty) {
                final tempValue = double.tryParse(temp);
                if (tempValue != null && (tempValue > 100 || tempValue < 95)) {
                  warnings.add('Temperature: ${tempValue}°F');
                }
              }
              
              if (resp.isNotEmpty) {
                final respValue = int.tryParse(resp);
                if (respValue != null && (respValue > 24 || respValue < 12)) {
                  warnings.add('Respirations: $respValue');
                }
              }
              
              Get.back();
              
              // Log vitals
              _saveCareLog(
                CareActivityType.vitals,
                'assessment',
                null,
                'Vitals: BP: $bp, Pulse: $pulse, Temp: $temp, Resp: $resp',
              );
              
              // Show warnings if any
              if (warnings.isNotEmpty) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('⚠️ Call Nurse'),
                    content: Text(
                      'The following vital signs are outside normal ranges:\n\n'
                      '${warnings.join('\n')}\n\n'
                      'Please contact a nurse immediately.',
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _logLocation(String action, String details) {
    Get.back();
    _saveCareLog(
      CareActivityType.location,
      action,
      null,
      'Location: $details',
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

  void _showMedicationInput(MedicationAction action) {
    Get.back();
    UniversalPopup.showInputDialog(
      title: 'Medication ${action.name}',
      hintText: 'Enter medicine name...',
      onConfirm: (medicineName) {
        _logMedication(action, medicineName);
      },
    );
  }

  void _showMultipleMedicationInput() {
    Get.back();
    final List<String> medications = [];
    
    UniversalPopup.showInputDialog(
      title: 'Add Multiple Medications',
      hintText: 'Enter medicine name...',
      onConfirm: (medicineName) {
        if (medicineName.isNotEmpty) {
          medications.add(medicineName);
          _showMultipleMedicationList(medications);
        }
      },
    );
  }

  void _showMultipleMedicationList(List<String> medications) {
    UniversalPopup.show(
      title: 'Medications Added',
      subtitle: 'Select action for medications',
      icon: Icons.medication,
      color: Colors.green,
      actions: [
        PopupAction(
          title: 'All Given',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () => _logMultipleMedications(medications, MedicationAction.given),
        ),
        PopupAction(
          title: 'All Refused',
          icon: Icons.cancel,
          color: Colors.red,
          onTap: () => _logMultipleMedications(medications, MedicationAction.refused),
        ),
        PopupAction(
          title: 'Add More',
          icon: Icons.add_circle,
          color: Colors.blue,
          onTap: () => _showMultipleMedicationInput(),
        ),
      ],
    );
  }

  void _logMultipleMedications(List<String> medications, MedicationAction action) {
    Get.back();
    for (String medicine in medications) {
      _logMedication(action, medicine);
    }
    Get.snackbar(
      'Success',
      '${medications.length} medications logged as ${action.name}',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
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

  void openCareHistory() {
    Get.toNamed(Routes.CARE_LOG_HISTORY, arguments: client);
  }

  void editClient() {
    Get.toNamed('/client/edit', arguments: client);
  }

  void takePhoto() {
    Get.toNamed(Routes.PHOTO_CAPTURE, arguments: client);
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

  void goBack() {
    Get.back();
  }
} 