import 'package:flutter/material.dart';
import 'package:comecomepay/utils/token_refresh_tester.dart';

/// Token刷新测试页面
///
/// 可以临时添加到应用中用于测试token刷新功能
/// 使用方法：在任意地方导航到此页面
/// Navigator.push(context, MaterialPageRoute(builder: (_) => TokenRefreshTestPage()));
class TokenRefreshTestPage extends StatelessWidget {
  const TokenRefreshTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token刷新测试'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明卡片
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '测试说明',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '此页面用于测试Token自动刷新功能。\n'
                    '点击下方按钮模拟token过期，然后返回首页或其他页面触发API请求，'
                    '观察是否自动刷新token。',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 测试按钮组
          _buildTestButton(
            context,
            icon: Icons.refresh,
            title: '测试1: Access Token过期',
            subtitle: '模拟24小时后access token过期',
            color: Colors.orange,
            onPressed: () async {
              await TokenRefreshTester.simulateAccessTokenExpiry();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Access Token已设置为过期\n'
                        '请返回首页或刷新任意页面查看效果'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),

          _buildTestButton(
            context,
            icon: Icons.error_outline,
            title: '测试2: Refresh Token过期',
            subtitle: '模拟7天后refresh token也过期',
            color: Colors.red,
            onPressed: () async {
              final confirm = await _showConfirmDialog(
                context,
                '确认操作',
                '这将模拟refresh token过期，\n'
                    '之后需要重新登录。\n'
                    '是否继续？',
              );

              if (confirm == true) {
                await TokenRefreshTester.simulateRefreshTokenExpiry();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 两个Token都已设置为过期\n'
                          '请触发API请求，应该会清除数据'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          _buildTestButton(
            context,
            icon: Icons.info_outline,
            title: '查看Token状态',
            subtitle: '显示当前token信息',
            color: Colors.blue,
            onPressed: () {
              TokenRefreshTester.checkTokenStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Token状态已输出到控制台\n'
                      '请查看DevTools的Logging标签'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildTestButton(
            context,
            icon: Icons.help_outline,
            title: '显示测试指南',
            subtitle: '查看详细的测试步骤',
            color: Colors.green,
            onPressed: () {
              TokenRefreshTester.showTestGuide();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ 测试指南已输出到控制台'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // 预期结果说明
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '预期结果',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Access Token过期：\n'
                    '• 自动刷新token（用户无感知）\n'
                    '• 数据正常加载\n\n'
                    'Refresh Token过期：\n'
                    '• 清除本地数据\n'
                    '• 需要重新登录',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
