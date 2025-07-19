# Error Handling System Documentation

## Overview

The Sanyin app implements a comprehensive error handling system that provides consistent error management across all modules. The system categorizes errors, provides user-friendly messages, and includes retry mechanisms for transient failures.

## Architecture

### Core Components

1. **ErrorHandler** (`lib/app/core/error_handler.dart`)
   - Centralized error handling service
   - Error categorization and user-friendly messages
   - Consistent snackbar notifications

2. **Validation** (`lib/app/core/validation.dart`)
   - Form validation utilities
   - Input sanitization and validation rules
   - Consistent validation across the app

3. **RetryMechanism** (`lib/app/core/retry_mechanism.dart`)
   - Automatic retry for transient failures
   - Exponential backoff with jitter
   - Configurable retry conditions

4. **ConnectivityService** (`lib/app/services/connectivity_service.dart`)
   - Network connectivity monitoring
   - Network-aware error handling
   - Offline state management

## Error Types

### ErrorType Enum
- `network`: Network connectivity issues
- `database`: Database operation failures
- `validation`: Form validation errors
- `permission`: Permission-related errors
- `file`: File operation failures
- `unknown`: Unclassified errors

### AppError Class
```dart
class AppError {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;
}
```

## Usage Examples

### Basic Error Handling
```dart
final errorHandler = ErrorHandler();

try {
  await someOperation();
} catch (e) {
  errorHandler.showErrorSnackbar(errorHandler.categorizeError(e));
}
```

### With Retry Mechanism
```dart
final retryMechanism = RetryMechanism();

await retryMechanism.retryDatabaseOperation(
  () async => await databaseService.insertClient(client),
  operationName: 'Add client',
);
```

### Form Validation
```dart
final nameError = Validation.validateName(nameController.text);
if (nameError != null) {
  errorHandler.showWarningSnackbar(nameError);
  return false;
}
```

## Error Categories and Handling

### Database Errors
- **Causes**: SQLite failures, constraint violations, disk space issues
- **Handling**: Automatic retry with exponential backoff
- **User Message**: "Unable to save or retrieve data. Please try again."

### Network Errors
- **Causes**: No internet connection, timeout, server errors
- **Handling**: Connectivity monitoring, retry with backoff
- **User Message**: "Network connection issue. Please check your internet connection."

### Permission Errors
- **Causes**: Camera, storage, notification permissions denied
- **Handling**: No retry, show permission request
- **User Message**: "Permission required. Please grant the necessary permissions in settings."

### Validation Errors
- **Causes**: Invalid input, missing required fields
- **Handling**: No retry, show specific validation message
- **User Message**: Custom validation message

### File Errors
- **Causes**: Storage access, file corruption, disk space
- **Handling**: Limited retry, fallback options
- **User Message**: "Unable to access or save file. Please check storage permissions."

## Validation Rules

### Client Information
- **Name**: Required, 2-50 characters
- **Phone**: Optional, valid phone format
- **Notes**: Optional, max 500 characters

### Care Logs
- **Details**: Optional, max 1000 characters
- **Client ID**: Required, valid integer

### Reminders
- **Title**: Required, max 100 characters
- **Description**: Required, max 200 characters
- **DateTime**: Required, future date/time

### Vital Signs
- **Blood Pressure**: Format: systolic/diastolic (e.g., 120/80)
- **Temperature**: 90-110°F
- **Pulse**: 40-200 bpm
- **Respirations**: 8-40 per minute
- **Oxygen Saturation**: 70-100%

## Retry Strategy

### Database Operations
- **Max Attempts**: 3
- **Initial Delay**: 1 second
- **Backoff**: Exponential with jitter
- **Retryable**: Yes (except validation errors)

### Network Operations
- **Max Attempts**: 3
- **Initial Delay**: 1 second
- **Backoff**: Exponential
- **Retryable**: Yes (network-related errors only)

### File Operations
- **Max Attempts**: 2
- **Initial Delay**: 1 second
- **Backoff**: Exponential
- **Retryable**: Yes (file access errors)

## Error Logging

All errors are logged with the following information:
- Error type and message
- Original error details
- Stack trace (if available)
- Timestamp and context

## Best Practices

1. **Always categorize errors** using `ErrorHandler.categorizeError()`
2. **Use appropriate error types** for better user experience
3. **Implement retry for transient failures** using RetryMechanism
4. **Validate inputs** before processing using Validation utilities
5. **Show user-friendly messages** instead of technical error details
6. **Log errors for debugging** but don't expose sensitive information
7. **Handle connectivity changes** gracefully
8. **Provide fallback options** for critical operations

## Integration Points

### Controllers
All controllers now use the centralized error handling:
- ClientDashboardController
- AddClientController
- QuickActionsController
- PhotoCaptureController
- CareLogHistoryController

### Services
Services implement proper error handling:
- DatabaseService: Retry mechanism for database operations
- NotificationService: Permission and initialization error handling
- PhotoService: File and permission error handling
- ConnectivityService: Network state monitoring

### Main App
The main app initializes error handling services:
- ErrorHandler initialization
- ConnectivityService initialization
- NotificationService initialization with error handling

## Testing Error Scenarios

### Database Errors
1. Corrupt database file
2. Disk space full
3. Concurrent access conflicts

### Network Errors
1. No internet connection
2. Slow network response
3. Server timeout

### Permission Errors
1. Camera permission denied
2. Storage permission denied
3. Notification permission denied

### Validation Errors
1. Invalid input formats
2. Missing required fields
3. Out-of-range values

## Future Enhancements

1. **Error Analytics**: Track error patterns and frequency
2. **Automatic Recovery**: Self-healing mechanisms for common issues
3. **Offline Mode**: Enhanced offline functionality with sync
4. **Error Reporting**: Integration with crash reporting services
5. **Custom Error Types**: Domain-specific error categories
6. **Error Recovery**: Automatic recovery strategies for different error types 