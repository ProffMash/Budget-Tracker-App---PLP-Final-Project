import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/savings_goal.dart';

class SavingsGoalWidget extends StatelessWidget {
  final VoidCallback? onAdd;
  final void Function(SavingsGoal goal)? onEdit;
  const SavingsGoalWidget({Key? key, this.onAdd, this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SavingsGoal>('savingsGoals').listenable(),
      builder: (context, Box<SavingsGoal> box, _) {
        final goals = box.values.toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Savings Goals',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Add Savings Goal',
                          onPressed: onAdd,
                        ),
                      ],
                    ),
                  ],
                ),
                if (goals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No savings goals set.'),
                  )
                else
                  ...goals.map((goal) {
                    final percent = (goal.currentAmount / goal.targetAmount)
                        .clamp(0.0, 1.0);
                    return ListTile(
                      title: Text(goal.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: percent),
                          const SizedBox(height: 4),
                          Text(
                              'Saved: ${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Savings Goal',
                        onPressed: onEdit != null ? () => onEdit!(goal) : null,
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
