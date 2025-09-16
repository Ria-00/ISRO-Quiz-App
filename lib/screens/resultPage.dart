import 'package:flutter/material.dart';
import 'package:isro/models/user.dart';
import 'package:isro/providers/userProvider.dart';
import 'package:isro/services/userOperations.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final String userName;
  final String category;
  final String level;

  ResultPage({
    super.key,
    required this.category,
    required this.level,
    required this.score,
    required this.total,
    required this.userName,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  UserClassOperations operations = UserClassOperations();

  void updateQuiz() async {
    String userEmail =
        Provider.of<userProvider>(context, listen: false).email ?? '';

    int result=await operations.addQuizResult(userEmail,widget.level, widget.category,widget.score);
    if (result == 1) {
    print("Quiz added successfully");
  } else {
    print("Failed to add quiz");
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top avatar / illustration
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 229, 245),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events,
                  size: 80, color: Color.fromARGB(255, 60, 58, 183)),
            ),

            const SizedBox(height: 30),

            // Score
            Text(
              "Your Score",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            Text(
              "${widget.score}/${widget.total}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 60, 58, 183),
              ),
            ),

            const SizedBox(height: 20),

            // Congratulation message
            Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    widget.score > 5
        ? const Text(
            "Congratulations!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 60, 58, 183),
            ),
          )
        : const Text(
            "You can do better!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
    const SizedBox(height: 8),
    Text(
      widget.score > 5
          ? "Great job, ${widget.userName}! You have done well."
          : "Keep practicing, ${widget.userName}!",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
    ),
  ],
)
,

            const SizedBox(height: 20),

            const SizedBox(height: 60),

            // Back to Home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color.fromARGB(255, 60, 58, 183),
                ),
                onPressed: () {
                  updateQuiz();
                  Navigator.pop(context, '/home');

                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
