import 'package:flutter/material.dart';
import '../services/keyboard_service.dart';

class KeyboardAwareWrapper extends StatefulWidget {
  final Widget child;
  final bool enableKeyboardDismiss;
  final bool enableScrollDismiss;
  final EdgeInsets? padding;
  final ScrollController? scrollController;

  const KeyboardAwareWrapper({
    super.key,
    required this.child,
    this.enableKeyboardDismiss = true,
    this.enableScrollDismiss = true,
    this.padding,
    this.scrollController,
  });

  @override
  State<KeyboardAwareWrapper> createState() => _KeyboardAwareWrapperState();
}

class _KeyboardAwareWrapperState extends State<KeyboardAwareWrapper>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  final KeyboardService _keyboardService = KeyboardService.to;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.enableScrollDismiss) {
      _keyboardService.setupScrollDismiss(_scrollController);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Handle keyboard visibility changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      _keyboardService.isKeyboardVisible.value = mediaQuery.viewInsets.bottom > 0;
      _keyboardService.keyboardHeight.value = mediaQuery.viewInsets.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Dismiss keyboard on back button press
        if (_keyboardService.isKeyboardVisible.value) {
          _keyboardService.dismissKeyboard();
          return false; // Prevent back navigation if keyboard is visible
        }
        return true; // Allow normal back navigation
      },
      child: GestureDetector(
        onTap: widget.enableKeyboardDismiss
            ? () => _keyboardService.dismissKeyboard()
            : null,
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: widget.enableScrollDismiss
              ? ScrollViewKeyboardDismissBehavior.onDrag
              : ScrollViewKeyboardDismissBehavior.manual,
          padding: widget.padding ?? _keyboardService.getKeyboardAwarePadding(context),
          child: widget.child,
        ),
      ),
    );
  }
}

// Keyboard-aware form wrapper
class KeyboardAwareForm extends StatefulWidget {
  final Widget child;
  final GlobalKey<FormState>? formKey;
  final VoidCallback? onSubmit;
  final bool enableAutoFocus;

  const KeyboardAwareForm({
    super.key,
    required this.child,
    this.formKey,
    this.onSubmit,
    this.enableAutoFocus = true,
  });

  @override
  State<KeyboardAwareForm> createState() => _KeyboardAwareFormState();
}

class _KeyboardAwareFormState extends State<KeyboardAwareForm> {
  final KeyboardService _keyboardService = KeyboardService.to;

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareWrapper(
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Expanded(child: widget.child),
            if (widget.onSubmit != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _keyboardService.handleFormSubmission(
                      context,
                      onComplete: widget.onSubmit,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Keyboard-aware bottom sheet wrapper
class KeyboardAwareBottomSheet extends StatelessWidget {
  final Widget child;
  final double? maxHeight;
  final bool enableKeyboardDismiss;

  const KeyboardAwareBottomSheet({
    super.key,
    required this.child,
    this.maxHeight,
    this.enableKeyboardDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: KeyboardAwareWrapper(
        enableKeyboardDismiss: enableKeyboardDismiss,
        child: child,
      ),
    );
  }
} 