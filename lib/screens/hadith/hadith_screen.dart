import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../providers/dua_provider.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  String? _selectedTheme;

  @override
  Widget build(BuildContext context) {
    final hadithsAsync = ref.watch(hadithsProvider);
    final themesAsync = ref.watch(hadithThemesProvider);
    final query = ref.watch(hadithSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hadiths')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) =>
                  ref.read(hadithSearchProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Rechercher un hadith...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          themesAsync.when(
            data: (themes) => SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('Tous'),
                    selected: _selectedTheme == null,
                    onSelected: (_) => setState(() => _selectedTheme = null),
                    selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                  ),
                  ...themes.map(
                    (theme) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(theme),
                        selected: _selectedTheme == theme,
                        onSelected: (_) =>
                            setState(() => _selectedTheme = theme),
                        selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: hadithsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorStateWidget(message: e.toString()),
              data: (hadiths) {
                var filtered = hadiths;
                if (_selectedTheme != null) {
                  filtered =
                      filtered.where((h) => h.theme == _selectedTheme).toList();
                }
                if (query.isNotEmpty) {
                  final q = query.toLowerCase();
                  filtered = filtered
                      .where((h) =>
                          h.english.toLowerCase().contains(q) ||
                          h.theme.toLowerCase().contains(q) ||
                          h.narrator.toLowerCase().contains(q),)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.auto_stories_outlined,
                    title: 'Aucun hadith trouvé',
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final hadith = filtered[index];
                    return ListTile(
                      title: Text(
                        hadith.english,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${hadith.theme} • ${hadith.reference}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          context.push('/hadith/${hadith.id}', extra: hadith),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
