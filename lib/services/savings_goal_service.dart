import 'package:hive/hive.dart';
import '../models/savings_goal.dart';

class SavingsGoalService {
  static const String boxName = 'savingsGoals';

  Future<Box<SavingsGoal>> _getBox() async {
    return await Hive.openBox<SavingsGoal>(boxName);
  }

  Future<List<SavingsGoal>> getGoals() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final box = await _getBox();
    await box.add(goal);
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await goal.save();
  }

  Future<void> deleteGoal(SavingsGoal goal) async {
    await goal.delete();
  }
}
