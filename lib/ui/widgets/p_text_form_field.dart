import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PTextFormField extends StatefulWidget {
  const PTextFormField({
    super.key,
    this.label,
    this.labelActions,
    this.labelActionsPadding = EdgeInsets.zero,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixIcons,
    this.hintText,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.readonly = false,
    this.maxLines = 1,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.iconsAlignment = CrossAxisAlignment.center,
    this.focusNode,
    this.controller,
    this.showCopyButton = false,
    this.showRandomGenButton = false,
    this.onRandomGen,
    this.onTap,
    this.onChanged,
    this.validator,
  });

  final Widget? label;

  /// label右侧actions
  final List<Widget>? labelActions;
  final EdgeInsets labelActionsPadding;

  final Widget? prefixIcon;

  /// 如果传递该属性,则不渲染默认行为例如: clear text..
  final Widget? suffixIcon;
  final List<Widget>? suffixIcons;
  final String? hintText;
  final TextAlign textAlign;

  final bool enabled;
  final bool readonly;
  final int maxLines;
  // 输入框初始值, 实际上是传递给controller.text
  final String? initialValue;
  // 键盘类型
  final TextInputType? keyboardType;
  // 键盘输入类型
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final CrossAxisAlignment iconsAlignment;

  final FocusNode? focusNode;
  final TextEditingController? controller;

  final bool showCopyButton;
  final bool showRandomGenButton;
  final ValueChanged<TextInputType?>? onRandomGen;

  /// 如果传递该属性,则会导致TextField无法响应 pointer事件
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? Function(String? value)? validator;

  @override
  State<PTextFormField> createState() => _PTextFieldState();
}

class _PTextFieldState extends State<PTextFormField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  bool _clearIconVisible = false;

  /// 当keyboardType类型为 password时,通过该属性控制显示与隐藏
  late bool _obscureText;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  bool get _isPasswordKeyboardType =>
      widget.keyboardType == TextInputType.visiblePassword;

  bool get _isMultiLine => widget.maxLines > 1;

  void _init() {
    if (widget.controller == null) {
      _internalController = TextEditingController(
        text: widget.initialValue ?? '',
      );
    } else {
      if (widget.controller != null && widget.initialValue != null) {
        throw 'controller和initialValue不能同时传递';
      }
      // if (widget.controller!.text.isEmpty) {
      //   widget.controller!.text = widget.initialValue ?? '';
      // }
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }

    _effectiveFocusNode.addListener(_handleFocusNodeChanged);
    _effectiveController.addListener(_handleTextChanged);

    _obscureText = _isPasswordKeyboardType;
  }

  void _handleFocusNodeChanged() => setState(() {});
  void _handleTextChanged() {
    setState(() {
      _clearIconVisible = _effectiveController.text.isNotEmpty;
    });
  }

  Widget _buildWrapper(Widget child) {
    return DefaultTextStyle.merge(
      style: TextStyle(fontWeight: FontWeight.bold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          if (widget.label != null || widget.labelActions != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null) widget.label!,
                if (widget.labelActions != null &&
                    widget.labelActions!.isNotEmpty)
                  Padding(
                    padding: widget.labelActionsPadding,
                    child: Row(children: [...widget.labelActions!]),
                  ),
              ],
            ),
          child,
        ],
      ),
    );
  }

  Widget _buildClearIcon() {
    if (_effectiveFocusNode.hasFocus == false) return SizedBox.shrink();
    if (_clearIconVisible == false || widget.readonly == true) {
      return SizedBox.shrink();
    }

    /// 清空图标
    return GestureDetector(
      onTap: () => _effectiveController.clear(),
      child: Icon(Icons.clear),
    );
  }

  Widget _buildRandomGenIcon() {
    if (widget.readonly == true || widget.showRandomGenButton == false) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => widget.onRandomGen?.call(widget.keyboardType),
      child: Icon(Icons.autorenew_rounded),
    );
  }

  Widget _buildPwdVisibleIcon() {
    if (_isPasswordKeyboardType == false) return SizedBox.shrink();

    /// 密文显示与隐藏
    return GestureDetector(
      onTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      child: Icon(
        _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusNodeChanged);
    _effectiveController.removeListener(_handleTextChanged);

    if (widget.controller == null) {
      _internalController.dispose();
    }
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildWrapper(
      GestureDetector(
        onTap: widget.onTap,
        child: FormField<String>(
          initialValue: _effectiveController.text,
          validator: (value) {
            return widget.validator?.call(value);
          },
          enabled: widget.enabled,
          builder: (field) {
            // 确保FormField与controller同步
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (field.value != _effectiveController.text) {
                field.didChange(_effectiveController.text);
              }
            });

            return InputDecorator(
              isFocused: widget.focusNode?.hasFocus ?? false,
              decoration: InputDecoration(
                errorText: field.errorText,
                enabled: widget.enabled,
                contentPadding: const EdgeInsets.all(0),
                // 固定当校验时自动撑开的高度
                // https://stackoverflow.com/questions/56674596/validator-error-message-changes-textformfields-height/70828619#70828619
                helperText: widget.validator != null ? ' ' : null,
                border: WidgetStateInputBorder.resolveWith((states) {
                  if (states.contains(WidgetState.error)) {
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    );
                  }

                  if (states.contains(WidgetState.focused)) {
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    );
                  }

                  return OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          DividerTheme.of(context).color ??
                          Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: widget.iconsAlignment,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      // Prefix icons
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          _isMultiLine ? 14 : 0,
                          4,
                          0,
                        ),
                        child: widget.prefixIcon,
                      ),
                      // TextField
                      Expanded(
                        child: IgnorePointer(
                          // 解决外层GestureDetector接收整个大小的onTap事件
                          ignoring: widget.onTap != null,
                          child: TextField(
                            controller: _effectiveController,
                            focusNode: _effectiveFocusNode,
                            maxLines: widget.maxLines,
                            enabled: widget.enabled,
                            readOnly: widget.readonly,
                            obscureText: _obscureText,
                            keyboardType: widget.keyboardType,
                            textInputAction: widget.textInputAction,
                            textAlign: widget.textAlign,
                            inputFormatters: widget.inputFormatters,
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              contentPadding: const EdgeInsets.fromLTRB(
                                0,
                                20,
                                0,
                                12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              field.didChange(value);
                              // 1. 输入时 清空错误
                              if (field.hasError) {
                                field.reset();
                              }
                              // 2. 生成的 text也要 didChange
                              widget.onChanged?.call(value);
                            },
                          ),
                        ),
                      ),

                      // Suffix icons
                      widget.suffixIcon ?? _buildSuffixIcons(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuffixIcons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, _isMultiLine ? 14 : 4, 4, 4),
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildClearIcon(),
          _buildRandomGenIcon(),
          _buildPwdVisibleIcon(),
          // Custom suffix icons
          ...?widget.suffixIcons,
        ],
      ),
    );
  }
}
