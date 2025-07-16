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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddExpensePage(budgetId: widget.budgetId),
                  ),
                );
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
              Fluttertoast.showToast(msg: 'Expense deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
