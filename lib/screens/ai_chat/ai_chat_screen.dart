import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../providers/ai_chat_provider.dart';
import '../../services/ai_chat_service.dart';

/// Assistant IA An-Nour pour poser des questions sur l'islam.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatProvider);
    final isDark = context.isDarkMode;

    ref.listen<AiChatState>(aiChatProvider, (prev, next) {
      if (next.messages.length != prev?.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.emerald, AppColors.emeraldDark],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assistant An-Nour', style: TextStyle(fontSize: 16)),
                  Text(
                    'Pose tes questions sur l\'islam',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Effacer la conversation',
              onPressed: () => ref.read(aiChatProvider.notifier).clearMessages(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _WelcomeView(onSuggestionTap: (s) {
                    ref.read(aiChatProvider.notifier).sendMessage(s);
                    _scrollToBottom();
                  })
                : _MessageList(
                    messages: state.messages,
                    isLoading: state.isLoading,
                    scrollController: _scrollController,
                  ),
          ),
          if (state.error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: context.textTheme.bodySmall?.copyWith(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 16, color: Colors.red[700]),
                    onPressed: () => ref.read(aiChatProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
          _InputBar(
            controller: _controller,
            isLoading: state.isLoading,
            onSend: _send,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Liste des messages
// ──────────────────────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isLoading,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return _TypingIndicator(isDark: isDark);
        }
        final msg = messages[index];
        return _MessageBubble(message: msg, isDark: isDark)
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.05);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isDark});

  final ChatMessage message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final isArabic = _containsArabic(message.content);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.emerald
                    : (isDark ? AppColors.darkCard : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
              ),
              child: isArabic && !isUser
                  ? Text(
                      message.content,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.8,
                        color: isUser ? Colors.white : null,
                      ),
                      textDirection: TextDirection.rtl,
                    )
                  : SelectableText(
                      message.content,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.white : null,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: const Icon(Icons.person_rounded, size: 16, color: AppColors.goldDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
      child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.emerald),
    );
  }

  bool _containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }
}

// ──────────────────────────────────────────────────────────────
// Indicateur de saisie
// ──────────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
            child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.emerald),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.2, 1.2),
                      duration: 600.ms,
                      delay: (i * 200).ms,
                    );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Vue d'accueil avec suggestions
// ──────────────────────────────────────────────────────────────
class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onSuggestionTap});

  final void Function(String) onSuggestionTap;

  static const _suggestions = [
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Explique une sourate',
      'prompt': 'Peux-tu m\'expliquer la Sourate Al-Fatiha et son contexte de révélation ?',
    },
    {
      'icon': Icons.auto_stories_rounded,
      'title': 'Trouve un hadith',
      'prompt': 'Trouve-moi un hadith sur l\'importance de la prière en groupe.',
    },
    {
      'icon': Icons.access_time_rounded,
      'title': 'Horaires de prière',
      'prompt': 'Quelles sont les prières obligatoires et combien de rakats pour chacune ?',
    },
    {
      'icon': Icons.volunteer_activism_rounded,
      'title': 'La zakat',
      'prompt': 'Comment calcule-t-on la zakat et quel est le taux minimum (nisab) ?',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.emerald, AppColors.emeraldDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 20),
            Text(
              'Assistant An-Nour',
              style: context.textTheme.headlineMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Pose tes questions sur le Coran, les hadiths,\nla prière, la jurisprudence et plus encore.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: _suggestions.map((s) {
                final index = _suggestions.indexOf(s);
                return _SuggestionCard(
                  icon: s['icon'] as IconData,
                  title: s['title'] as String,
                  onTap: () => onSuggestionTap(s['prompt'] as String),
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(delay: (400 + index * 80).ms)
                    .slideY(begin: 0.1);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.emerald, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: context.textTheme.labelLarge?.copyWith(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Barre de saisie
// ──────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.isDark,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoal : AppColors.offWhite,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Pose ta question...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? Container(
                      key: const ValueKey('loading'),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.emerald,
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('send'),
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: onSend,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
