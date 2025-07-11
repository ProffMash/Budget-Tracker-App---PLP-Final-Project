import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:budget_app/models/budget.dart';
import 'package:budget_app/models/expense.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final expenses =
        Hive.box<Expense>('expenses').getExpensesForBudget(budget.id);
    final spent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final remaining = budget.amount - spent;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(budget.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('\$${budget.amount.toStringAsFixed(2)} Budgeted'),
            const SizedBox(height: 4),
            Text('\$${spent.toStringAsFixed(2)} spent'),
            const SizedBox(height: 4),
            Text('\$${remaining.toStringAsFixed(2)} remaining'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
