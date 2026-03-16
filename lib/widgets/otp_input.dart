import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/utils/app_colors.dart';

/// OTP验证码输入框组件 - 改进版
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const OtpInput({
    Key? key,
    this.length = 5,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
  }) : super(key: key);

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // 自动聚焦第一个输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // 输入了数字，移动到下一个框
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // 最后一个框，取消焦点
        _focusNodes[index].unfocus();
      }
    }

    // 通知输入变化
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);

    // 检查是否全部填完
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AspectRatio(
              aspectRatio: 1,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  // 处理退格键
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    if (_controllers[index].text.isEmpty && index > 0) {
                      // 当前框为空，删除前一个框的内容并聚焦
                      _controllers[index - 1].clear();
                      _focusNodes[index - 1].requestFocus();

                      // 通知变化
                      final code = _controllers.map((c) => c.text).join();
                      widget.onChanged?.call(code);
                    }
                  }
                },
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  obscureText: widget.obscureText,
                  maxLength: 1,
                  showCursor: false, // 极致简约，隐藏光标
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.pageBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    if (value.length > 1) {
                      // 防止粘贴多个字符
                      _controllers[index].text = value[0];
                      _controllers[index].selection =
                          TextSelection.fromPosition(
                        TextPosition(offset: 1),
                      );
                    }
                    _onChanged(value, index);
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
