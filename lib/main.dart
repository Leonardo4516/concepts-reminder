import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'core/content_manager.dart';
import 'core/storage_service.dart';
import 'core/reminder_scheduler.dart';
import 'models/app_settings.dart';
import 'models/question.dart';
import 'ui/quiz_screen.dart';
import 'ui/topics_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Inicializar almacenamiento y paquetes de preguntas
  final storage = StorageService();
  final settings = await storage.loadSettings();
  final progressMap = await storage.loadProgressMap();

  final contentManager = ContentManager();
  await contentManager.loadAllPacks();
  contentManager.restoreProgress(progressMap);

  // Inicializar scheduler con la frecuencia guardada
  final scheduler = ReminderScheduler();
  scheduler.start(
    frequencyMinutes: settings.frequencyMinutes,
    onTriggerCallback: () {
      _triggerReminderQuiz();
    },
  );

  runApp(ConceptsReminderApp(initialSettings: settings));
}

void _triggerReminderQuiz() {
  final currentContext = navigatorKey.currentContext;
  if (currentContext == null) return;

  final storage = StorageService();
  storage.loadSettings().then((settings) {
    // Seleccionar pregunta considerando los lenguajes activos
    final contentManager = ContentManager();
    final activeLangs = settings.activeLanguages;
    
    // Buscar pregunta de alguno de los lenguajes activos
    Question? selectedQuestion;
    for (final lang in activeLangs) {
      selectedQuestion = contentManager.getDueQuestion(lang.toLowerCase());
      if (selectedQuestion != null) break;
    }
    selectedQuestion ??= contentManager.getDueQuestion(null, true);

    if (selectedQuestion != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            question: selectedQuestion!,
            fullScreenLock: settings.fullScreenLock,
          ),
        ),
      );
    }
  });
}

class ConceptsReminderApp extends StatefulWidget {
  final AppSettings initialSettings;
  const ConceptsReminderApp({super.key, required this.initialSettings});

  @override
  State<ConceptsReminderApp> createState() => _ConceptsReminderAppState();
}

class _ConceptsReminderAppState extends State<ConceptsReminderApp> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    StorageService().saveSettings(newSettings);
    ReminderScheduler().updateFrequency(newSettings.frequencyMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Concepts Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: MainDashboard(
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const MainDashboard({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories),
                label: Text('Temas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Ajustes'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(settings: widget.settings);
      case 1:
        return TopicsPage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        );
      case 2:
        return SettingsPage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        );
      default:
        return HomePage(settings: widget.settings);
    }
  }
}

class HomePage extends StatefulWidget {
  final AppSettings settings;
  const HomePage({super.key, required this.settings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalQuestions = 0;
  int _dueQuestions = 0;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  void _refreshStats() {
    final cm = ContentManager();
    int total = 0;
    int due = 0;

    for (final lang in widget.settings.activeLanguages) {
      final questions = cm.getQuestionsByLanguage(lang.toLowerCase());
      total += questions.length;
      due += cm.getDueQuestions(lang.toLowerCase()).length;
    }

    setState(() {
      _totalQuestions = total;
      _dueQuestions = due;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, Desarrollador!',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mantén tus conceptos frescos con el algoritmo de repetición espaciada.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Botón para probar recordatorio de inmediato
              ElevatedButton.icon(
                onPressed: () {
                  _triggerReminderQuiz();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Probar Alarma Ahora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF374151),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Tarjeta Principal
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Lenguajes activos: ${widget.settings.activeLanguages.join(", ")}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tienes $_dueQuestions conceptos pendientes de $_totalQuestions disponibles.',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final cm = ContentManager();
                          Question? q;
                          for (final lang in widget.settings.activeLanguages) {
                            q = cm.getDueQuestion(lang.toLowerCase());
                            if (q != null) break;
                          }
                          q ??= cm.getDueQuestion(null, true);

                          if (q != null) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  question: q!,
                                  fullScreenLock: widget.settings.fullScreenLock,
                                ),
                              ),
                            );
                            _refreshStats();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Comenzar Repaso Manual'),
                      ),
                      Text(
                        'Próximo recordatorio automático cada ${widget.settings.frequencyMinutes} min',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SettingsPage extends StatelessWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajustes de Recordatorios', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 40),
          ListTile(
            title: const Text('Frecuencia del Recordatorio'),
            subtitle: Text('Cada ${settings.frequencyMinutes} minutos'),
            leading: const Icon(Icons.timer),
            trailing: DropdownButton<int>(
              value: settings.frequencyMinutes,
              dropdownColor: const Color(0xFF1F2937),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 minuto (Prueba rápida)')),
                DropdownMenuItem(value: 5, child: Text('5 minutos')),
                DropdownMenuItem(value: 15, child: Text('15 minutos')),
                DropdownMenuItem(value: 30, child: Text('30 minutos')),
                DropdownMenuItem(value: 60, child: Text('60 minutos (1 hora)')),
                DropdownMenuItem(value: 120, child: Text('120 minutos (2 horas)')),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onSettingsChanged(settings.copyWith(frequencyMinutes: newValue));
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Nivel de Dificultad'),
            subtitle: Text('Nivel actual: ${settings.difficulty.toUpperCase()}'),
            leading: const Icon(Icons.leaderboard),
            trailing: DropdownButton<String>(
              value: settings.difficulty,
              dropdownColor: const Color(0xFF1F2937),
              items: const [
                DropdownMenuItem(value: 'basic', child: Text('Básico')),
                DropdownMenuItem(value: 'medium', child: Text('Intermedio')),
                DropdownMenuItem(value: 'advanced', child: Text('Avanzado')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onSettingsChanged(settings.copyWith(difficulty: newValue));
                }
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Bloqueo de Pantalla Completa (Modo Kiosco)'),
            subtitle: const Text('Exige responder correctamente para continuar usando el equipo'),
            secondary: const Icon(Icons.lock),
            value: settings.fullScreenLock,
            onChanged: (bool value) {
              onSettingsChanged(settings.copyWith(fullScreenLock: value));
            },
          ),
        ],
      ),
    );
  }
}
