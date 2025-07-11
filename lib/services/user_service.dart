import 'package:hive/hive.dart';
import 'package:budget_app/models/user.dart';

class UserService {
  static final Box<User> _userBox = Hive.box<User>('users');

  static User? get currentUser => _userBox.currentUser;

  static void setUser(User user) {
    _userBox.setUser(user);
  }

  static void deleteUser() {
    _userBox.clear();
  }
}
