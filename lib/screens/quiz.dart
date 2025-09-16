import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isro/models/user.dart';
import 'package:isro/providers/userProvider.dart';
import 'package:isro/screens/resultPage.dart';
import 'package:isro/services/questionService.dart';
import 'package:isro/services/userOperations.dart';
import 'package:provider/provider.dart';

class QuizPage extends StatefulWidget {
  final String category;
  final String level;

  const QuizPage({super.key, required this.category, required this.level});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  UserClass? _user;
  UserClassOperations operations = UserClassOperations();
  int currentIndex = 0;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  int? selectedOption;

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

  final QuestionService _questionService = QuestionService();
  List<Map<String, dynamic>> quizQuestions = [];

  Future<void> loadQuiz() async {
    await _questionService.loadQuestions();
    setState(() {
      quizQuestions =
          _questionService.getQuestions(widget.category, widget.level);
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    loadQuiz();
    _getuserInformation();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        nextQuestion();
      }
    });
  }

  void checkAnswer(int index) {
    setState(() {
      selectedOption = index;
      if (index == quizQuestions[currentIndex]["correct"]) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentIndex < quizQuestions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
      startTimer();
    } else {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: score,
            total: 10,
            userName: _user!.userName ?? "Guest",
            category: widget.category,
            level: widget.level,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.category} - ${widget.level}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 91, 95, 152),
          centerTitle: true, // optional: centers the title
        ),
        body: const Center(child: Text("No questions available.")),
      );
    }

    final question = quizQuestions[currentIndex];
    final options = question["options"] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.category} - ${widget.level}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22, // slightly bigger
            color: Colors.white, // ensures contrast
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 92, 91, 152),
        elevation: 4, // subtle shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // rounded bottom corners
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 92, 91, 152),
                Color.fromARGB(255, 152, 135, 191),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            // Timer
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "⏳ $timeLeft s",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // Question
            Container(
              width: double.infinity, // 👈 same as options
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 152, 91, 143),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Q${currentIndex + 1}. ${question["question"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Options
            ...List.generate(options.length, (i) {
              return GestureDetector(
                onTap: () => checkAnswer(i),
                child: Container(
                  alignment:Alignment.center,
                  width: double.infinity, // 👈 matches question box
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedOption == i
                        ? const Color.fromRGBO(91, 106, 152, 1)
                        : const Color.fromRGBO(61, 57, 61, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    options[i],
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
            }),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Color.fromARGB(255, 255, 255, 255),
                backgroundColor: const Color.fromARGB(255, 152, 91, 143),
              ),
              onPressed: nextQuestion,
              child: Text(
                  currentIndex == quizQuestions.length - 1 ? "Finish" : "Next"),
            )
          ],
        ),
      ),
    );
  }
}
