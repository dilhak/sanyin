import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool obscureText;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final double? height;
  final bool showClearButton;
  final bool autoFocus;
  final bool enableInteractiveSelection;

  const EnhancedTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.obscureText = false,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 16.0,
    this.height,
    this.showClearButton = true,
    this.autoFocus = false,
    this.enableInteractiveSelection = true,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
      // Ensure keyboard appears quickly
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
    }
  }

  void _clearText() {
    widget.controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.height ?? 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: (widget.focusedBorderColor ?? Colors.blue)
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                  if (!_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                  }
                  // Add haptic feedback for better UX
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: widget.fillColor ?? Colors.grey[50],
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: _isFocused
                          ? (widget.focusedBorderColor ?? Colors.blue)
                          : (widget.borderColor ?? Colors.grey[300]!),
                      width: _isFocused ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? (widget.focusedBorderColor ?? Colors.blue)
                              : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          keyboardType: widget.keyboardType,
                          textInputAction: widget.textInputAction,
                          textCapitalization: widget.textCapitalization,
                          maxLines: widget.maxLines,
                          maxLength: widget.maxLength,
                          enabled: widget.enabled,
                          obscureText: widget.obscureText,
                          onChanged: widget.onChanged,
                          onSubmitted: widget.onSubmitted,
                          inputFormatters: widget.inputFormatters,
                          enableInteractiveSelection: widget.enableInteractiveSelection,
                          autofocus: widget.autoFocus,
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.enabled ? Colors.black87 : Colors.grey[600],
                          ),
                          decoration: InputDecoration(
                            labelText: widget.labelText != null
                                ? '${widget.labelText}${widget.isRequired ? ' *' : ''}'
                                : null,
                            hintText: widget.hintText,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            labelStyle: TextStyle(
                              color: _isFocused
                                  ? (widget.focusedBorderColor ?? Colors.blue)
                                  : Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            suffixIcon: _buildSuffixIcon(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: Colors.grey[600],
        size: 20,
      );
    }

    if (widget.showClearButton &&
        widget.controller.text.isNotEmpty &&
        _isFocused) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.grey[500],
          size: 20,
        ),
        onPressed: _clearText,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      );
    }

    return null;
  }
}

// Enhanced form field wrapper for better validation UX
class EnhancedFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool obscureText;

  const EnhancedFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnhancedTextField(
              controller: controller,
              focusNode: focusNode,
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixIcon,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              maxLines: maxLines,
              isRequired: isRequired,
              onChanged: (value) {
                field.didChange(value);
                if (onChanged != null) {
                  onChanged!(value);
                }
              },
              onSubmitted: onSubmitted,
              inputFormatters: inputFormatters,
              enabled: enabled,
              obscureText: obscureText,
              focusedBorderColor: field.hasError ? Colors.red : null,
            ),
            if (field.hasError) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
} 