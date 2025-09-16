import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:isro/models/user.dart';
import 'package:isro/providers/userProvider.dart';
import 'package:isro/screens/homePage.dart';
import 'package:isro/screens/splashScreen.dart';
import 'package:isro/screens/warning.dart';
import 'package:isro/services/userOperations.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  User? _user;
  UserClassOperations operate = UserClassOperations();
  UserClass u = UserClass.login(userMail: '', userPassword: '');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  void showFloatingWarning(String message) {
    final overlay = Overlay.of(context, rootOverlay: true);

    if (overlay == null) {
      debugPrint("No overlay found in context!");
      return;
    }

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => FloatingWarning(message: message),
    );

    // Insert overlay
    overlay.insert(overlayEntry);

    // Remove after 2 sec
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Required";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null; // No error
  }

  String? _validateLoginPassword(String? value) {
      // Check if password is empty
      if (value == null || value.isEmpty) {
        return "Required";
      }
      return null; // No error
    }

  Future<void> _submitForm() async {
    isLoading = true;
    setState(() {});
    u.userMail = _emailController.text.trim();
    u.userPassword = _passwordController.text.trim();
    final form = _formKey.currentState;
    if (form!.validate()) {
      print("Valid Form");
      int a = await operate.login(u);
      if (a == 1) {
        Provider.of<userProvider>(context, listen: false).setValue(u.userMail!);
        Provider.of<userProvider>(context, listen: false)
            .setPass(u.userPassword!);
        print(Provider.of<userProvider>(context, listen: false).email);
        isLoading = false;
        setState(() {});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        isLoading = false;
        setState(() {});
        showFloatingWarning("Incorrect credentials");
      }
    } else {
      isLoading = false;
      setState(() {});
      print("Error in form");
    }
  }

  Future<void> registerUserAfterGoogleSignIn(String email) async {
    try {
      UserClass? fetchedUser = await operate.getUser(email);

      if (fetchedUser == null) {
        UserClass _user1 = UserClass.login(userMail: email);
        // If the user doesn't exist in Firestore, register them
        await operate.create(_user1);

        print("User registered successfully in Firestore.");
      } else {
        print("User already exists in Firestore.");
      }
    } catch (e) {
      print("Error registering user in Firestore: $e");
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      // **Ensure previous user session is cleared before new login**
      await FirebaseAuth.instance.signOut();
      isLoading = true;
      setState(() {}); // Trigger a rebuild to show loading indicator

      GoogleAuthProvider _authprovider = GoogleAuthProvider();
      _authprovider.addScope('email').setCustomParameters(
          {'prompt': 'select_account'}); // Forces account selection

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(_authprovider);

      _user = userCredential.user;

      if (_user != null) {
        print("Google Sign-In successful:");
        print("Profile Data: ${userCredential.toString()}");
        print("Name: ${_user!.displayName}");
        print("Email: ${_user!.email}");

        // **Ensure provider updates immediately**
        Provider.of<userProvider>(context, listen: false)
            .setValue(_user!.email!);

        await registerUserAfterGoogleSignIn(_user!.email!);

        isLoading = false;
        setState(() {}); // Trigger a rebuild to hide loading indicator
        // **Navigate after provider update**
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      _user = null;
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await _auth.signOut();
      setState(() {
        _user = null; // Clear the user after sign-out
      });
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ keyboard pushes content up
      body: Stack(
        children: [
          // ✅ Fullscreen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover, // cover entire screen
            ),
          ),

          // ✅ Foreground content (scrollable)
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 100),

                            // Title
                            const Text(
                              "LOGIN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Email Field
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _emailController,
                              validator: _validateUsername,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(Icons.email,
                                    color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              validator: _validateLoginPassword,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                prefixIcon:
                                    const Icon(Icons.lock, color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Login Button
                            ElevatedButton(
                              onPressed: () {
                                _submitForm();
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 18, 23, 112),
                                ),
                              ),
                            ),

                            const SizedBox(height: 2),

                            // Register Redirect
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don’t have an account?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Text("OR",style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),),
                            ),

                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                await signInWithGoogle();
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 18, 23, 112),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  FaIcon(FontAwesomeIcons.google,
                                  size: 25
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
