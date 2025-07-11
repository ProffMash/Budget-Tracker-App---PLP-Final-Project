import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String budgetId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  Expense({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.amount,
    required this.date,
  });
}

extension ExpenseBox on Box<Expense> {
  List<Expense> get expensesForBudget => values.toList();

  List<Expense> getExpensesForBudget(String budgetId) {
    return values.where((expense) => expense.budgetId == budgetId).toList();
  }

  double getTotalSpentForBudget(String budgetId) {
    return getExpensesForBudget(budgetId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  void addExpense(Expense expense) {
    put(expense.id, expense);
  }

  void deleteExpense(String id) {
    delete(id);
  }

  void deleteExpensesForBudget(String budgetId) {
    final expenses = getExpensesForBudget(budgetId);
    for (var expense in expenses) {
      delete(expense.id);
    }
  }
}
