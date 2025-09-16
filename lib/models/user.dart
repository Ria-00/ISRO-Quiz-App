class UserClass {
  String? userName;
  String userMail;
  String? userPassword;

  // Login constructor: only email and optional password
  UserClass.login({
    required this.userMail,
    this.userPassword,
  });

  // Register constructor: email, password, and name required
  UserClass.register({
    required this.userMail,
    required this.userPassword,
    required this.userName,
  });

  /// Converts the object to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      "name": userName,
      "email": userMail,
      "password": userPassword,
    };
  }

  /// Factory constructor to create a UserClass object from Firestore data
  factory UserClass.fromMap(Map<String, dynamic> map) {
    return UserClass.register(
      userName: map["name"],
      userMail: map["email"],
      userPassword: map["password"],
    );
  }

  /// Getters and Setters
  String? get getUserName => userName;
  set setUserName(String? name) => userName = name;

  String get getUserMail => userMail;
  set setUserMail(String mail) => userMail = mail;

  String? get getUserPassword => userPassword;
  set setUserPassword(String? pass) => userPassword = pass;
}
