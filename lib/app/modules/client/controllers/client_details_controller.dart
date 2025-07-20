import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/universal_popup.dart';
import '../../care_log/models/care_log_model.dart';
import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';
import '../../../models/reminder_model.dart';
import '../views/reminder_management_view.dart';
import '../../../widgets/reminder_dialog.dart';
import '../../../widgets/responsive_bottom_drawer.dart';

class ClientDetailsController extends GetxController {
  late Client client;
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  final RxList<Reminder> reminders = <Reminder>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final loadedReminders = await _databaseService.getRemindersForClient(client.id!);
      reminders.assignAll(loadedReminders);
    } catch (e) {
      // Handle database errors gracefully
      print('Error loading reminders: $e');
      reminders.clear();
    }
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
    ResponsiveBottomDrawer.showActions(
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
          title: 'Bedroom',
          icon: Icons.bed,
          color: Colors.blue,
          onTap: () => _logLocation('bedroom', 'Bedroom'),
        ),
        PopupAction(
          title: 'Common Area',
          icon: Icons.tv,
          color: Colors.green,
          onTap: () => _logLocation('common_area', 'Common Area'),
        ),
        PopupAction(
          title: 'Outside - Alone',
          icon: Icons.person,
          color: Colors.orange,
          onTap: () => _logLocation('outside_alone', 'Outside - Alone'),
        ),
        PopupAction(
          title: 'Outside - DSP',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => _logLocation('outside_dsp', 'Outside - DSP'),
        ),
        PopupAction(
          title: 'With Family',
          icon: Icons.family_restroom,
          color: Colors.purple,
          onTap: () => _logLocation('with_family', 'With Family'),
        ),
        PopupAction(
          title: 'Out of Facility',
          icon: Icons.business,
          color: Colors.grey,
          onTap: () => _logLocation('out_of_facility', 'Out of Facility'),
        ),
        PopupAction(
          title: 'Hospital / ER',
          icon: Icons.local_hospital,
          color: Colors.red,
          onTap: () => _logLocation('hospital_er', 'Hospital / ER'),
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
    final TextEditingController systolicController = TextEditingController();
    final TextEditingController diastolicController = TextEditingController();
    final TextEditingController pulseController = TextEditingController();
    final TextEditingController tempController = TextEditingController();
    final TextEditingController respController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController oxygenController = TextEditingController();
    
    ResponsiveBottomDrawer.show(
      title: 'Vitals Assessment',
      subtitle: 'Enter vital signs for ${client.name}',
      icon: Icons.favorite,
      color: Colors.pink[600]!,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Blood Pressure - Split into two fields
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: systolicController,
                            decoration: InputDecoration(
                              labelText: 'Systolic',
                              hintText: '120',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.pink[600]!),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: diastolicController,
                            decoration: InputDecoration(
                              labelText: 'Diastolic',
                              hintText: '80',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.pink[600]!),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: pulseController,
                        decoration: InputDecoration(
                          labelText: 'Pulse (beats per minute)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: tempController,
                        decoration: InputDecoration(
                          labelText: 'Temperature (°F) - Optional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: respController,
                        decoration: InputDecoration(
                          labelText: 'Respirations (per minute) - Optional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Weight field
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (lbs) - Optional',
                          hintText: '150',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Blood Oxygen field
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: oxygenController,
                        decoration: InputDecoration(
                          labelText: 'Blood Oxygen (%) - Optional',
                          hintText: '98',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Call Nurse If:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• BP: Systolic >150 or <90, Diastolic >90 or <50\n'
                            '• Pulse: >100 or <50\n'
                            '• Temp: >100°F or <95°F\n'
                            '• Respirations: >24 or <12\n'
                            '• Blood Oxygen: <95%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Action buttons - Raised up
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final systolic = systolicController.text.trim();
                      final diastolic = diastolicController.text.trim();
                      final pulse = pulseController.text.trim();
                      final temp = tempController.text.trim();
                      final resp = respController.text.trim();
                      final weight = weightController.text.trim();
                      final oxygen = oxygenController.text.trim();
                      
                      if (systolic.isEmpty && diastolic.isEmpty && pulse.isEmpty && temp.isEmpty && resp.isEmpty && weight.isEmpty && oxygen.isEmpty) {
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
                      
                      if (systolic.isNotEmpty && diastolic.isNotEmpty) {
                        final systolicValue = int.tryParse(systolic);
                        final diastolicValue = int.tryParse(diastolic);
                        if (systolicValue != null && diastolicValue != null) {
                          if (systolicValue > 150 || systolicValue < 90 || diastolicValue > 90 || diastolicValue < 50) {
                            warnings.add('Blood Pressure: $systolicValue/$diastolicValue');
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
                          warnings.add('Temperature: $tempValue°F');
                        }
                      }
                      
                      if (resp.isNotEmpty) {
                        final respValue = int.tryParse(resp);
                        if (respValue != null && (respValue > 24 || respValue < 12)) {
                          warnings.add('Respirations: $respValue');
                        }
                      }
                      
                      if (oxygen.isNotEmpty) {
                        final oxygenValue = int.tryParse(oxygen);
                        if (oxygenValue != null && oxygenValue < 95) {
                          warnings.add('Blood Oxygen: $oxygenValue%');
                        }
                      }
                      
                      Get.back();
                      
                      // Log vitals
                      final bp = systolic.isNotEmpty && diastolic.isNotEmpty ? '$systolic/$diastolic' : '';
                      _saveCareLog(
                        CareActivityType.vitals,
                        'assessment',
                        null,
                        'Vitals: BP: $bp, Pulse: $pulse, Temp: $temp, Resp: $resp, Weight: $weight lbs, O2: $oxygen%',
                      );
                      
                      // Show warnings if any
                      if (warnings.isNotEmpty) {
                        _showNurseCallWarning(warnings);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNurseCallWarning(List<String> warnings) {
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
            // Warning icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning,
                color: Colors.red[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Call Nurse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Abnormal vital signs detected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Warning details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The following vital signs are outside normal ranges:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  Text(
                    'Please contact a nurse immediately.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
    Get.toNamed(Routes.EDIT_CLIENT, arguments: client);
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

  // Reminder management methods
  void showReminderManagement() {
    Get.to(() => const ReminderManagementView());
  }

  void showAddReminderDialog() {
    ReminderDialog.show(
      title: 'Add Reminder',
      clientName: client.name,
      onConfirm: (title, description, scheduledTime) async {
        await _addReminder(title, description, scheduledTime);
      },
    );
  }

  Future<void> _addReminder(String title, String description, DateTime scheduledTime) async {
    // Validate inputs
    if (title.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reminder title',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (description.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reminder description',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      Get.snackbar(
        'Error',
        'Please select a future date and time',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      final reminder = Reminder(
        clientId: client.id!,
        title: title.trim(),
        description: description.trim(),
        scheduledTime: scheduledTime,
      );

      final id = await _databaseService.insertReminder(reminder);
      final savedReminder = Reminder(
        id: id,
        clientId: client.id!,
        title: title.trim(),
        description: description.trim(),
        scheduledTime: scheduledTime,
      );

      await _notificationService.scheduleReminder(savedReminder);
      await _loadReminders();

      Get.snackbar(
        'Success',
        'Reminder added successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add reminder: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void editReminder(Reminder reminder) {
    ReminderDialog.show(
      title: 'Edit Reminder',
      clientName: client.name,
      initialTitle: reminder.title,
      initialDescription: reminder.description,
      initialDateTime: reminder.scheduledTime,
      onConfirm: (title, description, scheduledTime) async {
        await _updateReminder(reminder, title, description, scheduledTime);
      },
    );
  }

  Future<void> _updateReminder(Reminder reminder, String title, String description, DateTime scheduledTime) async {
    // Validate inputs
    if (title.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reminder title',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (description.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reminder description',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      Get.snackbar(
        'Error',
        'Please select a future date and time',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      final updatedReminder = Reminder(
        id: reminder.id,
        clientId: client.id!,
        title: title.trim(),
        description: description.trim(),
        scheduledTime: scheduledTime,
        isActive: reminder.isActive,
        frequency: reminder.frequency,
        createdAt: reminder.createdAt,
      );

      await _databaseService.updateReminder(updatedReminder);
      await _notificationService.cancelReminder(reminder.id!);
      await _notificationService.scheduleReminder(updatedReminder);
      await _loadReminders();

      Get.snackbar(
        'Success',
        'Reminder updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update reminder: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> toggleReminder(Reminder reminder) async {
    try {
      final updatedReminder = Reminder(
        id: reminder.id,
        clientId: client.id!,
        title: reminder.title,
        description: reminder.description,
        scheduledTime: reminder.scheduledTime,
        isActive: !reminder.isActive,
        frequency: reminder.frequency,
        createdAt: reminder.createdAt,
      );

      await _databaseService.updateReminder(updatedReminder);
      
      if (updatedReminder.isActive) {
        await _notificationService.scheduleReminder(updatedReminder);
      } else {
        await _notificationService.cancelReminder(reminder.id!);
      }
      
      await _loadReminders();

      Get.snackbar(
        'Success',
        'Reminder ${updatedReminder.isActive ? 'enabled' : 'disabled'}',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle reminder: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await _databaseService.deleteReminder(reminder.id!);
                await _notificationService.cancelReminder(reminder.id!);
                await _loadReminders();

                Get.snackbar(
                  'Success',
                  'Reminder deleted successfully',
                  backgroundColor: Colors.green[100],
                  colorText: Colors.green[800],
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete reminder: $e',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 