import 'package:flutter/material.dart';

class AppColors {
  // Primary palette – rich gold
  static const Color primary = Color(0xFFC9A84C);
  static const Color primaryDark = Color(0xFF8B6F1E);
  static const Color primaryLight = Color(0xFFE8C97A);

  // Secondary palette – warm bronze
  static const Color secondary = Color(0xFF9B7B50);
  static const Color secondaryLight = Color(0xFFD4B896);

  // Accent
  static const Color accent = Color(0xFFE8C97A);
  static const Color accentGreen = Color(0xFF7EC8A4);
  static const Color accentOrange = Color(0xFFD4A04A);
  static const Color accentRed = Color(0xFFE07070);
  static const Color accentBlue = Color(0xFF6B9FD4);

  // Neutral – dark luxury
  static const Color background = Color(0xFF0C0C14);
  static const Color surface = Color(0xFF13131C);
  static const Color surfaceVariant = Color(0xFF1C1C28);
  static const Color cardBg = Color(0xFF181824);

  // Text
  static const Color textPrimary = Color(0xFFF0EAD6);
  static const Color textSecondary = Color(0xFF9A8F80);
  static const Color textHint = Color(0xFF5C5650);
  static const Color textOnPrimary = Color(0xFF0C0C14);

  // Border
  static const Color border = Color(0xFF2A2A38);
  static const Color borderFocus = Color(0xFFC9A84C);

  // Status
  static const Color success = Color(0xFF7EC8A4);
  static const Color warning = Color(0xFFD4A04A);
  static const Color error = Color(0xFFE07070);
  static const Color info = Color(0xFF7AB4C8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC9A84C), Color(0xFF8B6F1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE8C97A), Color(0xFFC9A84C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0C0C14), Color(0xFF1A1424)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF7EC8A4), Color(0xFF5BA87A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFD4A04A), Color(0xFFB07030)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStrings {
  static const String appName = 'EduHub';
  static const String appTagline = 'Your Digital Learning Hub';

  // Auth
  static const String login = 'Log In';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String resetPassword = 'Reset Password';

  // Onboarding
  static const String onboard1Title = 'Discover & Save';
  static const String onboard1Desc =
      'Explore thousands of educational videos and save your favorites with a single tap. Build your personal learning library effortlessly.';
  static const String onboard2Title = 'Organize & Categorize';
  static const String onboard2Desc =
      'Create custom albums and playlists to categorize your learning videos. Keep your studies organized and easy to access.';
  static const String onboard3Title = 'Track & Share';
  static const String onboard3Desc =
      'Monitor your learning progress, track study sessions, and share valuable resources with fellow students.';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String myVideos = 'My Videos';
  static const String albums = 'Albums';
  static const String downloads = 'Downloads';
  static const String history = 'History';
  static const String shared = 'Community';
  static const String sessions = 'Sessions';
  static const String profile = 'Profile';
  static const String admin = 'Admin Panel';
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String videos = '/videos';
  static const String addVideo = '/add-video';
  static const String videoDetail = '/video-detail';
  static const String albums = '/albums';
  static const String albumDetail = '/album-detail';
  static const String createAlbum = '/create-album';
  static const String downloads = '/downloads';
  static const String history = '/history';
  static const String shared = '/shared';
  static const String sessions = '/sessions';
  static const String profile = '/profile';
  static const String admin = '/admin';
}

class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusRound = 100.0;

  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
}
