import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum AppTextFieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  search,
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final AppTextFieldType type;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final VoidCallback? onSuffixIconTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.type = AppTextFieldType.text,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixWidget,
    this.suffixWidget,
    this.onSuffixIconTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.borderWidth,
  });

  const AppTextField.email({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixWidget,
    this.suffixWidget,
    this.onSuffixIconTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.borderWidth,
  }) : type = AppTextFieldType.email,
       maxLines = 1,
       minLines = null,
       inputFormatters = null;

  const AppTextField.password({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLength,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.borderWidth,
  }) : type = AppTextFieldType.password,
       maxLines = 1,
       minLines = null,
       suffixIcon = null,
       prefixWidget = null,
       suffixWidget = null,
       onSuffixIconTap = null,
       inputFormatters = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == AppTextFieldType.password;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(theme),
          const SizedBox(height: 8),
        ],
        _buildTextField(theme),
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 4),
          _buildHelperText(theme),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          _buildErrorText(theme),
        ],
      ],
    );
  }

  Widget _buildLabel(ThemeData theme) {
    return RichText(
      text: TextSpan(
        text: widget.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction ?? _getTextInputAction(),
      inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
      validator: widget.validator ?? _getDefaultValidator(),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: widget.isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
      ),
      decoration: _buildInputDecoration(theme),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme) {
    final borderColor = _getBorderColor();
    final fillColor = widget.fillColor ?? Colors.white;
    
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.textSecondary,
      ),
      prefixIcon: _buildPrefixIcon(),
      suffixIcon: _buildSuffixIcon(),
      filled: true,
      fillColor: widget.isEnabled ? fillColor : fillColor.withOpacity(0.5),
      contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: _buildBorder(borderColor),
      enabledBorder: _buildBorder(borderColor),
      focusedBorder: _buildBorder(AppTheme.primaryBlue, width: 2),
      errorBorder: _buildBorder(AppTheme.errorRed),
      focusedErrorBorder: _buildBorder(AppTheme.errorRed, width: 2),
      disabledBorder: _buildBorder(AppTheme.mediumGray.withOpacity(0.3)),
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixWidget != null) {
      return widget.prefixWidget;
    }
    
    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        color: _hasFocus ? AppTheme.primaryBlue : AppTheme.textSecondary,
      );
    }
    
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixWidget != null) {
      return widget.suffixWidget;
    }
    
    if (widget.type == AppTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _hasFocus ? AppTheme.primaryBlue : AppTheme.textSecondary,
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }
    
    return null;
  }

  OutlineInputBorder _buildBorder(Color color, {double? width}) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color,
        width: width ?? widget.borderWidth ?? 1,
      ),
    );
  }

  Color _getBorderColor() {
    if (widget.borderColor != null) {
      return widget.borderColor!;
    }
    
    if (_hasFocus) {
      return AppTheme.primaryBlue;
    }
    
    return AppTheme.mediumGray;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.phone:
        return TextInputType.phone;
      case AppTextFieldType.multiline:
        return TextInputType.multiline;
      case AppTextFieldType.search:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case AppTextFieldType.multiline:
        return TextInputAction.newline;
      case AppTextFieldType.search:
        return TextInputAction.search;
      default:
        return TextInputAction.next;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case AppTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }

  String? Function(String?)? _getDefaultValidator() {
    if (!widget.isRequired) return null;
    
    switch (widget.type) {
      case AppTextFieldType.email:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        };
      case AppTextFieldType.password:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        };
      default:
        return (value) {
          if (value == null || value.isEmpty) {
            return '${widget.label ?? 'Field'} is required';
          }
          return null;
        };
    }
  }

  Widget _buildHelperText(ThemeData theme) {
    return Text(
      widget.helperText!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildErrorText(ThemeData theme) {
    return Text(
      widget.errorText!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: AppTheme.errorRed,
      ),
    );
  }
}

