import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_app/models/budget.dart';
import 'package:budget_app/models/expense.dart';
import 'package:budget_app/pages/add_budget_page.dart';
import 'package:budget_app/pages/add_expense_page.dart';
import 'package:budget_app/pages/budget_detail_page.dart';
import 'package:budget_app/services/user_service.dart';
import 'package:budget_app/widgets/budget_card.dart';
import 'package:budget_app/widgets/spending_chart.dart';
import 'package:budget_app/widgets/savings_goal_widget.dart';
import 'package:budget_app/pages/savings_goal_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:budget_app/pages/login_page.dart';
import 'package:budget_app/theme/theme_provider.dart';
import 'package:budget_app/theme/theme_toggle.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Box<Budget> _budgetBox;
  late Box<Expense> _expenseBox;

  @override
  void initState() {
    super.initState();
    _budgetBox = Hive.box<Budget>('budgets');
    _expenseBox = Hive.box<Expense>('expenses');
  }

  double get _totalBudgeted {
    return _budgetBox.values.fold(0, (sum, budget) => sum + budget.amount);
  }

  double get _totalSpent {
    return _expenseBox.values.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Map<String, dynamic>> get _budgetSpendingData {
    return _budgetBox.values.map((budget) {
      final spent = _expenseBox.getTotalSpentForBudget(budget.id);
      return {
        'name': budget.name,
        'budgeted': budget.amount,
        'spent': spent,
        'remaining': budget.amount - spent,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;
    final themeNotifier = ThemeProvider.of(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome back, ${user?.name ?? ''}'),
        actions: [
          ThemeToggle(
            isDark: isDark,
            onToggle: () => setState(() => themeNotifier.toggleTheme()),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAccount,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Savings Goals Overview
            SavingsGoalWidget(
              onAdd: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SavingsGoalPage(),
                  ),
                );
              },
              onEdit: (goal) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SavingsGoalPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Dashboard Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Monthly Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Budgeted', _totalBudgeted),
                        _buildSummaryItem('Spent', _totalSpent),
                        _buildSummaryItem(
                            'Remaining', _totalBudgeted - _totalSpent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Spending Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: SpendingChart(data: _budgetSpendingData),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Expenses
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRecentExpenses(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Budgets List
            const Text(
              'Your Budgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBudgetsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpenses() {
    final expenses = _expenseBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final recentExpenses = expenses.take(3).toList();

    if (recentExpenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No recent expenses'),
      );
    }

    return Column(
      children: recentExpenses.map((expense) {
        final budget = _budgetBox.get(expense.budgetId);
        return ListTile(
          leading: const Icon(Icons.money_off),
          title: Text(expense.name),
          subtitle: Text(budget?.name ?? 'Unknown Budget'),
          trailing: Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetsList() {
    return ValueListenableBuilder(
      valueListenable: _budgetBox.listenable(),
      builder: (context, Box<Budget> box, _) {
        final budgets = box.values.toList();
        if (budgets.isEmpty) {
          return const Center(
            child: Text('No budgets created yet.'),
          );
        }
        return Column(
          children: budgets.map((budget) {
            return BudgetCard(
              budget: budget,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BudgetDetailPage(budgetId: budget.id),
                  ),
                );
              },
              onAddExpense: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpensePage(budgetId: budget.id),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This will remove all your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              UserService.deleteUser();
              Hive.box<Budget>('budgets').clear();
              Hive.box<Expense>('expenses').clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
              Fluttertoast.showToast(msg: 'Account deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
