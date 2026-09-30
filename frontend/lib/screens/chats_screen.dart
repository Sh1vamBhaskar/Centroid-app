import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> conversations = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future<void> loadChats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getPendingInteractions(),
        ApiService.getMyConversations(),
      ]);

      if (!mounted) return;

      setState(() {
        requests = results[0];
        conversations = results[1];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> acceptRequest(
      Map<String, dynamic> request,
      ) async {
    final interactionId =
    (request['id'] as num).toInt();

    try {
      // Accept the connection request.
      await ApiService.acceptInteraction(
        interactionId,
      );

      // Create the chat conversation.
      await ApiService.createConversationFromInteraction(
        interactionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection accepted'),
        ),
      );

      // Refresh requests and conversations.
      await loadChats();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  Future<void> declineRequest(
      Map<String, dynamic> request,
      ) async {
    final interactionId =
    (request['id'] as num).toInt();

    try {
      await ApiService.declineInteraction(
        interactionId,
      );

      if (!mounted) return;

      setState(() {
        requests.remove(request);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request declined'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  void openConversation(
      Map<String, dynamic> conversation,
      ) {
    final conversationId =
    (conversation['id'] as num).toInt();

    final otherUserId =
    (conversation['otherUserId'] as num).toInt();

    final otherUserName =
        conversation['otherUserName']?.toString() ??
            'User';

    final otherUserPicture =
    conversation['otherUserPicture']?.toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversationId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPicture: otherUserPicture,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chats',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 3),
                Text(
                  'Requests and conversations',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primarySoft,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: loadChats,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.refresh_rounded,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 27,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Could not load chats',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: loadChats,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text('Try again'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadChats,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24,
        ),
        children: [
          _buildRequestsSection(),
          const SizedBox(height: 28),
          _buildConversationsSection(),
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              size: 19,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Requests',
              style: AppTextStyles.heading,
            ),
            if (requests.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          _buildEmptySection(
            icon: Icons.person_add_alt_1_rounded,
            text: 'No connection requests',
          )
        else
          ...requests.map(
                (request) => Padding(
              padding:
              const EdgeInsets.only(bottom: 12),
              child: _RequestCard(
                request: request,
                onAccept: () =>
                    acceptRequest(request),
                onDecline: () =>
                    declineRequest(request),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConversationsSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 19,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Conversations',
              style: AppTextStyles.heading,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (conversations.isEmpty)
          _buildEmptySection(
            icon: Icons.chat_bubble_outline_rounded,
            text: 'No conversations yet',
          )
        else
          ...conversations.map(
                (conversation) => Padding(
              padding:
              const EdgeInsets.only(bottom: 10),
              child: _ConversationCard(
                conversation: conversation,
                onTap: () =>
                    openConversation(conversation),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 26,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final senderId = (request['senderId'] as num).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User #$senderId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Wants to connect with you',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(
                      Icons.check_rounded,
                      size: 18,
                    ),
                    label: const Text('Accept'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _ConversationCard extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        conversation['otherUserName']?.toString() ??
            'User';

    final picture =
    conversation['otherUserPicture']
        ?.toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              _ProfileAvatar(
                name: name,
                picture: picture,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open conversation',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? picture;

  const _ProfileAvatar({
    required this.name,
    required this.picture,
  });

  @override
  Widget build(BuildContext context) {
    final hasPicture =
        picture != null &&
            picture!.trim().isNotEmpty;

    if (hasPicture) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primarySoft,
        backgroundImage: NetworkImage(picture!),
      );
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor:
      AppColors.primary.withValues(
        alpha: 0.10,
      ),
      child: Text(
        name.isNotEmpty
            ? name[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}
