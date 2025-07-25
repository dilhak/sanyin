import 'package:flutter/material.dart';

/// Uniform spacing constants for consistent spacing between parent and child nodes
class SpacingConstants {
  // Base spacing unit (8px) - Increased by 30% for better parent-child separation
  static const double xs = 5.2;  // 4.0 * 1.3
  static const double sm = 10.4; // 8.0 * 1.3
  static const double md = 20.8; // 16.0 * 1.3
  static const double lg = 31.2; // 24.0 * 1.3
  static const double xl = 41.6; // 32.0 * 1.3
  static const double xxl = 62.4; // 48.0 * 1.3

  // Common spacing patterns - Increased by 30% for better parent-child separation
  static const EdgeInsets paddingAll = EdgeInsets.all(md);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: md);
  
  // Section spacing - Increased for better hierarchy
  static const EdgeInsets sectionPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  
  // List spacing - Increased for better readability
  static const EdgeInsets listItemSpacing = EdgeInsets.only(bottom: sm);
  static const EdgeInsets gridSpacing = EdgeInsets.all(sm);
  
  // Dialog spacing - Increased for better visual separation
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  static const EdgeInsets dialogContentPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  
  // Form spacing - Increased for better field separation
  static const EdgeInsets formFieldSpacing = EdgeInsets.only(bottom: md);
  static const EdgeInsets formSectionSpacing = EdgeInsets.only(bottom: lg);
  
  // Button spacing - Increased for better touch targets
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets buttonSpacing = EdgeInsets.only(right: sm);
  
  // Icon spacing - Increased for better visual balance
  static const EdgeInsets iconPadding = EdgeInsets.all(sm);
  static const EdgeInsets iconSpacing = EdgeInsets.only(right: sm);
  
  // Text spacing - Increased for better readability
  static const EdgeInsets textPadding = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets textSpacing = EdgeInsets.only(bottom: sm);
  
  // Container spacing - Increased for better content separation
  static const EdgeInsets containerPadding = EdgeInsets.all(md);
  static const EdgeInsets containerMargin = EdgeInsets.only(bottom: md);
  
  // Navigation spacing - Increased for better touch targets
  static const EdgeInsets navigationPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  
  // Bottom sheet spacing - Increased for better visual hierarchy
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(lg);
  static const EdgeInsets bottomSheetContentPadding = EdgeInsets.symmetric(horizontal: lg);
  
  // Card spacing - Increased for better content separation
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: md);
  static const EdgeInsets cardContentPadding = EdgeInsets.all(md);
  
  // Input field spacing - Increased for better field separation
  static const EdgeInsets inputFieldPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets inputFieldMargin = EdgeInsets.only(bottom: md);
  
  // Header spacing - Increased for better section separation
  static const EdgeInsets headerPadding = EdgeInsets.all(lg);
  static const EdgeInsets headerMargin = EdgeInsets.only(bottom: lg);
  
  // Footer spacing - Increased for better section separation
  static const EdgeInsets footerPadding = EdgeInsets.all(lg);
  static const EdgeInsets footerMargin = EdgeInsets.only(top: lg);
  
  // Divider spacing - Increased for better visual separation
  static const EdgeInsets dividerMargin = EdgeInsets.symmetric(vertical: md);
  
  // Status spacing - Increased for better visual hierarchy
  static const EdgeInsets statusPadding = EdgeInsets.symmetric(horizontal: sm, vertical: xs);
  static const EdgeInsets statusMargin = EdgeInsets.only(bottom: sm);
}

/// Spacing widgets for consistent spacing
class Spacing {
  // Vertical spacing
  static const Widget xs = SizedBox(height: SpacingConstants.xs);
  static const Widget sm = SizedBox(height: SpacingConstants.sm);
  static const Widget md = SizedBox(height: SpacingConstants.md);
  static const Widget lg = SizedBox(height: SpacingConstants.lg);
  static const Widget xl = SizedBox(height: SpacingConstants.xl);
  static const Widget xxl = SizedBox(height: SpacingConstants.xxl);
  
  // Horizontal spacing
  static const Widget hXs = SizedBox(width: SpacingConstants.xs);
  static const Widget hSm = SizedBox(width: SpacingConstants.sm);
  static const Widget hMd = SizedBox(width: SpacingConstants.md);
  static const Widget hLg = SizedBox(width: SpacingConstants.lg);
  static const Widget hXl = SizedBox(width: SpacingConstants.xl);
  static const Widget hXxl = SizedBox(width: SpacingConstants.xxl);
  
  // Custom spacing
  static Widget custom(double size) => SizedBox(height: size);
  static Widget hCustom(double size) => SizedBox(width: size);
}

/// Spacing mixins for consistent spacing patterns
mixin SpacingMixin {
  // Common spacing getters
  EdgeInsets get sectionPadding => SpacingConstants.sectionPadding;
  EdgeInsets get cardPadding => SpacingConstants.cardPadding;
  EdgeInsets get formFieldSpacing => SpacingConstants.formFieldSpacing;
  EdgeInsets get buttonPadding => SpacingConstants.buttonPadding;
  EdgeInsets get dialogPadding => SpacingConstants.dialogPadding;
  EdgeInsets get bottomSheetPadding => SpacingConstants.bottomSheetPadding;
  
  // Common spacing widgets
  Widget get spacingSm => Spacing.sm;
  Widget get spacingMd => Spacing.md;
  Widget get spacingLg => Spacing.lg;
  Widget get spacingXl => Spacing.xl;
  
  // Horizontal spacing widgets
  Widget get hSpacingSm => Spacing.hSm;
  Widget get hSpacingMd => Spacing.hMd;
  Widget get hSpacingLg => Spacing.hLg;
}

/// Spacing extensions for common widgets
extension SpacingExtension on Widget {
  Widget withPadding(EdgeInsets padding) => Padding(
    padding: padding,
    child: this,
  );
  
  Widget withMargin(EdgeInsets margin) => Container(
    margin: margin,
    child: this,
  );
  
  Widget withSpacing({double? top, double? bottom, double? left, double? right}) => Padding(
    padding: EdgeInsets.only(
      top: top ?? 0,
      bottom: bottom ?? 0,
      left: left ?? 0,
      right: right ?? 0,
    ),
    child: this,
  );
  
  Widget withVerticalSpacing(double spacing) => Padding(
    padding: EdgeInsets.symmetric(vertical: spacing),
    child: this,
  );
  
  Widget withHorizontalSpacing(double spacing) => Padding(
    padding: EdgeInsets.symmetric(horizontal: spacing),
    child: this,
  );
}

/// Spacing builder for conditional spacing
class SpacingBuilder extends StatelessWidget {
  final bool condition;
  final Widget child;
  final double spacing;
  
  const SpacingBuilder({
    super.key,
    required this.condition,
    required this.child,
    this.spacing = SpacingConstants.md,
  });
  
  @override
  Widget build(BuildContext context) {
    return condition ? Column(
      children: [
        child,
        SizedBox(height: spacing),
      ],
    ) : child;
  }
} 