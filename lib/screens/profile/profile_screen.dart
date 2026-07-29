import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/extensions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: context.textTheme.headlineMedium,
                  ),
                  Text(
                    AppConstants.appTagline,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _ProfileTile(
                icon: Icons.favorite_rounded,
                title: 'Favoris',
                subtitle: 'Sourates, douas et hadiths',
                onTap: () => context.push('/favorites'),
              ),
              _ProfileTile(
                icon: Icons.settings_rounded,
                title: 'Paramètres',
                subtitle: 'Langue, thème, notifications',
                onTap: () => context.push('/settings'),
              ),
              _ProfileTile(
                icon: Icons.explore_rounded,
                title: 'Qibla',
                subtitle: 'Direction de La Mecque',
                onTap: () => context.push('/qibla'),
              ),
              _ProfileTile(
                icon: Icons.touch_app_rounded,
                title: 'Tasbih',
                subtitle: 'Compteur de dhikr',
                onTap: () => context.push('/tasbih'),
              ),
              _ProfileTile(
                icon: Icons.auto_stories_rounded,
                title: 'Hadiths',
                subtitle: 'Collection de hadiths authentiques',
                onTap: () => context.push('/hadiths'),
              ),
              _ProfileTile(
                icon: Icons.calendar_month_rounded,
                title: 'Calendrier islamique',
                subtitle: 'Date hijri et événements',
                onTap: () => context.push('/calendar'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.emerald.withValues(alpha: 0.1),
        child: Icon(icon, color: AppColors.emerald),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
