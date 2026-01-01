import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 全局Zoho客服服务 - 确保客服插件只加载一次
class ZohoChatService {
  static final ZohoChatService _instance = ZohoChatService._internal();
  factory ZohoChatService() => _instance;
  ZohoChatService._internal();

  InAppWebViewController? _webViewController;
  bool _isInitialized = false;
  double _progress = 0;
  final List<Function(double)> _progressListeners = [];
  final List<Function(bool)> _loadingListeners = [];

  bool get isInitialized => _isInitialized;
  InAppWebViewController? get controller => _webViewController;

  void addProgressListener(Function(double) listener) {
    _progressListeners.add(listener);
  }

  void removeProgressListener(Function(double) listener) {
    _progressListeners.remove(listener);
  }

  void addLoadingListener(Function(bool) listener) {
    _loadingListeners.add(listener);
  }

  void removeLoadingListener(Function(bool) listener) {
    _loadingListeners.remove(listener);
  }

  void _notifyProgress(double progress) {
    _progress = progress;
    for (var listener in _progressListeners) {
      listener(progress);
    }
  }

  void _notifyLoading(bool isLoading) {
    for (var listener in _loadingListeners) {
      listener(isLoading);
    }
  }

  Widget buildWebView() {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: _getHtmlContent(),
        baseUrl: WebUri('https://app.comecomepay.com'),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        thirdPartyCookiesEnabled: true,
        cacheEnabled: true,
        clearCache: false,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        useHybridComposition: true,
        disableContextMenu: false,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        print('📱 [Zoho] WebView created (singleton)');
      },
      onLoadStart: (controller, url) {
        print('🔄 [Zoho] Loading started: $url');
        _notifyLoading(true);
      },
      onLoadStop: (controller, url) async {
        print('✅ [Zoho] Loading finished: $url');
        _isInitialized = true;
        _notifyLoading(false);
      },
      onProgressChanged: (controller, progress) {
        print('📊 [Zoho] Progress: $progress%');
        _notifyProgress(progress / 100);
      },
      onConsoleMessage: (controller, consoleMessage) {
        print('🖥️ [Zoho Console]: ${consoleMessage.message}');
      },
      onLoadError: (controller, url, code, message) {
        print('❌ [Zoho] Load error: $message');
      },
      onLoadHttpError: (controller, url, statusCode, description) {
        print('❌ [Zoho] HTTP error: $statusCode - $description');
      },
    );
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        html, body {
            width: 100%;
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e8eaf6 100%);
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 24px;
            height: 100%;
            overflow-y: auto;
        }
        .header {
            text-align: center;
            margin-bottom: 32px;
        }
        .icon-wrapper {
            width: 80px;
            height: 80px;
            margin: 0 auto 16px;
            background: linear-gradient(135deg, #A855F7 0%, #9333EA 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 24px rgba(168, 85, 247, 0.3);
        }
        .icon {
            font-size: 40px;
        }
        h1 {
            font-size: 24px;
            color: #1f2937;
            margin-bottom: 8px;
        }
        .subtitle {
            color: #6b7280;
            font-size: 14px;
        }
        
        .guide-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border: 1px solid rgba(168, 85, 247, 0.1);
        }
        .guide-title {
            font-size: 18px;
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .step {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
            align-items: start;
        }
        .step-number {
            width: 24px;
            height: 24px;
            background: linear-gradient(135deg, #A855F7 0%, #9333EA 100%);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 600;
            flex-shrink: 0;
        }
        .step-content {
            flex: 1;
            color: #4b5563;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .faq {
            margin-bottom: 12px;
        }
        .faq-question {
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 4px;
            font-size: 14px;
        }
        .faq-answer {
            color: #6b7280;
            font-size: 13px;
            line-height: 1.5;
        }
        
        .chat-button-hint {
            position: fixed;
            bottom: 100px;
            right: 24px;
            background: white;
            padding: 12px 16px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            max-width: 200px;
            animation: bounce 2s infinite;
            border: 2px solid #A855F7;
        }
        .chat-button-hint::after {
            content: '';
            position: absolute;
            bottom: -8px;
            right: 20px;
            width: 0;
            height: 0;
            border-left: 8px solid transparent;
            border-right: 8px solid transparent;
            border-top: 8px solid white;
        }
        .hint-text {
            font-size: 12px;
            color: #1f2937;
            font-weight: 500;
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            margin-bottom: 16px;
        }
        .status-dot {
            width: 6px;
            height: 6px;
            background: #059669;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="icon-wrapper">
                <div class="icon">💬</div>
            </div>
            <h1>Customer Service Center</h1>
            <p class="subtitle">We're here to help you 24/7</p>
            <div class="status-badge" id="statusBadge" style="display:none;">
                <span class="status-dot"></span>
                <span>Agent Online</span>
            </div>
        </div>

        <div class="guide-card">
            <div class="guide-title">
                💡 How to Start a Chat
            </div>
            <div class="step">
                <div class="step-number">1</div>
                <div class="step-content">
                    Click the <strong>blue chat button</strong> in the bottom-right corner
                </div>
            </div>
            <div class="step">
                <div class="step-number">2</div>
                <div class="step-content">
                    Type your question or concern
                </div>
            </div>
            <div class="step">
                <div class="step-number">3</div>
                <div class="step-content">
                    Our support team will respond to you shortly
                </div>
            </div>
        </div>

        <div class="guide-card">
            <div class="guide-title">
                ❓ Frequently Asked Questions
            </div>
            <div class="faq">
                <div class="faq-question">Q: What are your support hours?</div>
                <div class="faq-answer">A: Our team is available 24/7 to assist you.</div>
            </div>
            <div class="faq">
                <div class="faq-question">Q: How quickly will I get a response?</div>
                <div class="faq-answer">A: Most inquiries are answered within 2-5 minutes.</div>
            </div>
            <div class="faq">
                <div class="faq-question">Q: Can I attach files?</div>
                <div class="faq-answer">A: Yes, you can send images and documents through the chat.</div>
            </div>
            <div class="faq">
                <div class="faq-question">Q: Is my conversation secure?</div>
                <div class="faq-answer">A: Yes, all conversations are encrypted and confidential.</div>
            </div>
        </div>

        <div class="guide-card">
            <div class="guide-title">
                📧 Other Contact Methods
            </div>
            <div class="step-content">
                <p><strong>Email:</strong> support@comecomepay.com</p>
                <p style="margin-top:8px;"><strong>Response Time:</strong> Within 24 hours</p>
            </div>
        </div>
    </div>

    <div class="chat-button-hint" id="chatHint">
        <div class="hint-text">👉 Click here to start chatting!</div>
    </div>

    <script>
        console.log('[Zoho] Initializing SalesIQ (Global Instance)...');
        
        function showOnlineStatus() {
            var badge = document.getElementById('statusBadge');
            if (badge) {
                badge.style.display = 'inline-flex';
            }
        }
        
        function hideChatHint() {
            setTimeout(function() {
                var hint = document.getElementById('chatHint');
                if (hint) {
                    hint.style.display = 'none';
                }
            }, 10000);
        }
        
        window.\$zoho = window.\$zoho || {};
        window.\$zoho.salesiq = window.\$zoho.salesiq || {
            ready: function() {
                console.log('[Zoho] ✅ SalesIQ is ready (Global)!');
                showOnlineStatus();
                
                setTimeout(function() {
                    try {
                        if (window.\$zoho && window.\$zoho.salesiq && window.\$zoho.salesiq.floatwindow) {
                            window.\$zoho.salesiq.floatwindow.visible('show');
                            console.log('[Zoho] ✅ Chat window opened');
                            hideChatHint();
                        }
                    } catch(e) {
                        console.error('[Zoho] ❌ Error:', e);
                    }
                }, 2000);
            }
        };
    </script>
    
    <script 
        id="zsiqscript" 
        src="https://salesiq.zohopublic.com/widget?wc=siq08ab9b342cfc15548c359a0b37265cf12c83a97d3cb3709367f46e8ed175589b"
        onload="console.log('[Zoho] ✅ Script loaded (Global)')"
        onerror="console.error('[Zoho] ❌ Failed to load script')">
    </script>
</body>
</html>
''';
  }

  void openChat() {
    _webViewController?.evaluateJavascript(source: '''
      if (window.\$zoho && window.\$zoho.salesiq && window.\$zoho.salesiq.floatwindow) {
        window.\$zoho.salesiq.floatwindow.visible('show');
      }
    ''');
  }

  void closeChat() {
    _webViewController?.evaluateJavascript(source: '''
      if (window.\$zoho && window.\$zoho.salesiq && window.\$zoho.salesiq.floatwindow) {
        window.\$zoho.salesiq.floatwindow.visible('hide');
      }
    ''');
  }
}
