import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/screens/main_screen/main_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora UNET',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppTheme.nearlyBlue.withOpacity(0.5),
          cursorColor: AppTheme.nearlyBlue.withOpacity(0.5),
          selectionHandleColor: AppTheme.nearlyBlue.withOpacity(0.8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: TextStyle(
            color: AppTheme.nearlyBlue.withOpacity(0.8),
          ),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
