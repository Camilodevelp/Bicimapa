import '../models/user.dart';

class UserService {
  // Lista simulada de usuarios
  final List<User> _users = [
    User(id: '1', name: 'Juan Pérez', email: 'juanperez@email.com', completedRoutes: 12),
    User(id: '2', name: 'María Gómez', email: 'mariagomez@email.com', completedRoutes: 8),
  ];

  // Obtener todos los usuarios
  List<User> getAllUsers() {
    return _users;
  }

  // Obtener un usuario por ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Agregar un nuevo usuario
  void addUser(User user) {
    _users.add(user);
  }
}
