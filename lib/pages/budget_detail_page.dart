import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_app/models/budget.dart';
import 'package:budget_app/models/expense.dart';
import 'package:budget_app/pages/add_expense_page.dart';
import 'package:budget_app/widgets/expense_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BudgetDetailPage extends StatefulWidget {
  final String budgetId;

  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  late Box<Budget> _budgetBox;
  late Box<Expense> _expenseBox;
  late Budget _budget;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _budgetBox = Hive.box<Budget>('budgets');
    _expenseBox = Hive.box<Expense>('expenses');
    _budget = _budgetBox.get(widget.budgetId)!;
  }

  @override
  Widget build(BuildContext context) {
    final spent = _expenseBox.getTotalSpentForBudget(widget.budgetId);
    final remaining = _budget.amount - spent;

    return Scaffold(
      appBar: AppBar(
        title: Text(_budget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: _showSuccess ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: _showSuccess
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Action completed successfully!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              '# ${_budget.name} Overview',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _budget.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_budget.amount.toStringAsFixed(2)} Budgeted',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${spent.toStringAsFixed(2)} spent',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${remaining.toStringAsFixed(2)} remaining',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _deleteBudget,
                child: const Text('Delete Budget'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Add New ${_budget.name} Expense',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddExpensePage(budgetId: widget.budgetId),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
                _showAnimatedSuccess();
              },
              child: const Text('Add Expense'),
            ),
            const SizedBox(height: 24),
            Text(
              '# ${_budget.name} Expenses',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<Box<Expense>>(
                valueListenable: Hive.box<Expense>('expenses').listenable(),
                builder: (context, box, _) {
                  final expenses = box.getExpensesForBudget(widget.budgetId);
                  if (expenses.isEmpty) {
                    return const Center(
                      child: Text('No expenses added yet.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ExpenseTile(
                        expense: expense,
                        onDelete: () => _deleteExpense(expense.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBudget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
            'Are you sure you want to delete this budget? All related expenses will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _expenseBox.deleteExpensesForBudget(widget.budgetId);
              _budgetBox.delete(widget.budgetId);
              Navigator.pop(context);
              Navigator.pop(context);
              _showAnimatedSuccess();
              Fluttertoast.showToast(msg: 'Budget deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _expenseBox.delete(id);
              Navigator.pop(context);
              _showAnimatedSuccess();
              Fluttertoast.showToast(msg: 'Expense deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAnimatedSuccess() {
    setState(() {
      _showSuccess = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
      }
    });
  }
}
