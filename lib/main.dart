import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_app/models/budget.dart';
import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/user.dart';
import 'package:budget_app/models/savings_goal.dart';
import 'package:budget_app/pages/splash_page.dart';
import 'package:budget_app/theme/app_theme.dart';
import 'package:budget_app/theme/theme_notifier.dart';
import 'package:budget_app/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());
  await Hive.openBox<User>('users');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<SavingsGoal>('savingsGoals');

  runApp(
    ThemeProvider(
      notifier: ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    return MaterialApp(
      title: 'Budget App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      home: const SplashPage(),
    );
  }
}
