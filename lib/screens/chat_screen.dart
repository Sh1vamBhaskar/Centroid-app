import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final int otherUserId;
  final String otherUserName;
  final String? otherUserPicture;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPicture,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController =
  TextEditingController();
  final ScrollController _scrollController =
  ScrollController();

  List<ChatMessage> _messages = [];

  bool _isLoading = true;
  bool _isConnecting = true;
  String? _error;

  // Temporary current-user ID.
  //
  // We need the actual logged-in user's ID to decide
  // which side of the chat bubble a message belongs on.
  //
  // We will replace this with the authenticated user's
  // actual ID once the profile/session endpoint is available.
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // --------------------------------------------------
      // Load current user's profile
      // --------------------------------------------------

      final profile = await ApiService.getMyProfile();

      if (!mounted) return;

      setState(() {
        _currentUserId =
            (profile['userId'] as num).toInt();
      });

      // --------------------------------------------------
      // Load previous messages
      // --------------------------------------------------

      final messages = await ApiService.getMessages(
        widget.conversationId,
      );

      if (!mounted) return;

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      _scrollToBottom();

      // --------------------------------------------------
      // Connect to WebSocket
      // --------------------------------------------------

      await _chatService.connect(
        conversationId: widget.conversationId,
        onMessage: _handleIncomingMessage,
        onConnected: () {
          if (!mounted) return;

          setState(() {
            _isConnecting = false;
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isConnecting = false;
            _error = error;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isConnecting = false;
        _error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }
  void _handleIncomingMessage(ChatMessage message) {
    if (!mounted) return;

    // Prevent duplicate messages.
    final alreadyExists = _messages.any(
          (existing) => existing.id == message.id,
    );

    if (alreadyExists) {
      return;
    }

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
  }

  void _sendMessage() {
    final content =
    _messageController.text.trim();

    if (content.isEmpty) {
      return;
    }

    if (!_chatService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chat connection is not ready yet.',
          ),
        ),
      );
      return;
    }

    _chatService.sendMessage(
      conversationId: widget.conversationId,
      content: content,
    );

    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration:
          const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isConnecting)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primary,
            ),

          Expanded(
            child: _buildMessageArea(),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      titleSpacing: 0,

      title: Row(
        children: [
          _buildAvatar(),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _isConnecting
                      ? 'Connecting...'
                      : 'Connected',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnecting
                        ? AppColors.textSecondary
                        : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasPicture =
        widget.otherUserPicture != null &&
            widget.otherUserPicture!.isNotEmpty;

    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primarySoft,
      ),
      child: ClipOval(
        child: hasPicture
            ? Image.network(
          widget.otherUserPicture!,
          fit: BoxFit.cover,
          errorBuilder:
              (
              context,
              error,
              stackTrace,
              ) {
            return const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 22,
            );
          },
        )
            : const Icon(
          Icons.person_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE AREA
  // ============================================================

  Widget _buildMessageArea() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration:
                const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 29,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Unable to open chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isConnecting = true;
                    _error = null;
                  });

                  _initializeChat();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration:
                const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Start the conversation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Say hello to ${widget.otherUserName}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(
          _messages[index],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(
      ChatMessage message,
      ) {
    final isMine =
        _currentUserId != null &&
            message.senderId == _currentUserId;

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
          MediaQuery.of(context).size.width *
              0.78,
        ),
        margin: const EdgeInsets.only(
          bottom: 9,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isMine ? 18 : 5,
            ),
            bottomRight: Radius.circular(
              isMine ? 5 : 18,
            ),
          ),
          border: isMine
              ? null
              : Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: isMine
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? Colors.white70
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE INPUT
  // ============================================================

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          9,
          12,
          10,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints:
                const BoxConstraints(
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                  BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization:
                  TextCapitalization.sentences,
                  decoration:
                  const InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                  ),
                  onSubmitted: (_) {
                    _sendMessage();
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _sendMessage,
                customBorder:
                const CircleBorder(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME
  // ============================================================

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();

    final hour = localTime.hour == 0
        ? 12
        : localTime.hour > 12
        ? localTime.hour - 12
        : localTime.hour;

    final minute =
    localTime.minute.toString().padLeft(
      2,
      '0',
    );

    final period =
    localTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

}