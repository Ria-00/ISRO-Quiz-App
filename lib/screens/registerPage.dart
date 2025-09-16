import 'package:flutter/material.dart';
import 'package:isro/models/user.dart';
import 'package:isro/screens/loginPage.dart';
import 'package:isro/screens/success.dart';
import 'package:isro/screens/warning.dart';
import '../services/userOperations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading =false;
  UserClassOperations operate = UserClassOperations();
  UserClass u = UserClass.register(userMail: '', userPassword: '', userName: '');
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  void showFloatingSuccess(String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => FloatingSuccess(message: message),
    );

    // Insert the overlay
    Overlay.of(context).insert(overlayEntry);

    // Remove the overlay after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _submitForm() async {
    isLoading = true;
    setState(() {});
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      u.userMail = _emailController.text.trim();
      u.userPassword = _passwordController.text.trim();
      u.userName = _nameController.text.trim();

      int a = await operate.create(u);
      int b = await operate.add(u);
      if (a == 1 && b == 1) {
        isLoading = false;
    setState(() {});
        showFloatingSuccess("Registration successful");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        isLoading = false;
    setState(() {});
        showFloatingWarning("User already exists");
      }
    }
    else{
      isLoading = false;
    setState(() {});
      print("Error in form");
    }
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

  String? _nameValidator(String? value) {
      if (value == null || value.isEmpty) {
        return "Name is required";
      }
      if (value.length < 2) {
        return "Name must be at least 2 characters long";
      }
      return null;
    }
  
  String? _validatePassword(String? value) {
      // Check if password is empty
      if (value == null || value.isEmpty) {
        return "Required";
      }

      // Check for minimum length
      if (value.length < 8) {
        return "Must be at least 8 characters long";
      }

      // Check for at least one uppercase letter
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
        return "Must contain one uppercase letter";
      }

      // Check for at least one number
      if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
        return "Must contain one number";
      }

      // Check for at least one special character
      if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
        return "Must contain one special character";
      }

      return null; // No error
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          
          // Scrollable content
          isLoading
              ? Center(child: CircularProgressIndicator()):
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
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
                        const SizedBox(height: 80),
                        const Text(
                          "REGISTER",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Name
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Name", Icons.person),
                          validator: _nameValidator,),
                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Email", Icons.email),
                          validator: _validateUsername,
                        ),
                        const SizedBox(height: 20),

                        // Password
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Password", Icons.lock,
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
                              )),
                          validator: _validatePassword
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                              "Confirm Password", Icons.lock,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              )),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm your password";
                            }
                            if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        // Register Button
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 18, 23, 112),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Redirect
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}
