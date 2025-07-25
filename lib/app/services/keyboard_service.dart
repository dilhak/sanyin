import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class KeyboardService extends GetxService {
  static KeyboardService get to => Get.find();
  
  final RxBool isKeyboardVisible = false.obs;
  final RxDouble keyboardHeight = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _setupKeyboardListeners();
  }

  void _setupKeyboardListeners() {
    // Listen for keyboard visibility changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(Get.context!);
      isKeyboardVisible.value = mediaQuery.viewInsets.bottom > 0;
      keyboardHeight.value = mediaQuery.viewInsets.bottom;
    });
  }

  // Dismiss keyboard from anywhere in the app
  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // Show keyboard for a specific focus node
  void showKeyboard(FocusNode focusNode) {
    focusNode.requestFocus();
    // Ensure keyboard appears quickly
    HapticFeedback.lightImpact();
  }

  // Handle keyboard dismissal on scroll
  void setupScrollDismiss(ScrollController controller) {
    controller.addListener(() {
      if (controller.position.userScrollDirection == ScrollDirection.reverse) {
        dismissKeyboard();
      }
    });
  }

  // Auto-focus next field in a form
  void focusNextField(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  // Auto-focus previous field in a form
  void focusPreviousField(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  // Handle form submission with keyboard dismissal
  void handleFormSubmission(BuildContext context, {VoidCallback? onComplete}) {
    dismissKeyboard();
    if (onComplete != null) {
      onComplete();
    }
  }

  // Setup keyboard-aware scrolling
  Widget wrapWithKeyboardAwareScroll(Widget child) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: child,
    );
  }

  // Get keyboard-aware padding
  EdgeInsets getKeyboardAwarePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    
    return EdgeInsets.only(
      left: 16,
      right: 16,
      top: 16,
      bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
    );
  }

  // Handle back button press to dismiss keyboard
  bool handleBackPress() {
    if (isKeyboardVisible.value) {
      dismissKeyboard();
      return true; // Consume the back press
    }
    return false; // Let the system handle it
  }

  // Setup keyboard shortcuts
  void setupKeyboardShortcuts(BuildContext context) {
    // Add keyboard shortcuts for common actions
    Actions(
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (intent) => dismissKeyboard(),
        ),
      },
      child: Focus(
        autofocus: true,
        child: Container(), // This will be replaced by actual content
      ),
    );
  }
}

// Custom intent for dismissing keyboard
class DismissIntent extends Intent {
  const DismissIntent();
} 