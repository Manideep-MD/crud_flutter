import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ValidatorFn = String? Function(String? value);

class CommonTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValidatorFn? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final Color? fillColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  const CommonTextFormField({
    Key? key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = false,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.textInputAction,
    this.inputFormatters,
    this.enabled = true,
    this.fillColor,
    this.borderRadius = 8.0,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
  })  : assert(controller == null || initialValue == null,
  'Provide either controller or initialValue, not both.'),
        super(key: key);

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  late bool _obscure;
  TextEditingController? _internalController;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    if (widget.controller == null) {
      // only create internal controller if user didn't provide one and initialValue is present
      _internalController = TextEditingController(text: widget.initialValue ?? '');
    }
  }

  @override
  void dispose() {
    // dispose only internal controller
    _internalController?.dispose();
    super.dispose();
  }

  TextEditingController? get _effectiveController => widget.controller ?? _internalController;

  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
  }

  Widget? _buildSuffix() {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    if (widget.obscureText) {
      return IconButton(
        splashRadius: 20,
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: _toggleObscure,
      );
    }
    if (widget.showClearButton && _effectiveController != null) {
      return IconButton(
        splashRadius: 20,
        icon: const Icon(Icons.clear),
        onPressed: () {
          _effectiveController!.clear();
          // also notify onChanged with empty string
          widget.onChanged?.call('');
          setState(() {});
        },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: _effectiveController,
      initialValue: widget.controller == null ? widget.initialValue : null,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffix(),
        filled: true,
        fillColor: widget.fillColor ?? Theme.of(context).inputDecorationTheme.fillColor,
        contentPadding: widget.contentPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        errorMaxLines: 2,
      ),
    );
  }
}
