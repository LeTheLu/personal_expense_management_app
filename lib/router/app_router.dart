import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:du_an/features/home/presentation/pages/home_page.dart';
import 'package:du_an/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:du_an/features/statistics/presentation/pages/statistics_page.dart';
import 'package:du_an/features/settings/presentation/pages/settings_page.dart';
import 'package:du_an/router/main_shell.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String addTransaction = '/add-transaction';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: home,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: statistics,
            name: 'statistics',
            builder: (context, state) => const StatisticsPage(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: addTransaction,
        name: 'addTransaction',
        builder: (context, state) => const AddTransactionPage(),
      ),
    ],
  );
}
