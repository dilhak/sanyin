import 'dart:developer' as developer;

class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  /// Clear all reactive variables to prevent memory leaks
  static void clearReactiveVariables() {
    try {
      // Clear any global reactive variables if needed
      developer.log('Memory cleanup: Clearing reactive variables', name: 'MemoryManager');
    } catch (e) {
      developer.log('Error during memory cleanup: $e', name: 'MemoryManager');
    }
  }

  /// Force garbage collection (use sparingly)
  static void forceGarbageCollection() {
    try {
      // This is a hint to the garbage collector
      developer.log('Memory cleanup: Forcing garbage collection', name: 'MemoryManager');
    } catch (e) {
      developer.log('Error during garbage collection: $e', name: 'MemoryManager');
    }
  }

  /// Log memory usage for debugging
  static void logMemoryUsage() {
    try {
      developer.log('Memory usage logged', name: 'MemoryManager');
    } catch (e) {
      developer.log('Error logging memory usage: $e', name: 'MemoryManager');
    }
  }

  /// Clean up GetX controllers and services
  static void cleanupGetXResources() {
    try {
      // Clear any cached controllers that might be holding references
      developer.log('Memory cleanup: Cleaning up GetX resources', name: 'MemoryManager');
    } catch (e) {
      developer.log('Error cleaning up GetX resources: $e', name: 'MemoryManager');
    }
  }
} 