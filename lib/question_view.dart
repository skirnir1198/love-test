import 'package:flutter/material.dart';
import 'package:myapp/diagnosis_data.dart';
import 'package:myapp/result_view.dart';

class QuestionView extends StatefulWidget {
  final Diagnosis selectedTest;

  const QuestionView({super.key, required this.selectedTest});

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  int _currentQuestionIndex = 0;
  int _yesCount = 0;

  void _answerQuestion(bool answer) {
    if (answer) {
      _yesCount++;
    }

    if (_currentQuestionIndex < widget.selectedTest.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // 最後の質問に答えたら結果画面へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultView(
            selectedTest: widget.selectedTest,
            yesCount: _yesCount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.selectedTest.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedTest.title,
          style: const TextStyle(fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value:
                (_currentQuestionIndex + 1) /
                widget.selectedTest.questions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Q${_currentQuestionIndex + 1}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnswerButton(context, 'いいえ', false),
                _buildAnswerButton(context, 'はい', true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(BuildContext context, String text, bool value) {
    return ElevatedButton(
      onPressed: () => _answerQuestion(value),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 50),
        backgroundColor: value ? Colors.pinkAccent : Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
