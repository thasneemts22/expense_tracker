import 'package:expense_manager/core/services/notification_service.dart';
import 'package:expense_manager/features/auth/bloc/auth_bloc.dart';
import 'package:expense_manager/features/auth/service/auth_service.dart';
import 'package:expense_manager/features/transactions/bloc/sync_bloc.dart';
import 'package:expense_manager/features/transactions/repository/sync_repository.dart';
import 'package:expense_manager/features/transactions/screens/home_screen.dart';
import 'package:expense_manager/screens/main_screen.dart';
import 'package:expense_manager/features/auth/screens/name_screen.dart';
import 'package:expense_manager/screens/onboarding_screen.dart';
import 'package:expense_manager/features/auth/screens/phone_screen.dart';
import 'package:expense_manager/screens/splash_screen.dart';
import 'package:expense_manager/features/auth/screens/verify_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthService())),
        BlocProvider(create: (_) => SyncBloc(SyncRepository())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/verifyOtp': (context) => const VerifyOtpScreen(),
        '/name': (context) => const NameScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
