import 'package:fitnation/Screens/Community/CommunityHome.dart';
// import 'package:fitnation/Screens/HomeScreen.dart';
import 'package:fitnation/Screens/NavPages.dart';
import 'package:fitnation/Screens/SettingsScreen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
// import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv

import 'package:fitnation/Screens/Auth/Login.dart';
import 'package:fitnation/Screens/Auth/OTP_Screen.dart';
import 'package:fitnation/Screens/Auth/Signup.dart';
import 'package:fitnation/Screens/nutrition/trainer_nutrition_plans_screen.dart'; // Import TrainerNutritionPlansScreen
import 'package:fitnation/core/themes/themes.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:fitnation/providers/auth_provider.dart'; // Added import for authProvider
// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi
// import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
// Controllers for the AnimatedNotchBottomBar
// final NotchBottomBarController _notchController = NotchBottomBarController();
// final PageController _pageController = PageController();

late CloudinaryObject cloudinary;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load the .env file
  // Initialize FFI
  // sqfliteFfiInit();
  // // Change the default factory for Android/iOS/Linux/Windows.
  // databaseFactory =await databaseFactoryFfi;
  cloudinary = await CloudinaryObject.fromCloudName(cloudName: 'djheckgfw');

  final prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      overrides: [
        // Override the sharedPreferencesProvider with the initialized instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final PageController _pageController = PageController();
  final NotchBottomBarController _notchController = NotchBottomBarController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _notchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final authState = ref.watch(authProvider); // Watch auth state

    Widget homeWidget;
    if (authState is Authenticated) {
      homeWidget = Scaffold(
        // Main app scaffold
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: navPages,
        ),
        bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _notchController,
          color: const Color.fromARGB(250, 84, 83, 83),
          showLabel: false,
          notchColor: const Color.fromARGB(255, 255, 236, 236),
          removeMargins: false,
          bottomBarWidth: 500,
          elevation: 5.0,
          shadowElevation: 5.0,
          durationInMilliSeconds: 300,
          bottomBarItems:
              NavItem.values.map((navitem) => navitem.option).toList(),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.jumpToPage(index);
          },
          kIconSize: 16.0,
          kBottomRadius: 24.0,
        ),
      );
    } else if (authState is Unauthenticated) {
      homeWidget = const LoginScreen();
    } else {
      // AuthInitial or AuthLoading
      homeWidget = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp(
      title: 'Athlytiq',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: homeWidget, // Set home based on auth state
      routes: {
        '/login': (context) => const LoginScreen(),
        '/create_account': (context) => const CreateAccountScreen(),
        '/verify_email':
            (context) => const VerifyEmailScreen(email: 'sara@cruz.com'),
        '/settings': (context) => const SettingsScreen(),
        '/community': (context) => const CommunityHomeScreen(),
        '/trainer_nutrition_plans':
            (context) => const TrainerNutritionPlansScreen(), // New route
      },
    );
  }
}

// Helper extension for capitalizing strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

}