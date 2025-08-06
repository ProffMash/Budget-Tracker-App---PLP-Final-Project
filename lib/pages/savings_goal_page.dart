import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../services/savings_goal_service.dart';

class SavingsGoalPage extends StatefulWidget {
  const SavingsGoalPage({Key? key}) : super(key: key);

  @override
  State<SavingsGoalPage> createState() => _SavingsGoalPageState();
}

class _SavingsGoalPageState extends State<SavingsGoalPage> {
  bool _showSuccess = false;
  String _successMsg = '';
  final SavingsGoalService _service = SavingsGoalService();
  List<SavingsGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _service.getGoals();
    setState(() {
      _goals = goals;
    });
  }

  void _showAnimatedSuccess(String msg) {
    setState(() {
      _showSuccess = true;
      _successMsg = msg;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
      }
    });
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Goal Title'),
            ),
            TextField(
              controller: targetController,
              decoration: InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0.0;
              if (title.isNotEmpty && target > 0) {
                await _service
                    .addGoal(SavingsGoal(title: title, targetAmount: target));
                Navigator.pop(context);
                _loadGoals();
                _showAnimatedSuccess('Goal added successfully!');
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(SavingsGoal goal) {
    final titleController = TextEditingController(text: goal.title);
    final targetController =
        TextEditingController(text: goal.targetAmount.toString());
    final currentController =
        TextEditingController(text: goal.currentAmount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Goal Title'),
            ),
            TextField(
              controller: targetController,
              decoration: InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: currentController,
              decoration: InputDecoration(labelText: 'Current Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0.0;
              final current = double.tryParse(currentController.text) ?? 0.0;
              if (title.isNotEmpty && target > 0 && current >= 0) {
                goal.title = title;
                goal.targetAmount = target;
                goal.currentAmount = current;
                await _service.updateGoal(goal);
                Navigator.pop(context);
                _loadGoals();
                _showAnimatedSuccess('Goal updated successfully!');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showIncrementDialog(SavingsGoal goal) {
    final incrementController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to Savings'),
        content: TextField(
          controller: incrementController,
          decoration: InputDecoration(labelText: 'Amount to Add'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final inc = double.tryParse(incrementController.text) ?? 0.0;
              if (inc > 0) {
                goal.currentAmount += inc;
                await _service.updateGoal(goal);
                Navigator.pop(context);
                _loadGoals();
                _showAnimatedSuccess('Savings incremented!');
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGoalDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal'),
        content: Text('Are you sure you want to delete this savings goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.deleteGoal(goal);
              Navigator.pop(context);
              _loadGoals();
              _showAnimatedSuccess('Goal deleted!');
            },
            child: Text('Delete'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTile(SavingsGoal goal) {
    final percent = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    return Card(
      child: ListTile(
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: percent),
            SizedBox(height: 4),
            Text(
                'Saved: \$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditGoalDialog(goal),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showIncrementDialog(goal),
              tooltip: 'Add Savings',
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteGoalDialog(goal),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            tooltip: 'Add Savings Goal',
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedOpacity(
            opacity: _showSuccess ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: _showSuccess
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12, top: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _successMsg,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: _goals.isEmpty
                ? const Center(child: Text('No savings goals yet.'))
                : ListView(
                    children: _goals.map(_buildGoalTile).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Savings Goal',
      ),
    );
  }
}
