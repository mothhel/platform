import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/food_provider.dart';
import 'providers/request_provider.dart'; // 🔥 تم استيراد مزود الطلبات

import 'views/auth/login_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(
          create: (_) => RequestProvider(),
        ), // 🔥 تم تسجيله هنا
      ],
      child: const PlatformApp(),
    ),
  );
}

class PlatformApp extends StatelessWidget {
  const PlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة نِعم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(), // خط عربي احترافي
        scaffoldBackgroundColor: AppColors.background,
      ),
      // الانطلاق من شاشة الدخول
      home: const LoginScreen(),
    );
  }
}
