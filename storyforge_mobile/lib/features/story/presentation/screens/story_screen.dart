import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/story_message.dart';
import '../../data/models/story_model.dart';
import '../providers/story_provider.dart';
import '../providers/websocket_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  final int storyId;

  const StoryScreen({super.key, required this.storyId});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final story = ref.read(storyProvider(widget.storyId)).value;
      if (story != null) {
        ref.read(websocketProvider.notifier).connect(
          widget.storyId,
          history: story.segments,
          initialTurnUserId: story.currentTurn,
          initialTurnUsername: story.currentTurnUsername,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(websocketProvider.notifier).sendTurn(text);
      _inputController.clear();
    }
  }

  void _onSelectBranch(int branchId) {
    ref.read(websocketProvider.notifier).selectBranch(branchId);
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyProvider(widget.storyId));
    final wsState = ref.watch(websocketProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    // Connect WebSocket when story is loaded
    ref.listen(storyProvider(widget.storyId), (previous, next) {
      if (next is AsyncData && !wsState.isConnected) {
        final story = next.requireValue;
        ref.read(websocketProvider.notifier).connect(
          widget.storyId,
          history: story.segments,
          initialTurnUserId: story.currentTurn,
          initialTurnUsername: story.currentTurnUsername,
        );
      }
    });

    final bool isMyTurn = wsState.turnUserId != null && 
                         currentUser != null && 
                         wsState.turnUserId == int.tryParse(currentUser.id);

    final bool isOwner = storyAsync.maybeWhen(
      data: (s) => currentUser != null && s.ownerId == int.tryParse(currentUser.id),
      orElse: () => false,
    );

    return Hero(
      tag: 'story-${widget.storyId}',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(appRouterPrvdr).go('/dashboard');
            },
          ),
          title: storyAsync.when(
            data: (story) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: GoogleFonts.cinzel(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  wsState.isVoting 
                    ? 'VOTING PHASE' 
                    : (isMyTurn ? 'YOUR TURN' : 'Waiting for ${wsState.turnUsername ?? '...'}'),
                  style: TextStyle(
                    color: wsState.isVoting 
                      ? AppColors.tertiary 
                      : (isMyTurn ? AppColors.primaryLight : AppColors.textMuted),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Text('Error'),
          ),
          actions: [
            _ConnectionIndicator(isConnected: wsState.isConnected),
            const SizedBox(width: 8),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                _ReconnectingBanner(isVisible: !wsState.isConnected),
                Expanded(
                  child: storyAsync.when(
                    data: (story) {
                      if (story.status == 'lobby') {
                        return _LobbyView(
                          story: story,
                          isOwner: isOwner,
                          onStart: () => ref.read(storyProvider(widget.storyId).notifier).startStory(),
                        );
                      }
                      
                      return Stack(
                        children: [
                          if (wsState.messages.isEmpty && !wsState.isAiTyping && !wsState.isVoting)
                            _EmptyStoryState()
                          else
                            ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              reverse: true, // Newest at bottom
                              itemCount: wsState.messages.length + 
                                       (wsState.isAiTyping ? 1 : 0) + 
                                       (wsState.isVoting ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (wsState.isVoting && index == 0) {
                                  return _VotingInterface(
                                    branches: wsState.branches,
                                    onSelect: (id) {
                                      HapticFeedback.mediumImpact();
                                      _onSelectBranch(id);
                                    },
                                  );
                                }
                                
                                final typingIndex = wsState.isVoting ? 1 : 0;
                                if (wsState.isAiTyping && index == typingIndex) {
                                  return const _AiTypingIndicator();
                                }
                                
                                final messageOffset = (wsState.isAiTyping ? 1 : 0) + (wsState.isVoting ? 1 : 0);
                                final messageIndex = index - messageOffset;
                                
                                if (messageIndex < 0) return const SizedBox.shrink();
        
                                final message = wsState.messages.reversed.toList()[messageIndex];
                                return _MessageBubble(message: message);
                              },
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                ),
                storyAsync.maybeWhen(
                  data: (story) => story.status == 'lobby' 
                      ? const SizedBox.shrink() 
                      : (!wsState.isVoting ? _InputBar(
                          controller: _inputController,
                          onSend: () {
                            HapticFeedback.lightImpact();
                            _onSend();
                          },
                          isDisabled: !isMyTurn || wsState.isAiTyping,
                          hintText: isMyTurn ? 'Continue the story...' : 'Wait for your turn...',
                        ) : const SizedBox.shrink()),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyView extends StatelessWidget {
  final StoryModel story;
  final bool isOwner;
  final VoidCallback onStart;

  const _LobbyView({
    required this.story,
    required this.isOwner,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.meeting_room_rounded, size: 80, color: AppColors.primaryLight),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 32),
          Text(
            'Story Lobby',
            style: GoogleFonts.cinzel(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for participants to gather...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          _buildParticipantsList(),
          const SizedBox(height: 48),
          if (isOwner)
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
              ),
              child: Text(
                'START STORY',
                style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ).animate().shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryLight, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Only the owner can start the forge.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    // Note: We need participants list in StoryModel to show them here.
    // For now we just show a simple count or placeholder if participants field is added.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_rounded, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 12),
            Text(
              'FELLOW SCRIBES',
              style: GoogleFonts.cinzel(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Participants will appear here once the journey begins.',
          style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _VotingInterface extends StatelessWidget {
  final List<Map<String, dynamic>> branches;
  final Function(int) onSelect;

  const _VotingInterface({required this.branches, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.alt_route, color: AppColors.tertiary, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI HAS FORKED THE PATH',
                style: GoogleFonts.cinzel(
                  color: AppColors.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...branches.map((branch) => _BranchCard(
          content: branch['content'] ?? '',
          onTap: () => onSelect(branch['id']),
        )),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class _BranchCard extends StatelessWidget {
  final String content;
  final VoidCallback onTap;

  const _BranchCard({required this.content, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.tertiary.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'SELECT PATH',
                      style: TextStyle(
                        color: AppColors.tertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.tertiary, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  const _ConnectionIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected ? Colors.green : Colors.grey,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .scale(
       duration: 1500.ms,
       begin: const Offset(0.8, 0.8),
       end: const Offset(1.3, 1.3),
       curve: Curves.easeInOut,
     )
     .then()
     .scale(
       duration: 1500.ms,
       begin: const Offset(1.3, 1.3),
       end: const Offset(0.8, 0.8),
       curve: Curves.easeInOut,
     );
  }
}

class _ReconnectingBanner extends StatelessWidget {
  final bool isVisible;
  const _ReconnectingBanner({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      height: isVisible ? 32 : 0,
      width: double.infinity,
      color: Colors.amber.withOpacity(0.9),
      child: isVisible
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lost Connection - Reconnecting...',
                  style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : null,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final StoryMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'StoryForge AI',
                style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isUser ? AppColors.primaryGradient : null,
              color: isUser ? null : AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              border: isUser ? null : const Border(left: BorderSide(color: AppColors.primary, width: 2)),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: isUser ? 0.1 : -0.1, end: 0),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTypingIndicator extends StatelessWidget {
  const _AiTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'StoryForge AI',
              style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border(left: BorderSide(color: AppColors.primary, width: 2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                ).animate(onPlay: (controller) => controller.repeat())
                 .scale(duration: 600.ms, delay: (i * 200).ms, begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2))
                 .then()
                 .scale(duration: 600.ms, begin: const Offset(1.2, 1.2), end: const Offset(0.5, 0.5)),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDisabled;
  final String hintText;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isDisabled,
    required this.hintText,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() => _hasText = widget.controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isDisabled,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: (widget.isDisabled || !_hasText) ? null : widget.onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: (widget.isDisabled || !_hasText) ? null : AppColors.primaryGradient,
                color: (widget.isDisabled || !_hasText) ? AppColors.surfaceElevated : null,
              ),
              child: Icon(
                Icons.send_rounded,
                color: (widget.isDisabled || !_hasText) ? AppColors.textMuted : Colors.white,
                size: 20,
              ),
            ).animate(target: (widget.isDisabled || !_hasText) ? 0 : 1)
             .scale(duration: 200.ms, begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ),
        ],
      ),
    );
  }
}

class _EmptyStoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_edu_rounded,
            size: 64,
            color: AppColors.primary.withOpacity(0.3),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .shimmer(duration: 2000.ms, color: AppColors.primaryLight),
          const SizedBox(height: 24),
          const Text(
            'Your story awaits...',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send the first message to forge your legend.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
