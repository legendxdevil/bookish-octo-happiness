import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/chat_message_model.dart';
import '../blocs/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatHistory());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(message: message));
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat History'),
                  content: const Text(
                    'Are you sure you want to clear all chat messages?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChatBloc>().add(ClearChat());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(LucideIcons.trash2),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.circleAlert,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }

                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return _EmptyState(
                      onSuggestionTap: (suggestion) {
                        _messageController.text = suggestion;
                        _sendMessage();
                      },
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _ChatBubble(
                        message: message,
                        showAvatar: index == 0 ||
                            state.messages[index - 1].sender != message.sender,
                      ).animate().fadeIn(duration: 200.ms);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about your finances...',
                        filled: true,
                        fillColor: colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        LucideIcons.send,
                        color: colorScheme.onPrimary,
                      ),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool showAvatar;

  const _ChatBubble({
    required this.message,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && showAvatar) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ] else if (!isUser) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: message.isTyping
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0, colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        _buildDot(200, colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        _buildDot(400, colorScheme.onSurfaceVariant),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUser
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(message.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUser
                                ? colorScheme.onPrimary.withOpacity(0.7)
                                : colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (isUser && showAvatar) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.user,
                size: 16,
                color: colorScheme.onSecondary,
              ),
            ),
          ] else if (isUser) ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildDot(int delay, Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(begin: 0.5, end: 1, duration: 600.ms, delay: delay.ms)
        .fade(begin: 0.3, end: 1);
  }
}

class _EmptyState extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const _EmptyState({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final suggestions = [
      'How am I doing financially?',
      'Suggest ways to save money',
      'Analyze my spending habits',
      'Help me create a budget',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 48,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your AI Financial Assistant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about your finances. I can analyze your spending, provide saving tips, and help you reach your financial goals.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Try asking:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () => onSuggestionTap(suggestion),
                  backgroundColor: colorScheme.surfaceVariant,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
