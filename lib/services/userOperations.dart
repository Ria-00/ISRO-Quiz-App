import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isro/models/user.dart';

class UserClassOperations {
  // Step 1: Create an instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //register
  Future<int> add(UserClass user) async {
    // If registration is successful
    try {
      if (user.userMail != null && user.userPassword != null) {
        await _auth.createUserWithEmailAndPassword(
            email: user.userMail, password: user.userPassword!);
        print("done");
        return 1;
      } else {
        print("Email or password is null");
        return 0;
      }
      // throws exception in case of failure & returns registration failed message
    } catch (e) {
      print("no");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            print("Email is already in use.");
            break;
          case 'invalid-email':
            print("Invalid email format.");
            break;
          case 'weak-password':
            print("Weak password.");
            break;
          case 'network-request-failed':
            print("network-request-failed.");
            break;
          case 'operation-not-allowed':
            print("operation-not-allowed.");
            break;
          default:
            print("Registration failed: ${e.message}");
        }
      }
      return 0;
    }
  }

  //login
  Future<int> login(UserClass user) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: user.userMail!, password: user.userPassword!);

      User? user1 = userCredential.user;
      print(user1);
      if (user1 == null) {
        return 0;
      }
      print("Login successful");
      return 1;
    } catch (e) {
      print("error");
      return 0;
    }
  }

  Future<int> create(UserClass user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Check if a user with the same email already exists
      QuerySnapshot snapshot = await firestore
          .collection("users")
          .where("email", isEqualTo: user.userMail)
          .get();

      if (snapshot.docs.isEmpty) {
        // If no user exists, create a new user
        await firestore.collection("users").add(user.toMap());
        print("User created successfully");
        return 1; // Success
      } else {
        // User already exists
        print("User already exists");
        return 0; // User exists
      }
    } catch (e) {
      print("Error: $e");
      return -1; // Error occurred
    }
  }

   Future<UserClass?> getUser(String umail) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await firestore
          .collection("users")
          .where("email",
              isEqualTo: umail) // Ensure this field name matches Firestore
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Convert Firestore document to UserClass
        print(UserClass.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>));
        return UserClass.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print("nothing");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<int> addQuizResult(String email, String level, String quiz, int score) async {
    final CollectionReference users = FirebaseFirestore.instance.collection("users");
      try {
      QuerySnapshot querySnapshot =
          await users.where("email", isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = querySnapshot.docs.first.reference;

        await userRef.update({
          "quizes": FieldValue.arrayUnion([
            {
              "level": level,
              "quiz": quiz,
              "score": score,
            }
          ])
        });

        return 1; 
      } else {
        print("No user found with email $email");
        return 0;
      }
    } catch (e) {
      print("Error adding quiz: $e");
      return 0; 
    }
  }


  Future<List<Map<String, dynamic>>> fetchUserQuizzes(String email) async {
    try {
      final CollectionReference users = FirebaseFirestore.instance.collection("users");
      QuerySnapshot querySnapshot =
          await users.where("email", isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;

        if (data.containsKey("quizes")) {
          List<dynamic> quizzes = data["quizes"];
          // Cast into proper list of maps
          return quizzes.map((q) => Map<String, dynamic>.from(q)).toList();
        } else {
          print("No quizzes found for user");
          return [];
        }
      } else {
        print("No user found with email $email");
        return [];
      }
    } catch (e) {
      print("Error fetching quizzes: $e");
      return [];
    }
  }

}



