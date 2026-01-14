class User {
  int? id;
  String fullName;
  String username;
  String email;
  String password;
  String profilePhoto;
  List<String> categories;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.profilePhoto,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'password': password,
      'profilePhoto': profilePhoto,
      'categories': categories.join(','),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profilePhoto: map['profilePhoto'],
      categories: map['categories'] != null ? (map['categories'] as String).split(',') : [],
    );
  }
}
