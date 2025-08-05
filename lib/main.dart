import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/simple_theme_service.dart';
import 'screens/home_screen.dart';
import 'widgets/fade_in_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SimpleThemeService.initialize();
  runApp(MovieHubApp());
}

class MovieHubApp extends StatefulWidget {
  @override
  _MovieHubAppState createState() => _MovieHubAppState();
}

class _MovieHubAppState extends State<MovieHubApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Hub',
      debugShowCheckedModeBanner: false,
      theme: SimpleThemeService.lightTheme,
      darkTheme: SimpleThemeService.darkTheme,
      themeMode: SimpleThemeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FadeInWidget(
        duration: Duration(milliseconds: 800),
        child: HomeScreen(),
      ),
    );
  }
}
