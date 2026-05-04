import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'videos/videos_screen.dart';
import 'albums/albums_screen.dart';
import 'downloads/downloads_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_screen.dart';
import 'notifications/notifications_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // â”€â”€ Student screens & nav â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const _studentScreens = [
    DashboardScreen(),
    VideosScreen(),
    AlbumsScreen(),
    DownloadsScreen(),
    NotificationsPage(),
    ProfileScreen(),
  ];

  static const _studentNavItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.video_library_rounded, label: 'My Videos'),
    _NavItem(icon: Icons.folder_rounded, label: 'Albums'),
    _NavItem(icon: Icons.download_rounded, label: 'Downloads'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Notifications'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  // â”€â”€ Admin screens & nav â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const _adminScreens = [
    DashboardScreen(),
    AdminScreen(),
    ProfileScreen(),
  ];

  static const _adminNavItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'Admin Panel'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AppProvider>().isAdmin;
    final screens = isAdmin ? _adminScreens : _studentScreens;
    final navItems = isAdmin ? _adminNavItems : _studentNavItems;

    // Clamp index so switching roles doesn't crash
    final safeIndex = _selectedIndex.clamp(0, navItems.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                navItems.length,
                (i) => _buildNavItem(navItems[i], i, isAdmin,
                    unreadCount: (!isAdmin && i == 4) ? context.watch<AppProvider>().unreadCount : 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index, bool isAdmin, {int unreadCount = 0}) {
    final selected = _selectedIndex == index;
    final isAdminTab = isAdmin && item.label == 'Admin Panel';

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: AppColors.accentRed,
              child: Icon(
                item.icon,
                size: 24,
                color: selected
                    ? (isAdminTab ? AppColors.accentOrange : AppColors.primary)
                    : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? (isAdminTab ? AppColors.accentOrange : AppColors.primary)
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}


