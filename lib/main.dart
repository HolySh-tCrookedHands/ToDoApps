import "package:ToDo/models/settings.dart";
import 'package:ToDo/screens/home.dart';
import 'package:flutter/material.dart';

final appSettings = AppSettings();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await appSettings.load();

  runApp(
    MyApp(
      settings: appSettings,
    ),
  );
}
class MyApp extends StatelessWidget {
  final AppSettings settings;

  const MyApp({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settings,
        builder: (context, child) {
            return MaterialApp(
              themeMode: settings.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,

              theme: ThemeData(
                brightness: Brightness.light,

                colorScheme: ColorScheme.fromSeed(
                  seedColor: settings.color,
                  brightness: Brightness.light,
                ),

              ),

              darkTheme: ThemeData(
                brightness: Brightness.dark,

                colorScheme: ColorScheme.fromSeed(
                  seedColor: settings.color,
                  brightness: Brightness.dark,
                ),
              ),

              home: HomeScreen(
                settings: settings,
              ),
            );
        },
    );
  }
}
