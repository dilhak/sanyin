import '../core/memory_manager.dart';

class MemoryUtils {
  /// Optimize memory usage by clearing unnecessary data
  static void optimizeMemory() {
    try {
      // Clear reactive variables
      MemoryManager.clearReactiveVariables();
      
      // Clean up GetX resources
      MemoryManager.cleanupGetXResources();
      
      // Log memory usage
      MemoryManager.logMemoryUsage();
    } catch (e) {
      print('Error optimizing memory: $e');
    }
  }

  /// Check if memory usage is high (simple heuristic)
  static bool isMemoryUsageHigh() {
    // This is a simple check - in a real app you might use platform-specific APIs
    return false;
  }

  /// Perform aggressive memory cleanup
  static void aggressiveCleanup() {
    try {
      // Clear all reactive variables
      MemoryManager.clearReactiveVariables();
      
      // Force garbage collection
      MemoryManager.forceGarbageCollection();
      
      // Clean up GetX resources
      MemoryManager.cleanupGetXResources();
      
      print('Aggressive memory cleanup completed');
    } catch (e) {
      print('Error during aggressive cleanup: $e');
    }
  }

  /// Monitor memory usage and perform cleanup if needed
  static void monitorAndCleanup() {
    if (isMemoryUsageHigh()) {
      aggressiveCleanup();
    } else {
      optimizeMemory();
    }
  }
} 