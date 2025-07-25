import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'responsive_bottom_drawer.dart';
import 'enhanced_text_field.dart';
import '../services/keyboard_service.dart';

class ReminderDialog {
  static void show({
    required String title,
    required String clientName,
    required Function(String title, String description, DateTime scheduledTime) onConfirm,
    String? initialTitle,
    String? initialDescription,
    DateTime? initialDateTime,
  }) {
    final titleController = TextEditingController(text: initialTitle ?? '');
    final descriptionController = TextEditingController(text: initialDescription ?? '');
    DateTime selectedDateTime = initialDateTime ?? DateTime.now().add(const Duration(hours: 1));

    ResponsiveBottomDrawer.show(
      title: title,
      subtitle: 'Set reminder for $clientName',
      icon: Icons.notifications,
      color: Colors.orange[600]!,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title field
                        EnhancedTextField(
                          controller: titleController,
                          labelText: 'Reminder Title',
                          hintText: 'e.g., Medication reminder',
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => KeyboardService.to.focusNextField(context),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        // Description field
                        EnhancedTextField(
                          controller: descriptionController,
                          labelText: 'Description',
                          hintText: 'e.g., Give medication to $clientName',
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => KeyboardService.to.dismissKeyboard(),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        // Date and Time selection
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              children: [
                                // Date selection
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDateTime,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          selectedDateTime = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            selectedDateTime.hour,
                                            selectedDateTime.minute,
                                          );
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.calendar_today, color: Colors.blue[600], size: 20),
                                        ),
                                        title: const Text(
                                          'Date',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          '${selectedDateTime.month}/${selectedDateTime.day}/${selectedDateTime.year}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                        ),
                                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Time selection
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                                      );
                                      if (time != null) {
                                        setState(() {
                                          selectedDateTime = DateTime(
                                            selectedDateTime.year,
                                            selectedDateTime.month,
                                            selectedDateTime.day,
                                            time.hour,
                                            time.minute,
                                          );
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.access_time, color: Colors.blue[600], size: 20),
                                        ),
                                        title: const Text(
                                          'Time',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          '${selectedDateTime.hour.toString().padLeft(2, '0')}:'
                                          '${selectedDateTime.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                        ),
                                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                StatefulBuilder(
                  builder: (context, setState) {
                    final isValid = titleController.text.isNotEmpty && descriptionController.text.isNotEmpty;
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isValid ? () {
                                  Get.back();
                                  onConfirm(
                                    titleController.text,
                                    descriptionController.text,
                                    selectedDateTime,
                                  );
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isValid ? Colors.orange[600] : Colors.grey[400],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  initialTitle != null ? 'Update' : 'Add',
                                  style: TextStyle(
                                    color: isValid ? Colors.white : Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 