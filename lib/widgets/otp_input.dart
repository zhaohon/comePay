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
  late List<String> _oldValues;

  @override
  void initState() {
    super.initState();
    _oldValues = List.filled(widget.length, '');
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) {
        final node = FocusNode(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              _handleBackspace(index);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
        );
        // 当框获得焦点时自动全选其中的文字，以便每次输入都能直接覆盖原来的值
        node.addListener(() {
          if (node.hasFocus && _controllers[index].text.isNotEmpty) {
            // 需要微小的延迟来确保光标能在系统默认行为结束后被正确覆盖
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) {
                _controllers[index].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _controllers[index].text.length,
                );
              }
            });
          }
        });
        return node;
      },
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
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    String oldValue = _oldValues[index];

    if (cleanValue.length > 1) {
      // 检查是否是因为追加输入导致的两位数（比如原本是"1"，由于密码遮蔽无法全选，输入"2"变成了"12"）
      if (cleanValue.length == 2 && cleanValue.startsWith(oldValue)) {
        String newChar = cleanValue.substring(1);
        _controllers[index].text = newChar;
        _oldValues[index] = newChar;

        // 保持光标在文字之后以防继续删改
        _controllers[index].selection =
            const TextSelection.collapsed(offset: 1);

        if (index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        }
      } else {
        // 真正的多文本粘贴逻辑
        for (int i = 0; i < cleanValue.length; i++) {
          if (index + i < widget.length) {
            _controllers[index + i].text = cleanValue[i];
            _oldValues[index + i] = cleanValue[i];
          }
        }

        int nextFocusIndex = index + cleanValue.length;
        if (nextFocusIndex < widget.length) {
          _focusNodes[nextFocusIndex].requestFocus();
        } else {
          _focusNodes[widget.length - 1].requestFocus();
        }
      }
    } else if (cleanValue.isNotEmpty) {
      // 输入单个字符，移动到下一个
      _oldValues[index] = cleanValue;
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      _oldValues[index] = '';
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      // 如果当前框有内容，清除它
      _controllers[index].clear();
      _oldValues[index] = '';
    } else if (index > 0) {
      // 如果当前框为空，跳到前一个框并清除
      _controllers[index - 1].clear();
      _oldValues[index - 1] = '';
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
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
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                obscureText: widget.obscureText,
                showCursor: true, // 显示光标，方便定位
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                // 点击时全选，实现覆盖输入
                onTap: () {
                  if (_controllers[index].text.isNotEmpty) {
                    _controllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[index].text.length,
                    );
                  }
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // 允许粘贴验证码全长，而不是在系统层就切断它
                  LengthLimitingTextInputFormatter(widget.length),
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
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _onChanged(value, index),
              ),
            ),
          ),
        );
      }),
    );
  }
}
