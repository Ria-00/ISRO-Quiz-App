import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isro/models/user.dart';
import 'package:isro/providers/userProvider.dart';
import 'package:isro/screens/quiz.dart';
import 'package:isro/screens/splashScreen.dart';
import 'package:isro/services/userOperations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Quizhome extends StatefulWidget {
  const Quizhome({super.key});
  static const String routeName = '/home';

  @override
  State<Quizhome> createState() => _QuizhomeState();
}

class _QuizhomeState extends State<Quizhome> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> quizzes = [];
  UserClass? _user;
  UserClassOperations operations = UserClassOperations();

  final List<String> categories = ["Spacecrafts", "Rockets", "ISRO"];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getuserInformation();
    _getQuizzes();
  }

  void _getQuizzes() async {
    String userEmail =
        Provider.of<userProvider>(context, listen: false).email ?? '';
    List<Map<String, dynamic>> fetchedQuizzes = await operations.fetchUserQuizzes(userEmail);
    setState(() {
      quizzes = fetchedQuizzes;
    });
  }

  void _getuserInformation() async {
    String userEmail =
        Provider.of<userProvider>(context, listen: false).email ?? '';

    UserClass? fetchedUser = await operations.getUser(userEmail);
    print(userEmail);

    if (fetchedUser != null) {
      setState(() {
        _user = fetchedUser;
      });
    } else {
      print("User not found!");
    }
  }

  // Show bottom sheet for difficulty
  void _showDifficultySelector(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose difficulty for $category",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.star_border, color: Colors.green),
                title: const Text("Easy"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizPage(category: category, level: "Easy"),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_half, color: Colors.orange),
                title: const Text("Medium"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizPage(category: category, level: "Medium"),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.red),
                title: const Text("Hard"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizPage(category: category, level: "Hard"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                        'https://www.shutterstock.com/image-vector/man-character-face-avatar-glasses-600nw-542759665.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey, ${_user?.userName ?? 'Explorer'}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Ready to play",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            Provider.of<userProvider>(context, listen: false)
                                .removeValue();

                            // Sign out from Firebase
                            await FirebaseAuth.instance.signOut();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StartPage()),
                              (route) => false, // removes all previous routes
                            );
                          },
                          icon: const Icon(Icons.logout),
                          color: Colors.purple,
                          iconSize: 20,
                        ), // use iconSize
                        SizedBox(width: 4),
                        Text("Log Out",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Search for a quiz",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Play & Win Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Check out\nISRO's official website",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final Uri uri = Uri.parse('https://www.isro.gov.in/');
                        if (!await launchUrl(
                          uri,
                          mode: LaunchMode
                              .externalApplication, // forces system browser
                        )) {
                          throw Exception('Could not launch $uri');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Click here",
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Subjects",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () => _showDifficultySelector(context, category),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school,
                                size: 40, color: Colors.deepPurple),
                            const SizedBox(height: 8),
                            Text(category,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Recent Section
              const Text(
                "Completed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // build recent cards dynamically
              Column(
                children: quizzes.map((quiz) {
                  String subject = quiz["quiz"];
                  String subtitle = quiz["level"];
                  int score =
                      quiz["score"];
                  Color bgColor = quiz["score"] > 0
                      ? Colors.green[100]!
                      : Colors.orange[100]!;
                  Color textColor =
                      quiz["score"] > 0 ? Colors.green : Colors.orange;

                  return _buildRecentCard(subject,subtitle,score, bgColor, textColor);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCard(String title, String subtitle, int score,
      Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.science, size: 32, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${score ?? 0} / 10",
              style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              ),
              ),
            ),
        ],
      ),
    );
  }
}
