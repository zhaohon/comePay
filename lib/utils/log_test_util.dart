import 'package:flutter/material.dart';
import 'package:comecomepay/utils/logger.dart';
import 'dart:convert';

/// 测试工具 - 用于验证完整的 API 响应日志输出
/// 使用方法：在任意位置调用 LogTestUtil.testLongResponse(responseData)
class LogTestUtil {
  /// 测试长 JSON 响应的日志输出
  static void testLongResponse(Map<String, dynamic> responseData) {
    Logger.response(
      'GET',
      'https://app.comecomepay.com/api/v1/wallet/',
      200,
      responseData,
      const Duration(milliseconds: 773),
    );
  }

  /// 测试超长文本输出
  static void testVeryLongText() {
    final testData = {
      'status': 'success',
      'wallet': {
        'balances': List.generate(20, (index) {
          return {
            'id': index + 1,
            'currency': 'TEST_$index',
            'balance': index * 100.5,
            'main_coin_type': index,
            'coin_type': index,
            'symbol': 'SYM_$index',
            'decimals': 6,
            'token_status': 0,
            'main_symbol': '',
            'logo': 'https://example.com/coin_$index.png',
            'coin_name': 'TEST COIN $index',
            'address': 'ADDRESS_${index}_${'x' * 50}',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
        }),
      },
      'additional_data': {
        'very_long_string': 'A' * 2000, // 超长字符串测试
        'nested_array': List.generate(
            10,
            (i) => {
                  'item': i,
                  'data': List.generate(10, (j) => 'value_${i}_$j'),
                }),
      },
    };

    print('🧪 测试超长 JSON 输出...');
    Logger.response(
      'GET',
      'http://test.com/api/test',
      200,
      testData,
      const Duration(milliseconds: 500),
    );
    print('✅ 测试完成 - 请在 DevTools Logging 选项卡查看完整输出');
  }

  /// 在 DevTools 中显示帮助信息
  static void showHelp() {
    debugPrint('''
╔══════════════════════════════════════════════════════════╗
║      如何在 DevTools 中查看完整的 API 响应数据？          ║
╚══════════════════════════════════════════════════════════╝

1. 打开 Flutter DevTools

2. 点击顶部的 "Logging" 选项卡

3. 热重启应用（按 R 键）

4. 触发网络请求

5. 在 Logging 中你会看到：
   - 左侧：日志级别和名称（如 "INFO [RESPONSE]"）
   - 右侧：日志消息
   - 下方：完整的 JSON 数据（可展开查看）

6. 点击日志条目可以：
   - 查看完整的 JSON 数据
   - 复制数据到剪贴板
   - 展开/折叠 JSON 结构

📝 提示：
- JSON 数据会以格式化的形式显示（带缩进）
- 可以使用搜索功能过滤日志
- 完整数据不会被截断！

🔧 如需测试，请调用：
   LogTestUtil.testVeryLongText()
''');
  }
}
