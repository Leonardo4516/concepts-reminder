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

bool _isQuizOpen = false;

void _triggerReminderQuiz() {
  if (_isQuizOpen) {
    debugPrint("Recordatorio omitido: ya hay un cuestionario en pantalla esperando que el usuario lo resuelva.");
    return;
  }

  final currentContext = navigatorKey.currentContext;
  if (currentContext == null) return;

  final storage = StorageService();
  storage.loadSettings().then((settings) {
    // Check quiet hours
    if (settings.quietHoursEnabled) {
      final nowHour = DateTime.now().hour;
      final start = settings.quietStartHour;
      final end = settings.quietEndHour;
      bool isQuiet = false;
      if (start > end) {
        // e.g. 22 to 8 (crosses midnight)
        isQuiet = (nowHour >= start || nowHour < end);
      } else {
        isQuiet = (nowHour >= start && nowHour < end);
      }
      if (isQuiet) {
        debugPrint("Recordatorio omitido por Horas de Silencio ($nowHour:00 dentro de $start:00-$end:00)");
        return;
      }
    }

    final contentManager = ContentManager();
    final activeLangs = settings.activeLanguages;
    final activeSub = settings.activeSubtopics;

    Question? selectedQuestion;
    for (final lang in activeLangs) {
      final allowed = activeSub[lang.toLowerCase().trim()];
      final topicDiff = settings.topicDifficulties[lang.toLowerCase().trim()] ?? settings.difficulty;
      selectedQuestion = contentManager.getDueQuestion(
        lang.toLowerCase(),
        false,
        topicDiff,
        allowed,
      );
      if (selectedQuestion != null) break;
    }
    selectedQuestion ??= contentManager.getDueQuestion(
      null,
      true,
      settings.difficulty,
    );

    if (selectedQuestion != null) {
      _isQuizOpen = true;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            question: selectedQuestion!,
            fullScreenLock: settings.fullScreenLock,
            hapticsEnabled: settings.hapticsEnabled,
          ),
        ),
      ).then((_) {
        _isQuizOpen = false;
        // El reconteo del próximo recordatorio inicia exactamente cuando el usuario resuelve y cierra la pantalla
        ReminderScheduler().updateFrequency(settings.frequencyMinutes);
      });
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0E12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
          surface: const Color(0xFF13161C),
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

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 650;

        if (isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFF0C0E12),
            body: SafeArea(child: _buildContent()),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF11141A),
                border: Border(
                  top: BorderSide(color: Color(0xFF1E232E), width: 1),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavigate,
                backgroundColor: const Color(0xFF11141A),
                indicatorColor: const Color(0xFF064E3B),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard, color: Color(0xFF34D399)),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.auto_stories_outlined),
                    selectedIcon: Icon(Icons.auto_stories, color: Color(0xFF34D399)),
                    label: 'Temas',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.tune_outlined),
                    selectedIcon: Icon(Icons.tune, color: Color(0xFF34D399)),
                    label: 'Ajustes',
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0C0E12),
          body: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFF1D222B), width: 1),
                  ),
                ),
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onNavigate,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: const Color(0xFF101318),
                  indicatorColor: const Color(0xFF064E3B),
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.psychology_outlined, color: Color(0xFF34D399), size: 22),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard, color: Color(0xFF34D399)),
                      label: Text('Inicio'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_stories_outlined),
                      selectedIcon: Icon(Icons.auto_stories, color: Color(0xFF34D399)),
                      label: Text('Temas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune, color: Color(0xFF34D399)),
                      label: Text('Ajustes'),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        HomePage(
          settings: widget.settings,
          onNavigateToTopics: () => _onNavigate(1),
        ),
        TopicsPage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        ),
        SettingsPage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onNavigateToTopics;

  const HomePage({
    super.key,
    required this.settings,
    required this.onNavigateToTopics,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalQuestions = 0;
  int _dueQuestions = 0;
  int _masteredQuestions = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  void _refreshStats() async {
    final cm = ContentManager();
    final storage = StorageService();
    final streak = await storage.getStreak();

    int total = 0;
    int due = 0;
    int mastered = 0;

    for (final lang in widget.settings.activeLanguages) {
      final allowed = widget.settings.activeSubtopics[lang.toLowerCase().trim()];
      final topicDiff = widget.settings.topicDifficulties[lang.toLowerCase().trim()] ?? widget.settings.difficulty;
      final questions = cm.getQuestionsByLanguage(lang.toLowerCase(), topicDiff, allowed);
      total += questions.length;
      due += cm.getDueQuestions(lang.toLowerCase(), topicDiff, allowed).length;

      for (final q in questions) {
        final progress = cm.getProgress(q.id);
        if (progress != null && progress.intervalDays >= 21) {
          mastered++;
        }
      }
    }

    if (mounted) {
      setState(() {
        _totalQuestions = total;
        _dueQuestions = due;
        _masteredQuestions = mastered;
        _currentStreak = streak;
      });
    }
  }

  Future<void> _startFocusedReview() async {
    final cm = ContentManager();
    Question? q;
    for (final lang in widget.settings.activeLanguages) {
      final allowed = widget.settings.activeSubtopics[lang.toLowerCase().trim()];
      final topicDiff = widget.settings.topicDifficulties[lang.toLowerCase().trim()] ?? widget.settings.difficulty;
      q = cm.getDueQuestion(
        lang.toLowerCase(),
        false,
        topicDiff,
        allowed,
      );
      if (q != null) break;
    }
    q ??= cm.getDueQuestion(null, true, widget.settings.difficulty);

    if (q != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            question: q!,
            fullScreenLock: widget.settings.fullScreenLock,
            hapticsEnabled: widget.settings.hapticsEnabled,
          ),
        ),
      );
      _refreshStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Branding, Greeting and Streak Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concepts Reminder',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '¡Hola, Desarrollador!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mantén tus conceptos técnicos consolidados con repetición espaciada.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _currentStreak > 0 ? const Color(0xFF1B202A) : const Color(0xFF14171E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _currentStreak > 0 ? const Color(0xFF2C3445) : const Color(0xFF1E2430),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_currentStreak > 0 ? '🔥' : '🌱', style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          _currentStreak > 0 ? '$_currentStreak días racha' : 'Comienza tu racha',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _currentStreak > 0 ? const Color(0xFFF3F4F6) : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Rhythmic Notification Status Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF13171F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222836)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B222E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.timer_outlined, color: Color(0xFF34D399), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recordatorios automáticos en curso',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF3F4F6),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Frecuencia: cada ${widget.settings.frequencyMinutes} min • ${widget.settings.activeLanguages.length} temas activos',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _triggerReminderQuiz(),
                      icon: const Icon(Icons.notifications_active_outlined, size: 15),
                      label: const Text('Probar alarma'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF34D399),
                        side: const BorderSide(color: Color(0xFF065F46)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 Metric Cards Row
              LayoutBuilder(
                builder: (context, c) {
                  final bool stackMetrics = c.maxWidth < 620;
                  final cards = [
                    _buildMetricCard(
                      title: 'Pendientes hoy',
                      value: '$_dueQuestions',
                      subtitle: 'Listos para repasar',
                      accentColor: const Color(0xFF10B981),
                      icon: Icons.access_time_rounded,
                    ),
                    _buildMetricCard(
                      title: 'Dominados',
                      value: '$_masteredQuestions',
                      subtitle: 'Intervalo > 21 días',
                      accentColor: const Color(0xFF60A5FA),
                      icon: Icons.verified_outlined,
                    ),
                    _buildMetricCard(
                      title: 'Conceptos activos',
                      value: '$_totalQuestions',
                      subtitle: 'En tus subtemas',
                      accentColor: const Color(0xFFA78BFA),
                      icon: Icons.layers_outlined,
                    ),
                  ];

                  if (stackMetrics) {
                    return Column(
                      children: cards
                          .map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: card,
                              ))
                          .toList(),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 14),
                      Expanded(child: cards[1]),
                      const SizedBox(width: 14),
                      Expanded(child: cards[2]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Primary Action: Focused Review (Concept 3 inspired)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F261E), Color(0xFF131922)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF16533E), width: 1.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt, color: Color(0xFF34D399), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Repaso Inmediato',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sesión Rápida de Preguntas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Refuerza conceptos inmediatamente sin esperar el siguiente ciclo.',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _startFocusedReview,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Comenzar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Active Modules & Micro-options Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Módulos y Subtemas Activos',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: widget.onNavigateToTopics,
                    icon: const Icon(Icons.tune_rounded, size: 15, color: Color(0xFF34D399)),
                    label: const Text('Personalizar', style: TextStyle(color: Color(0xFF34D399), fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...widget.settings.activeLanguages.map((langKey) {
                final cm = ContentManager();
                final displayName = cm.getPackDisplayName(langKey);
                final allSubtopics = cm.getSubtopicsForPack(langKey);
                final activeSub = widget.settings.activeSubtopics[langKey.toLowerCase().trim()] ?? allSubtopics.keys.toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12151C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1F2430)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF3F4F6),
                            ),
                          ),
                          Text(
                            '${activeSub.length} de ${allSubtopics.length} subtemas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: activeSub.map((subKey) {
                          final label = allSubtopics[subKey] ?? subKey;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A202C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF283244)),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2533)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.grey.shade500,
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
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Ajustes de Preferencias',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Configura el ritmo de estudio, dificultad y comportamiento del sistema.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 32),

              // Section 1: Ritmo de Recordatorios
              _buildSectionCard(
                title: 'Frecuencia de Recordatorios',
                subtitle: 'Cada cuánto tiempo saldrá un concepto de repaso',
                icon: Icons.timer_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildIntervalPill(1, '1 min (Test)', context),
                        _buildIntervalPill(15, '15 min', context),
                        _buildIntervalPill(25, '25 min (Pomodoro)', context),
                        _buildIntervalPill(45, '45 min', context),
                        _buildIntervalPill(60, '60 min (1h)', context),
                        _buildIntervalPill(120, '120 min (2h)', context),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Efectos Hápticos y Sonido (Mobile Ready)
              _buildSectionCard(
                title: 'Feedback Táctil & Sonido',
                subtitle: 'Respuesta física al responder preguntas en móvil y escritorio',
                icon: Icons.vibration_rounded,
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Vibración háptica',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Vibración sutil al seleccionar respuestas correctas o incorrectas.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      value: settings.hapticsEnabled,
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFF065F46),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: const Color(0xFF374151),
                      onChanged: (val) {
                        onSettingsChanged(settings.copyWith(hapticsEnabled: val));
                      },
                    ),
                    const Divider(color: Color(0xFF1F2633), height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Sonidos de confirmación',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Reproduce un tono discreto al acertar un repaso.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      value: settings.soundEnabled,
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFF065F46),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: const Color(0xFF374151),
                      onChanged: (val) {
                        onSettingsChanged(settings.copyWith(soundEnabled: val));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Modo Silencioso / Horas de Estudio
              _buildSectionCard(
                title: 'Modo Silencioso / Horas de Sueño',
                subtitle: 'Pausa los recordatorios automáticos durante tus horas de descanso',
                icon: Icons.bedtime_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Pausar recordatorios por horario',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      subtitle: Text(
                        settings.quietHoursEnabled
                            ? 'Silenciado desde las ${settings.quietStartHour.toString().padLeft(2, '0')}:00 hasta las ${settings.quietEndHour.toString().padLeft(2, '0')}:00'
                            : 'Los recordatorios se emitirán continuamente según tu frecuencia',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      value: settings.quietHoursEnabled,
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFF065F46),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: const Color(0xFF374151),
                      onChanged: (val) {
                        onSettingsChanged(settings.copyWith(quietHoursEnabled: val));
                      },
                    ),
                    if (settings.quietHoursEnabled) ...[
                      const Divider(color: Color(0xFF1F2633), height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hora de inicio (Dormir)',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(hour: settings.quietStartHour, minute: 0),
                                      helpText: 'Selecciona hora de inicio de silencio',
                                    );
                                    if (picked != null) {
                                      onSettingsChanged(settings.copyWith(quietStartHour: picked.hour));
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1F2A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF283244)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${settings.quietStartHour.toString().padLeft(2, '0')}:00',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF34D399)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hora de fin (Despertar)',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(hour: settings.quietEndHour, minute: 0),
                                      helpText: 'Selecciona hora de fin de silencio',
                                    );
                                    if (picked != null) {
                                      onSettingsChanged(settings.copyWith(quietEndHour: picked.hour));
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1F2A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF283244)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${settings.quietEndHour.toString().padLeft(2, '0')}:00',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const Icon(Icons.wb_sunny_outlined, size: 16, color: Color(0xFF34D399)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Bloqueo de Pantalla y Modo Enfoque
              _buildSectionCard(
                title: 'Modo Enfoque & Bloqueo de Pantalla',
                subtitle: 'Control de atención al momento de responder una pregunta',
                icon: Icons.fullscreen_rounded,
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Bloqueo de pantalla',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Muestra el cuestionario a pantalla completa y bloquea distracciones hasta responder.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      value: settings.fullScreenLock,
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFF065F46),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: const Color(0xFF374151),
                      onChanged: (val) {
                        onSettingsChanged(settings.copyWith(fullScreenLock: val));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Material(
      color: const Color(0xFF13171F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF202633)),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2533),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF34D399), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
    );
  }

  Widget _buildIntervalPill(int minutes, String label, BuildContext context) {
    final bool isSelected = settings.frequencyMinutes == minutes;
    return InkWell(
      onTap: () {
        onSettingsChanged(settings.copyWith(frequencyMinutes: minutes));
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF064E3B) : const Color(0xFF191F2B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF283244),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

