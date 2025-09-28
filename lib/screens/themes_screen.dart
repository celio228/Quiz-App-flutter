import 'package:flutter/material.dart' hide Theme;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'questions_screen.dart';
import '../models/phase_model.dart';
import '../models/theme_model.dart';

class ThemesScreen extends StatefulWidget {
  final Phase phase;

  const ThemesScreen({Key? key, required this.phase}) : super(key: key);

  @override
  _ThemesScreenState createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  late List<Theme> _themes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    print('🎯 Chargement des thèmes pour la phase ${widget.phase.id}');

    try {
      final themes = await themeProvider.loadThemes(widget.phase.id, authProvider.token!);
      setState(() {
        _themes = themes;
        _isLoading = false;
        _error = null;
      });
      print('✅ Thèmes chargés: ${themes.length}');
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
        _themes = [];
      });
      print('❌ Erreur chargement thèmes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.phase.name),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Chargement des thèmes...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        'Erreur',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadThemes,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _themes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'Aucun thème disponible',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'pour cette phase',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _themes.length,
                      itemBuilder: (context, index) {
                        final theme = _themes[index];
                        return _buildThemeCard(theme);
                      },
                    ),
    );
  }

  Widget _buildThemeCard(Theme theme) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getThemeColor(theme),
          child: Icon(
            Icons.category,
            color: Colors.white,
          ),
        ),
        title: Text(
          theme.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(theme.description),
            SizedBox(height: 5),
            Text(
              '${theme.questions.length} questions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionsScreen(theme: theme),
            ),
          );
        },
      ),
    );
  }

  Color _getThemeColor(Theme theme) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[theme.id % colors.length];
  }
}