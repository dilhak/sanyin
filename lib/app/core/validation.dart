class Validation {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateName(String? value) {
    final error = validateRequired(value, 'Name');
    if (error != null) return error;
    
    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }

  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }
    
    if (value.trim().length > 500) {
      return 'Notes must be less than 500 characters';
    }
    
    return null;
  }

  static String? validateReminderTitle(String? value) {
    final error = validateRequired(value, 'Reminder title');
    if (error != null) return error;
    
    if (value!.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    
    return null;
  }

  static String? validateReminderDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    
    if (value.trim().length > 200) {
      return 'Description must be less than 200 characters';
    }
    
    return null;
  }

  static String? validateDateTime(DateTime? value) {
    if (value == null) {
      return 'Date and time is required';
    }
    
    if (value.isBefore(DateTime.now())) {
      return 'Please select a future date and time';
    }
    
    return null;
  }

  static String? validateVitalSign(String? value, String vitalName, {
    double? minValue,
    double? maxValue,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // Vitals are optional
    }
    
    final numericValue = double.tryParse(value.trim());
    if (numericValue == null) {
      return '$vitalName must be a valid number';
    }
    
    if (minValue != null && numericValue < minValue) {
      return '$vitalName must be at least $minValue';
    }
    
    if (maxValue != null && numericValue > maxValue) {
      return '$vitalName must be less than $maxValue';
    }
    
    return null;
  }

  static String? validateBloodPressure(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // BP is optional
    }
    
    final parts = value.trim().split('/');
    if (parts.length != 2) {
      return 'Blood pressure must be in format: systolic/diastolic (e.g., 120/80)';
    }
    
    final systolic = int.tryParse(parts[0]);
    final diastolic = int.tryParse(parts[1]);
    
    if (systolic == null || diastolic == null) {
      return 'Blood pressure values must be valid numbers';
    }
    
    if (systolic < 70 || systolic > 200) {
      return 'Systolic pressure must be between 70-200';
    }
    
    if (diastolic < 40 || diastolic > 130) {
      return 'Diastolic pressure must be between 40-130';
    }
    
    if (systolic <= diastolic) {
      return 'Systolic pressure must be higher than diastolic';
    }
    
    return null;
  }

  static String? validateTemperature(String? value) {
    return validateVitalSign(value, 'Temperature', minValue: 90.0, maxValue: 110.0);
  }

  static String? validatePulse(String? value) {
    return validateVitalSign(value, 'Pulse', minValue: 40.0, maxValue: 200.0);
  }

  static String? validateRespirations(String? value) {
    return validateVitalSign(value, 'Respirations', minValue: 8.0, maxValue: 40.0);
  }

  static String? validateOxygenSaturation(String? value) {
    return validateVitalSign(value, 'Oxygen saturation', minValue: 70.0, maxValue: 100.0);
  }

  static String? validatePainScale(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Pain scale is optional
    }
    
    final painValue = int.tryParse(value.trim());
    if (painValue == null) {
      return 'Pain scale must be a valid number';
    }
    
    if (painValue < 0 || painValue > 10) {
      return 'Pain scale must be between 0-10';
    }
    
    return null;
  }

  static String? validateWeight(String? value) {
    return validateVitalSign(value, 'Weight', minValue: 50.0, maxValue: 500.0);
  }

  static String? validateHeight(String? value) {
    return validateVitalSign(value, 'Height', minValue: 36.0, maxValue: 84.0);
  }

  static String? validateBloodSugar(String? value) {
    return validateVitalSign(value, 'Blood sugar', minValue: 40.0, maxValue: 600.0);
  }

  static String? validateMedicationDose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Medication dose is required';
    }
    
    if (value.trim().length > 50) {
      return 'Dose must be less than 50 characters';
    }
    
    return null;
  }

  static String? validateMedicationName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Medication name is required';
    }
    
    if (value.trim().length > 100) {
      return 'Medication name must be less than 100 characters';
    }
    
    return null;
  }

  static String? validateClientId(int? clientId) {
    if (clientId == null || clientId <= 0) {
      return 'Invalid client ID';
    }
    return null;
  }

  static String? validateCareLogDetails(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Details are optional
    }
    
    if (value.trim().length > 1000) {
      return 'Details must be less than 1000 characters';
    }
    
    return null;
  }
} 