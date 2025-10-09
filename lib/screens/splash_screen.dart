import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:filesharing/utils/permissions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _initializeApp() async {
    // Start checking permissions in background
    final permissionCheckFuture = PermissionUtils.areAllPermissionsGranted();

    Timer(const Duration(seconds: 2), () async {
      final allPermissionsGranted = await permissionCheckFuture;
      if (allPermissionsGranted) {
        // If permissions are already granted, go directly to home
        GoRouter.of(context).go('/home');
      } else {
        // If permissions are not granted, go to permissions screen
        GoRouter.of(context).go('/permissions');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Calculate responsive values
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 600;

    final animationSize = isSmallScreen
        ? 120.0
        : isMediumScreen
        ? 160.0
        : 200.0;
    final titleFontSize = isSmallScreen
        ? 32.0
        : isMediumScreen
        ? 40.0
        : 48.0;
    final subtitleFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
        ? 16.0
        : 18.0;
    final spacing = isSmallScreen
        ? 20.0
        : isMediumScreen
        ? 25.0
        : 30.0;
    final bottomSpacing = isSmallScreen
        ? 30.0
        : isMediumScreen
        ? 40.0
        : 50.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Lottie.asset(
                    'assets/animations/splash_animation.json',
                    width: animationSize,
                    height: animationSize,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'File Sharing',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.grey.withOpacity(0.3),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Share Files Instantly 🚀',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.black54,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(height: bottomSpacing),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
