import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> futureQuestions;
  List<Question>? questions;
  int currentQuestionIndex = 0;
  int score = 0;
  int remainingTime = 720; // 12 minutes in seconds
  bool quizCompleted = false;

  final List<String> backgroundImages = [
    'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    'https://images.unsplash.com/photo-1444084316824-dc26d6657664?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    'https://images.unsplash.com/photo-1519999482648-25049ddd37b1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    'https://images.unsplash.com/photo-1521747116042-5a810fda9664?crop=entropy&cs=tinysrgb&fit=crop&w=1080&h=720&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&q=80',
    'https://images.unsplash.com/photo-1444084316824-dc26d6657664?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    'https://images.unsplash.com/photo-1519999482648-25049ddd37b1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?crop=entropy&cs=tinysrgb&fit=crop&w=1080&h=720&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&q=80',
  ];

  String? backgroundImage;

  @override
  void initState() {
    super.initState();
    futureQuestions = ApiService().fetchQuestions();
    startTimer();
    backgroundImage =
        backgroundImages[Random().nextInt(backgroundImages.length)];
  }

  void startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (remainingTime > 0 && !quizCompleted) {
        setState(() {
          remainingTime--;
        });
        startTimer();
      } else {
        setState(() {
          quizCompleted = true;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(score: score),
          ),
        );
      }
    });
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      remainingTime = 720;
      quizCompleted = false;
      futureQuestions = ApiService().fetchQuestions();
      startTimer();
      backgroundImage =
          backgroundImages[Random().nextInt(backgroundImages.length)];
    });
  }

  void answerQuestion(String selectedOption) {
    if (questions![currentQuestionIndex].answer == selectedOption) {
      score++;
    }

    if (currentQuestionIndex < questions!.length - 1) {
      setState(() {
        currentQuestionIndex++;
        backgroundImage =
            backgroundImages[Random().nextInt(backgroundImages.length)];
      });
    } else {
      setState(() {
        quizCompleted = true;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: score),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Question>>(
        future: futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            questions = snapshot.data;

            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: backgroundImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remaining Time: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                      questions![currentQuestionIndex].question,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    ...questions![currentQuestionIndex].options.map((option) {
                      return ElevatedButton(
                        onPressed: () => answerQuestion(option),
                        child: Text(option),
                      );
                    }).toList(),
                    if (quizCompleted)
                      ElevatedButton(
                        onPressed: restartQuiz,
                        child: Text('Restart Quiz'),
                      ),
                  ],
                ),
              ],
            );
          }
          return Center(child: Text('No questions available.'));
        },
      ),
    );
  }
}
