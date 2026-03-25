import 'package:flutter/material.dart';
import 'package:du_an/core/database/hive_init.dart';
import 'package:du_an/core/theme/app_theme.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/router/app_router.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  await configureDependencies();

  // Seed default categories on first launch
  await getIt<CustomCategoryRepository>().seedDefaults();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
