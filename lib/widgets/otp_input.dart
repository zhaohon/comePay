import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/utils/app_colors.dart';

/// OTP验证码输入框组件 - 改进版
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInput({
    Key? key,
    this.length = 5,
    this.onCompleted,
    this.onChanged,
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
        return SizedBox(
          width: 60,
          height: 60,
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
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderActive, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderActive, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderActive, width: 2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                if (value.length > 1) {
                  // 防止粘贴多个字符
                  _controllers[index].text = value[0];
                  _controllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: 1),
                  );
                }
                _onChanged(value, index);
              },
              onTap: () {
                // 点击时选中所有文本，方便替换
                if (_controllers[index].text.isNotEmpty) {
                  _controllers[index].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controllers[index].text.length,
                  );
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
