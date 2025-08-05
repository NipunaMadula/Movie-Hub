import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/settings_screen.dart';
import '../screens/advanced_search_screen.dart';

class QuickActionsWidget extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  
  const QuickActionsWidget({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  _QuickActionsWidgetState createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              _isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
            ),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme Toggle Button
        IconButton(
          onPressed: _toggleTheme,
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          tooltip: 'Toggle Theme',
        ),
        
        // Advanced Search Button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdvancedSearchScreen(),
              ),
            );
          },
          icon: Icon(Icons.search_outlined, color: Colors.white),
          tooltip: 'Advanced Search',
        ),
        
        // Settings Button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              ),
            );
          },
          icon: Icon(Icons.settings, color: Colors.white),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
