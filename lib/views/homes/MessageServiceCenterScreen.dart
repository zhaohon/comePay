import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/viewmodels/messageservicecenter_viewmodel.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:intl/intl.dart';

class MessageServiceCenterScreen extends StatefulWidget {
  const MessageServiceCenterScreen({super.key});

  @override
  State<MessageServiceCenterScreen> createState() =>
      _MessageServiceCenterScreenState();
}

class _MessageServiceCenterScreenState
    extends State<MessageServiceCenterScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<MessageServiceCenterViewModel>(context, listen: false);
      viewModel.getChatHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      ),
      body: Consumer<MessageServiceCenterViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.chatHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.chatHistory.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet. Start a conversation!',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.refreshChatHistory();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.chatHistory.length +
                        (viewModel.isLoadingHistoryMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && viewModel.isLoadingHistoryMore) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final actualIndex =
                          viewModel.isLoadingHistoryMore ? index - 1 : index;
                      if (actualIndex < 0) return const SizedBox.shrink();

                      final msg = viewModel.chatHistory[actualIndex];
                      final isUser = msg.sender.toLowerCase() == 'user';
                      final messageText = msg.message;
                      final createdAt = msg.createdAt;
                      String timeString = "";
                      try {
                        timeString = DateFormat('HH:mm').format(createdAt);
                      } catch (e) {
                        timeString = "Unknown";
                      }

                      // Load more when reaching near the top (only if not already loading)
                      if (actualIndex == 0 &&
                          !viewModel.isLoadingHistoryMore &&
                          viewModel.historyHasMorePages) {
                        viewModel.loadMoreChatHistory();
                      }

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform: Matrix4.translationValues(0, 0, 0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  isUser ? AppColors.primaryGradient : null,
                              color: isUser ? null : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messageText,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isUser
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    if (!msg.isRead && !isUser) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "Type Message",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: AppColors.primary),
                        onPressed: () async {
                          final viewModel =
                              Provider.of<MessageServiceCenterViewModel>(
                                  context,
                                  listen: false);
                          final message = _controller.text.trim();
                          if (message.isNotEmpty) {
                            try {
                              await viewModel.sendChatHistoryMessage(message);
                              _controller.clear();
                            } catch (e) {
                              // Show error message to user
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to send message: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
