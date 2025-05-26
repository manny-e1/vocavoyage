import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vocavoyage/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  String apiKey = dotenv.get('GEMINI_API_KEY');
  if (apiKey.isEmpty) {
    throw AssertionError('GEMINI_API_KEY is not set');
  }
  Gemini.init(apiKey: apiKey);
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for a more immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define our custom color scheme
    const primaryColor = Color(0xFF4E54C8); // Deep purple-blue
    const secondaryColor = Color(0xFF8F94FB); // Lighter purple
    const backgroundColor = Color(0xFF1A1A2E); // Deep blue-black
    const surfaceColor = Color(0xFF16213E); // Slightly lighter blue-black
    const accentColor = Color(0xFF00D2FF); // Bright cyan

    return MaterialApp(
      title: 'VocaVoyage',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          surface: surfaceColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: surfaceColor,
          shadowColor: primaryColor.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        iconTheme: const IconThemeData(color: accentColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceColor,
          disabledColor: surfaceColor.withOpacity(0.5),
          selectedColor: primaryColor,
          secondarySelectedColor: secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: const TextStyle(fontSize: 14, color: Colors.white),
          secondaryLabelStyle: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          brightness: Brightness.dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2D3250),
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
