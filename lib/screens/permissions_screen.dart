import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:filesharing/utils/permissions.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions(BuildContext context) async {
    setState(() => _isRequesting = true);

    bool allGranted = await PermissionUtils.areAllPermissionsGranted();
    if (!allGranted) {
      await PermissionUtils.requestNecessaryPermissions();
      allGranted = await PermissionUtils.areAllPermissionsGranted();
    }

    setState(() => _isRequesting = false);

    if (allGranted) {
      GoRouter.of(context).go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All permissions are required for full functionality. Please grant all permissions. 🔒',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final isSmallScreen = screenWidth < 400 || screenHeight < 600;

    final animationSize = isSmallScreen ? 140.0 : 180.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final bodyFontSize = isSmallScreen ? 12.0 : 14.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final spacing = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Lottie.asset(
                            'assets/animations/permission_screen.json',
                            width: animationSize,
                            height: animationSize,
                            repeat: true,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Permissions Needed 🔐',
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'To use FileSharing, we need access to:\n\n'
                          '📷 Camera for scanning QR codes\n'
                          '📁 Photos / Videos / Audio for file sharing\n'
                          '📍 Location & Nearby Devices for WiFi discovery\n'
                          '👥 Contacts for easy sharing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ElevatedButton.icon(
                          onPressed: _isRequesting
                              ? null
                              : () => _requestPermissions(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 24 : 32,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          icon: _isRequesting
                              ? SizedBox(
                                  width: isSmallScreen ? 16 : 20,
                                  height: isSmallScreen ? 16 : 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(Icons.verified_user_rounded,
                                  size: isSmallScreen ? 20 : 24),
                          label: Text(
                              _isRequesting ? 'Requesting...' : 'Grant Permissions'),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'We respect your privacy ✅\nPermissions are only used locally on your device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: bodyFontSize - 2,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
