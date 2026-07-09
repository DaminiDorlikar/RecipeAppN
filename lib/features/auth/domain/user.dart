class User {
  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
}
