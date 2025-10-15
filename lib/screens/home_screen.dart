import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _deviceName = 'Device';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    _getDeviceName();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        _deviceName = androidInfo.model;
      });
    } catch (e) {
      try {
        final iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceName = iosInfo.name;
        });
      } catch (e2) {
        setState(() {
          _deviceName = 'Device';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Calculate responsive values
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 600;
    final isLargeScreen = screenWidth >= 800;

    final paddingValue = isSmallScreen
        ? 16.0
        : isMediumScreen
        ? 20.0
        : 24.0;
    final animationSize = isSmallScreen
        ? 120.0
        : isMediumScreen
        ? 150.0
        : isLargeScreen
        ? 200.0
        : 180.0;
    final headerPadding = isSmallScreen
        ? 16.0
        : isMediumScreen
        ? 20.0
        : 24.0;
    final spacingValue = isSmallScreen
        ? 16.0
        : isMediumScreen
        ? 20.0
        : 24.0;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          'File Sharing',
          style: TextStyle(
            fontSize: isSmallScreen ? 20.0 : 24.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => context.push('/active-transfers'),
            tooltip: 'Active Transfers',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          children: [
            // Header Section with Animation
            Container(
              padding: EdgeInsets.all(headerPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [Colors.blue.shade900, Colors.purple.shade900]
                      : [Colors.blue.shade50, Colors.purple.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.blue.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/animations/home_animation.json',
                    height: animationSize,
                    width: animationSize,
                  ),
                  SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                  Text(
                    'Professional File Sharing 🚀',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18.0 : 22.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue.shade200
                          : Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 6.0 : 8.0),
                  Text(
                    'Welcome back, $_deviceName! ✨\nShare files instantly and securely',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade300
                          : Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: spacingValue),

            // Action Buttons Section
            Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: isSmallScreen ? 16.0 : 18.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
            ),

            SizedBox(height: spacingValue),

            // Action Buttons Section
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/send'),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Send Files'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/receive'),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Receive Files'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(
                          '/receive',
                        ), // Assuming receive has QR scan
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scan QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/history'),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: spacingValue),

            // Professional Features Section
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '✨ Professional Features',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16.0 : 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue.shade300
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: isSmallScreen ? 16.0 : 24.0,
                    runSpacing: 20.0,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      _buildFeatureItem(
                        'QR Connect',
                        '📱',
                        'Instant device pairing',
                        isSmallScreen,
                      ),
                      _buildFeatureItem(
                        'File Types',
                        '📁',
                        'All formats supported',
                        isSmallScreen,
                      ),
                      _buildFeatureItem(
                        'Fast Transfer',
                        '⚡',
                        'Lightning speed',
                        isSmallScreen,
                      ),
                      _buildFeatureItem(
                        'Secure',
                        '🔒',
                        'Local network only',
                        isSmallScreen,
                      ),
                      _buildFeatureItem(
                        'Cross-Platform',
                        '🌐',
                        'Works everywhere',
                        isSmallScreen,
                      ),
                      _buildFeatureItem(
                        'No Limits',
                        '♾️',
                        'Unlimited sharing',
                        isSmallScreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    String title,
    String emoji,
    String subtitle,
    bool isSmallScreen,
  ) {
    return SizedBox(
      width: isSmallScreen ? 80 : 100,
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 24.0 : 28.0)),
          SizedBox(height: isSmallScreen ? 4.0 : 6.0),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 10.0 : 12.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 2.0 : 4.0),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 8.0 : 10.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade500
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
