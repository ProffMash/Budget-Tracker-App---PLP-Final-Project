import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 3)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double currentAmount;

  @HiveField(3)
  DateTime? deadline;

  SavingsGoal({
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
  });
}
