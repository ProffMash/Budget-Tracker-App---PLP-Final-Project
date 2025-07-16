import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:budget_app/models/budget.dart';
import 'package:budget_app/models/expense.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;
  final VoidCallback onAddExpense;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.onTap,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final expenses =
        Hive.box<Expense>('expenses').getExpensesForBudget(budget.id);
    final spent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final remaining = budget.amount - spent;
    final progress = budget.amount > 0 ? spent / budget.amount : 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onAddExpense,
                    tooltip: 'Add Expense',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8 ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${spent.toStringAsFixed(2)} spent'),
                  Text('\$${remaining.toStringAsFixed(2)} remaining'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${budget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
