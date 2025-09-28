import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phase_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';
import 'themes_screen.dart';

class QuizPhasesScreen extends StatefulWidget {
  @override
  _QuizPhasesScreenState createState() => _QuizPhasesScreenState();
}

class _QuizPhasesScreenState extends State<QuizPhasesScreen> {
  @override
  void initState() {
    super.initState();
    _loadPhases();
  }

  Future<void> _loadPhases() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    if (quizProvider.phases.isEmpty) { // Ne charger que si la liste est vide
      await quizProvider.loadPhases(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final phases = quizProvider.phases;

    // Debug: afficher le nombre de phases
    print('Nombre de phases chargées: ${phases.length}');
    phases.forEach((phase) {
      print(' ${phase.name}');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Phases du Quiz'),
        backgroundColor: Colors.blue,
      ),
      body: quizProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : quizProvider.error != null
              ? Center(child: Text(quizProvider.error!))
              : phases.isEmpty
                  ? Center(child: Text('Aucune phase disponible'))
                  : ListView.builder(
                      itemCount: phases.length,
                      itemBuilder: (context, index) {
                        final phase = phases[index];
                        return _buildPhaseCard(phase);
                      },
                    ),
    );
  }

  Widget _buildPhaseCard(Phase phase) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            '${phase.order}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          ' ${phase.name}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(phase.description),
            SizedBox(height: 4),
            Text(
              'Niveau: ${phase.level} • ${phase.themes.length} thème(s)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThemesScreen(phase: phase),
            ),
          );
        },
      ),
    );
  }
}