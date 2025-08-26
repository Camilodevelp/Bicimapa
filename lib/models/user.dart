class User {
  final String id;
  final String name;
  final String email;
  final int completedRoutes;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.completedRoutes = 0,
  });
}
