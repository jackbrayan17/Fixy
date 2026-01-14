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
      child: const FixyApp(),
    ),
  );
}

class FixyApp extends StatelessWidget {
  const FixyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgWhite,
        primaryColor: AppColors.midnightBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgWhite,
          foregroundColor: AppColors.midnightBlue,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.midnightBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.midnightBlue,
          primary: AppColors.midnightBlue,
          secondary: AppColors.grey,
          surface: AppColors.bgWhite,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgWhite,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.lightGrey),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.midnightBlue, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.darkGrey),
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
