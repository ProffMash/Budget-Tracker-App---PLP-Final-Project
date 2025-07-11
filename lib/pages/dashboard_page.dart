import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_app/models/budget.dart';
import 'package:budget_app/models/expense.dart';
import 'package:budget_app/pages/add_budget_page.dart';
import 'package:budget_app/pages/budget_detail_page.dart';
import 'package:budget_app/services/user_service.dart';
import 'package:budget_app/widgets/budget_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:budget_app/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Box<Budget> _budgetBox;

  @override
  void initState() {
    super.initState();
    _budgetBox = Hive.box<Budget>('budgets');
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome back, ${user?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAccount,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal budgeting is the secret to financial freedom.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create a budget to get started!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder(
              valueListenable: _budgetBox.listenable(),
              builder: (context, Box<Budget> box, _) {
                final budgets = box.values.toList();
                if (budgets.isEmpty) {
                  return const Center(
                    child: Text('No budgets created yet.'),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      return BudgetCard(
                        budget: budget,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetDetailPage(
                                budgetId: budget.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
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
