import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/services/zoho_chat_service.dart';

class MessageServiceCenterScreen extends StatefulWidget {
  const MessageServiceCenterScreen({super.key});

  @override
  State<MessageServiceCenterScreen> createState() =>
      _MessageServiceCenterScreenState();
}

class _MessageServiceCenterScreenState
    extends State<MessageServiceCenterScreen> {
  final ZohoChatService _chatService = ZohoChatService();
  double _progress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 添加监听器
    _chatService.addProgressListener(_onProgressChanged);
    _chatService.addLoadingListener(_onLoadingChanged);

    // 如果已经初始化，直接显示
    if (_chatService.isInitialized) {
      setState(() {
        _isLoading = false;
        _progress = 1.0;
      });
    }
  }

  @override
  void dispose() {
    // 移除监听器
    _chatService.removeProgressListener(_onProgressChanged);
    _chatService.removeLoadingListener(_onLoadingChanged);
    super.dispose();
  }

  void _onProgressChanged(double progress) {
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  void _onLoadingChanged(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  String _getLoadingMessage() {
    if (_progress < 0.3) {
      return 'Initializing connection...';
    } else if (_progress < 0.7) {
      return 'Loading chat service...';
    } else if (_progress < 0.9) {
      return 'Setting up secure channel...';
    } else {
      return 'Almost ready...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.messageServiceCenter,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _chatService.controller?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 使用全局单例的WebView
          _chatService.buildWebView(),

          // 加载动画（仅首次加载时显示）
          if (_isLoading && !_chatService.isInitialized)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(0xFFF3E8FF),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 客服图标
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFA855F7),
                            const Color(0xFF9333EA),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 标题
                    const Text(
                      'Connecting to Customer Service',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 副标题
                    Text(
                      'Setting up your chat session...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 进度条
                    SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFA855F7),
                            ),
                            minHeight: 4,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 加载步骤提示
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getLoadingMessage(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
