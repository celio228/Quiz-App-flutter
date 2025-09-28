import 'package:flutter/material.dart' hide Theme;
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';
import '../models/theme_model.dart';
import '../models/question_model.dart';
import '../models/quiz_response_model.dart';

class QuestionsScreen extends StatefulWidget {
  final Theme theme;

  const QuestionsScreen({Key? key, required this.theme}) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<Question> _questions = [];
  Map<int, int?> _selectedOptions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    try {
      final questions = await quizProvider.loadQuestions(widget.theme.id, authProvider.token!);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSubmissionDialog() {
    final unansweredQuestions = _questions.where((q) => _selectedOptions[q.id] == null).length;
    
    if (unansweredQuestions > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Questions non répondues'),
          content: Text('Il reste $unansweredQuestions question(s) non répondue(s). Voulez-vous vraiment soumettre ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitAnswers();
              },
              child: Text('Soumettre'),
            ),
          ],
        ),
      );
    } else {
      _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    try {
      final answers = _selectedOptions.entries
          .where((entry) => entry.value != null)
          .map((entry) => QuizResponse(
                questionId: entry.key,
                selectedOptionId: entry.value!,
              ))
          .toList();

      final submission = QuizSubmission(
        themeId: widget.theme.id,
        answers: answers,
      );

      final result = await quizProvider.submitAnswers(submission, authProvider.token!);
      
      _showResultDialog(result);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la soumission: $error')),
      );
    }
  }

  void _showResultDialog(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Résultats du Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Points gagnés: ${result.totalPointsEarned}'),
            Text('Réponses correctes: ${result.correctAnswers}/${result.totalQuestions}'),
            SizedBox(height: 10),
            Text(
              'Score: ${((result.correctAnswers / result.totalQuestions) * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer la dialog
              Navigator.pop(context); // Retour à l'écran précédent
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.theme.name),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return _buildQuestionCard(question);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showSubmissionDialog,
                      child: Text(
                        'Soumettre les réponses',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...question.options.map((option) => _buildOptionTile(question, option)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(Question question, Option option) {
    return RadioListTile<int>(
      title: Text(option.optionText),
      value: option.id,
      groupValue: _selectedOptions[question.id],
      onChanged: (value) {
        setState(() {
          _selectedOptions[question.id] = value;
        });
      },
    );
  }
}