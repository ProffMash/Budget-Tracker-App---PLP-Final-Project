import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.createdAt,
  });
}

extension BudgetBox on Box<Budget> {
  List<Budget> get allBudgets => values.toList();

  void addBudget(Budget budget) {
    put(budget.id, budget);
  }

  void deleteBudget(String id) {
    delete(id);
  }
}
