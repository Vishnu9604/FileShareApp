import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:filesharing/providers/theme_provider.dart';
import 'package:filesharing/providers/settings_provider.dart';
import 'package:filesharing/providers/history_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings ⚙️'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with animation
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Colors.blue.shade900,
                          Colors.purple.shade900,
                        ]
                      : [
                          Colors.blue.shade50,
                          Colors.purple.shade50,
                        ],
                ),
              ),
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/animations/settings_animation.json',
                    height: 120,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Customize Your Experience 🎨',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue.shade200
                              : Colors.blue.shade800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust settings to make Xbean work best for you',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings sections
            _buildSettingsSection(
              title: 'Appearance 🌟',
              children: [
                _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark themes',
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                  icon: Icons.dark_mode,
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'Transfer Settings 📤',
              children: [
                _buildListTile(
                  title: 'Default Transfer Port',
                  subtitle: 'Port used for file transfers',
                  trailing: const Text('8080'),
                  icon: Icons.settings_ethernet,
                  onTap: () {
                    // TODO: Show port configuration dialog
                  },
                ),
                _buildSwitchTile(
                  title: 'Auto-accept Transfers',
                  subtitle: 'Automatically accept incoming transfers',
                  value: settings.autoAcceptTransfers,
                  onChanged: (value) {
                    settingsNotifier.setAutoAcceptTransfers(value);
                  },
                  icon: Icons.auto_mode,
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'Privacy & Security 🔒',
              children: [
                _buildListTile(
                  title: 'Clear Transfer History',
                  subtitle: 'Remove all transfer records',
                  icon: Icons.delete_sweep,
                  onTap: () {
                    _showClearHistoryDialog(context);
                  },
                ),
                _buildSwitchTile(
                  title: 'Encrypt Transfers',
                  subtitle: 'Use encryption for file transfers',
                  value: settings.encryptTransfers,
                  onChanged: (value) {
                    settingsNotifier.setEncryptTransfers(value);
                  },
                  icon: Icons.security,
                ),
              ],
            ),

            _buildSettingsSection(
              title: 'About ℹ️',
              children: [
                _buildListTile(
                  title: 'Version',
                  subtitle: 'Current app version',
                  trailing: const Text('1.0.0'),
                  icon: Icons.info,
                  onTap: () { },
                ),
                _buildListTile(
                  title: 'Help & Support',
                  subtitle: 'Get help or contact support',
                  icon: Icons.help,
                  onTap: () {
                    // TODO: Navigate to help screen
                  },
                ),
                _buildListTile(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Icons.privacy_tip,
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_animationController),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.shade300
                        : Colors.blue.shade700,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade300
          : Colors.blue.shade600),
      title: Text(title, style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      )),
      subtitle: Text(subtitle, style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      )),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade300
          : Colors.blue.shade600),
      title: Text(title, style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      )),
      subtitle: Text(subtitle, style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      )),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade300
          : Colors.blue.shade600,
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    final historyNotifier = ref.read(historyProvider.notifier);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text('Clear Transfer History? 🗑️', style: TextStyle(
          color: Theme.of(context).textTheme.headlineSmall?.color,
        )),
        content: Text(
          'This will permanently remove all transfer records from your device. This action cannot be undone.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            )),
          ),
          TextButton(
            onPressed: () {
              historyNotifier.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Transfer history cleared 🧹'),
                  backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
