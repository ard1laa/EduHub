import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final user = prov.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.role == UserRole.admin
                              ? Icons.admin_panel_settings_rounded
                              : Icons.school_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.role == UserRole.admin ? 'Administrator' : 'Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(
                    label: 'Videos',
                    value: '${prov.totalVideos}',
                    icon: Icons.video_library_rounded,
                    color: AppColors.primary,
                  ),
                  _Divider(),
                  _ProfileStat(
                    label: 'Albums',
                    value: '${prov.totalAlbums}',
                    icon: Icons.photo_library_rounded,
                    color: AppColors.secondary,
                  ),
                  _Divider(),
                  _ProfileStat(
                    label: 'Downloads',
                    value: '${prov.totalDownloads}',
                    icon: Icons.download_rounded,
                    color: AppColors.accentGreen,
                  ),
                  _Divider(),
                  _ProfileStat(
                    label: 'Hrs Studied',
                    value: prov.totalStudyHours.toStringAsFixed(1),
                    icon: Icons.timer_rounded,
                    color: AppColors.accentOrange,
                  ),
                ],
              ),
            ),
          ),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Account',
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () =>
                            _showEditProfileDialog(context, prov, user),
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Password change — coming soon!')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Preferences',
                    children: [
                      _SettingsTileToggle(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        value: true,
                        onChanged: (_) => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Notifications toggled'))),
                      ),
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        label: 'App Theme',
                        trailing: const Text('Light',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 13)),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Theme switching — coming soon!')),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        trailing: const Text('English',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 13)),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Support',
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About EduHub',
                        trailing: const Text('v1.0.0',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 13)),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'EduHub',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                                '© 2024 EduHub. All rights reserved.',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context, prov),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.accentRed),
                      label: const Text('Sign Out',
                          style: TextStyle(color: AppColors.accentRed)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accentRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLG),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, AppProvider prov, UserModel user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of EduHub?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await prov.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _ProfileStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppColors.border);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  )),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(children.length * 2 - 1, (i) {
              if (i.isOdd) {
                return const Divider(
                    height: 1, indent: 56, color: AppColors.border);
              }
              return children[i ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile(
      {required this.icon, required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}

class _SettingsTileToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SettingsTileToggle(
      {required this.icon,
      required this.label,
      required this.value,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}
