import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';


/// Custom text field widget with enhanced features for Onflix
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final String? prefixText;
  final String? suffixText;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final bool filled;
  final TextFieldVariant variant;
  final TextFieldSize size;
  final bool isRequired;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final Duration animationDuration;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.inputFormatters,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconData,
    this.suffixIconData,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    this.prefixText,
    this.suffixText,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.filled = true,
    this.variant = TextFieldVariant.outlined,
    this.size = TextFieldSize.medium,
    this.isRequired = false,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  // Named constructors for common use cases
  const CustomTextField.email({
    super.key,
    this.label = 'Email',
    this.hintText = 'Enter your email',
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.variant = TextFieldVariant.outlined,
    this.size = TextFieldSize.medium,
    this.isRequired = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : keyboardType = TextInputType.emailAddress,
       textInputAction = TextInputAction.next,
       obscureText = false,
       autocorrect = false,
       enableSuggestions = false,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       maxLengthEnforcement = null,
       inputFormatters = null,
       prefixIcon = null,
       suffixIcon = null,
       prefixIconData = LucideIcons.mail,
       suffixIconData = null,
       onPrefixIconTap = null,
       onSuffixIconTap = null,
       onTap = null,
       prefixText = null,
       suffixText = null,
       labelStyle = null,
       hintStyle = null,
       errorStyle = null,
       helperStyle = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       filled = true;

  const CustomTextField.password({
    super.key,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.variant = TextFieldVariant.outlined,
    this.size = TextFieldSize.medium,
    this.isRequired = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : keyboardType = TextInputType.visiblePassword,
       textInputAction = TextInputAction.done,
       obscureText = true,
       autocorrect = false,
       enableSuggestions = false,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       maxLengthEnforcement = null,
       inputFormatters = null,
       prefixIcon = null,
       suffixIcon = null,
       prefixIconData = LucideIcons.lock,
       suffixIconData = LucideIcons.eye,
       onPrefixIconTap = null,
       onSuffixIconTap = null,
       onTap = null,
       prefixText = null,
       suffixText = null,
       labelStyle = null,
       hintStyle = null,
       errorStyle = null,
       helperStyle = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       filled = true;

  const CustomTextField.search({
    super.key,
    this.label,
    this.hintText = 'Search...',
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.variant = TextFieldVariant.filled,
    this.size = TextFieldSize.medium,
    this.validator,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search,
       obscureText = false,
       autocorrect = false,
       enableSuggestions = true,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       maxLengthEnforcement = null,
       inputFormatters = null,
       prefixIcon = null,
       suffixIcon = null,
       prefixIconData = LucideIcons.search,
       suffixIconData = LucideIcons.x,
       onPrefixIconTap = null,
       onSuffixIconTap = null,
       onTap = null,
       prefixText = null,
       suffixText = null,
       labelStyle = null,
       hintStyle = null,
       errorStyle = null,
       helperStyle = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       filled = true,
       isRequired = false,
       autovalidateMode = AutovalidateMode.disabled;

  const CustomTextField.multiline({
    super.key,
    this.label,
    this.hintText = 'Enter text...',
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 4,
    this.minLines = 2,
    this.maxLength,
    this.focusNode,
    this.style,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.variant = TextFieldVariant.outlined,
    this.size = TextFieldSize.medium,
    this.validator,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       obscureText = false,
       autocorrect = true,
       enableSuggestions = true,
       maxLengthEnforcement = null,
       inputFormatters = null,
       prefixIcon = null,
       suffixIcon = null,
       prefixIconData = null,
       suffixIconData = null,
       onPrefixIconTap = null,
       onSuffixIconTap = null,
       onTap = null,
       prefixText = null,
       suffixText = null,
       labelStyle = null,
       hintStyle = null,
       errorStyle = null,
       helperStyle = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       filled = true,
       isRequired = false,
       autovalidateMode = AutovalidateMode.disabled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;

  bool _isFocused = false;
  bool _isHovered = false;
  bool _obscureText = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _obscureText = widget.obscureText;
  }

  void _initializeControllers() {
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: widget.borderColor ?? OnflixColors.lightGray.withOpacity(0.3),
      end: widget.focusedBorderColor ?? OnflixColors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleTextChange);
      _controller = widget.controller ?? _controller;
      _controller.addListener(_handleTextChange);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? _focusNode;
      _focusNode.addListener(_handleFocusChange);
    }

    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      if (_controller.text.isEmpty) {
        _animationController.reverse();
      }
    }
  }

  void _handleTextChange() {
    widget.onChanged?.call(_controller.text);
    
    if (widget.validator != null && widget.autovalidateMode != AutovalidateMode.disabled) {
      final error = widget.validator!(_controller.text);
      if (error != _currentError) {
        setState(() {
          _currentError = error;
        });
      }
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveError = widget.errorText ?? _currentError;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            _buildLabel(context),
          
          _buildTextField(context, effectiveError),
          
          if (widget.helperText != null || effectiveError != null)
            _buildHelperText(context, effectiveError),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: widget.labelStyle ?? _getDefaultLabelStyle(context),
          children: [
            TextSpan(text: widget.label),
            if (widget.isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: OnflixColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String? effectiveError) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ShadInput(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          inputFormatters: widget.inputFormatters,
          style: widget.style ?? _getDefaultTextStyle(context),
          onPressed: widget.onTap,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
        );
      }
    );
  }

  Widget _buildHelperText(BuildContext context, String? effectiveError) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: effectiveError != null
          ? Text(
              effectiveError,
              style: widget.errorStyle ?? _getDefaultErrorStyle(context),
            )
          : widget.helperText != null
              ? Text(
                  widget.helperText!,
                  style: widget.helperStyle ?? _getDefaultHelperStyle(context),
                )
              : const SizedBox.shrink(),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, String? effectiveError) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: widget.hintStyle ?? _getDefaultHintStyle(context),
      prefixIcon: _buildPrefixIcon(),
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      contentPadding: widget.contentPadding ?? _getDefaultContentPadding(),
      filled: widget.filled,
      fillColor: widget.fillColor ?? _getDefaultFillColor(context),
      border: _buildBorder(context, effectiveError),
      enabledBorder: _buildBorder(context, effectiveError),
      focusedBorder: _buildFocusedBorder(context, effectiveError),
      errorBorder: _buildErrorBorder(context),
      focusedErrorBorder: _buildErrorBorder(context),
      disabledBorder: _buildDisabledBorder(context),
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon!;
    }
    
    if (widget.prefixIconData != null) {
      return IconButton(
        icon: Icon(
          widget.prefixIconData!,
          size: _getIconSize(),
          color: _getIconColor(context),
        ),
        onPressed: widget.onPrefixIconTap,
      );
    }
    
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon!;
    }
    
    // Handle password visibility toggle
    if (widget.obscureText && widget.suffixIconData != null) {
      return IconButton(
        icon: Icon(
          _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
          size: _getIconSize(),
          color: _getIconColor(context),
        ),
        onPressed: _toggleObscureText,
      );
    }
    
    // Handle search field clear button
    if (widget.variant == TextFieldVariant.filled && 
        widget.suffixIconData == LucideIcons.x && 
        _controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(
          LucideIcons.x,
          size: _getIconSize(),
          color: _getIconColor(context),
        ),
        onPressed: _clearText,
      );
    }
    
    if (widget.suffixIconData != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIconData!,
          size: _getIconSize(),
          color: _getIconColor(context),
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }
    
    return null;
  }

  InputBorder _buildBorder(BuildContext context, String? effectiveError) {
    final borderColor = effectiveError != null 
        ? (widget.errorBorderColor ?? OnflixColors.error)
        : (widget.borderColor ?? OnflixColors.lightGray.withOpacity(0.3));
    
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: borderColor, width: 1),
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide.none,
        );
    }
  }

  InputBorder _buildFocusedBorder(BuildContext context, String? effectiveError) {
    final borderColor = effectiveError != null 
        ? (widget.errorBorderColor ?? OnflixColors.error)
        : (widget.focusedBorderColor ?? OnflixColors.primary);
    
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: borderColor, width: 2),
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: borderColor, width: 2),
        );
    }
  }

  InputBorder _buildErrorBorder(BuildContext context) {
    final borderColor = widget.errorBorderColor ?? OnflixColors.error;
    
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: borderColor, width: 1),
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: borderColor, width: 1),
        );
    }
  }

  InputBorder _buildDisabledBorder(BuildContext context) {
    final borderColor = OnflixColors.lightGray.withOpacity(0.2);
    
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: borderColor, width: 1),
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide.none,
        );
    }
  }

  // Style getters
  TextStyle _getDefaultTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
  }

  TextStyle _getDefaultLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle();
  }

  TextStyle _getDefaultHintStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: OnflixColors.lightGray,
    ) ?? const TextStyle();
  }

  TextStyle _getDefaultErrorStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: OnflixColors.error,
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle();
  }

  TextStyle _getDefaultHelperStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: OnflixColors.lightGray,
    ) ?? const TextStyle();
  }

  Color _getDefaultFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? OnflixColors.mediumGray.withOpacity(0.3)
        : OnflixColors.veryLightGray.withOpacity(0.5);
  }

  Color _getIconColor(BuildContext context) {
    return _isFocused ? OnflixColors.primary : OnflixColors.lightGray;
  }

  BorderRadius _getDefaultBorderRadius() {
    return BorderRadius.circular(8);
  }

  EdgeInsetsGeometry _getDefaultContentPadding() {
    switch (widget.size) {
      case TextFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case TextFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case TextFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case TextFieldSize.small:
        return 18;
      case TextFieldSize.medium:
        return 20;
      case TextFieldSize.large:
        return 22;
    }
  }
}

/// Text field variant enumeration
enum TextFieldVariant {
  outlined,
  filled,
  underlined,
}

/// Text field size enumeration
enum TextFieldSize {
  small,
  medium,
  large,
}