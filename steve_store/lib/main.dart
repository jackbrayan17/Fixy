import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'helpers/notification_service.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/customer/home_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
      ],
      child: const SteveStoreApp(),
    ),
  );
}

class SteveStoreApp extends StatelessWidget {
  const SteveStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return MaterialApp(
      title: 'Steve Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgLight,
        primaryColor: AppColors.emeraldGreen,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldGreen,
          primary: AppColors.emeraldGreen,
          secondary: AppColors.emeraldDark,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      home: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.currentUser == null) {
            return const SignUpScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}
