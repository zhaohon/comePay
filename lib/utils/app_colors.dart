import 'package:flutter/material.dart';

/// App颜色配置
/// 统一管理所有颜色，方便维护和修改
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  // ==================== 背景色 ====================
  /// 页面背景色（浅紫灰）
  static const Color background = Color(0xFFF3F0F7);

  /// 页面通用背景色（Telegram风格浅灰）
  static const Color pageBackground = Color(0xFFEFEFF4);

  /// 卡片/输入框背景色（白色）
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ==================== 主色调 ====================
  /// 主紫色
  static const Color primary = Color(0xFFA855F7);

  /// 深紫色
  static const Color primaryDark = Color(0xFF9333EA);

  /// 浅紫色
  static const Color primaryLight = Color(0xFFDDD6FE);

  /// 粉红色
  static const Color accent = Color(0xFFEC4899);

  // ==================== 渐变色 ====================
  /// 主渐变（紫→粉）
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 进度条渐变
  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ==================== 辅助色 ====================
  /// 警告/强调黄色
  static const Color warning = Color(0xFFF59E0B);

  /// 成功绿色
  static const Color success = Color(0xFF10B981);

  /// 错误红色
  static const Color error = Color(0xFFEF4444);

  /// 信息色（使用主紫色）
  static const Color info = primary;

  // ==================== 文字色 ====================
  /// 主文字色（深灰黑）
  static const Color textPrimary = Color(0xFF1F2937);

  /// 次要文字色（中灰）
  static const Color textSecondary = Color(0xFF6B7280);

  /// 占位符文字色（浅灰）
  static const Color textPlaceholder = Color(0xFF9CA3AF);

  /// 禁用文字色
  static const Color textDisabled = Color(0xFFD1D5DB);

  // ==================== 边框色 ====================
  /// 默认边框色
  static const Color border = Color(0xFFE5E7EB);

  /// 活跃/焦点边框色（紫色）
  static const Color borderActive = Color(0xFFA855F7);

  /// 错误边框色
  static const Color borderError = Color(0xFFEF4444);

  // ==================== 其他 ====================
  /// 分割线颜色
  static const Color divider = Color(0xFFE5E7EB);

  /// 阴影颜色
  static const Color shadow = Color(0x0A000000);

  /// 白色
  static const Color white = Color(0xFFFFFFFF);

  /// 黑色
  static const Color black = Color(0xFF000000);
}
