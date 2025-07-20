import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/memory_manager.dart';

class MemoryMonitor extends StatelessWidget {
  const MemoryMonitor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Monitor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    MemoryManager.clearReactiveVariables();
                    Get.snackbar('Memory', 'Reactive variables cleared');
                  },
                  child: Text('Clear', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 24),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () {
                    MemoryManager.forceGarbageCollection();
                    Get.snackbar('Memory', 'Garbage collection triggered');
                  },
                  child: Text('GC', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 