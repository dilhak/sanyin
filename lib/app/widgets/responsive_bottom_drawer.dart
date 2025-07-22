import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'universal_popup.dart';

/// Responsive bottom drawer that adapts to different screen sizes
/// - Automatically adjusts grid layout based on screen width
/// - Calculates optimal height based on content
/// - Supports both form content and action grids
class ResponsiveBottomDrawer {
  static void show({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget content,
    double maxHeight = 0.8,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * maxHeight,
        ),
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Content with bottom padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: content,
              ),
            ),
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
    );
  }

  /// Shows a responsive action grid that adapts to screen size
  /// - Mobile: 2 columns
  /// - Landscape: 3 columns  
  /// - Tablet: 3 columns with adjusted aspect ratio
  static void showActions({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<PopupAction> actions,
    double maxHeight = 0.8,
  }) {
    final screenHeight = Get.height;
    final screenWidth = Get.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenHeight < screenWidth;
    
    // Adjust layout based on screen size
    int crossAxisCount = 2;
    double childAspectRatio = 1.2;
    
    if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.0;
    } else if (isLandscape) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
    }
    
    // Calculate max height based on content with better estimation
    final estimatedHeight = (actions.length / crossAxisCount).ceil() * 140 + 250;
    final maxDrawerHeight = (estimatedHeight / screenHeight).clamp(0.4, maxHeight);

    show(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      maxHeight: maxDrawerHeight,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionButton(action);
            },
          ),
        ),
      ),
    );
  }

  static Widget _buildActionButton(PopupAction action) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 