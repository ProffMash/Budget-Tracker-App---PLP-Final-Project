import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String name;

  User({required this.name});
}

extension UserBox on Box<User> {
  User? get currentUser => values.isNotEmpty ? values.first : null;

  void setUser(User user) {
    clear();
    add(user);
  }
}
