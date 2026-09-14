import 'package:flutter/material.dart';
import '../core/content_manager.dart';
import '../models/app_settings.dart';

/// Representation of a learning category.
class TopicCategory {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;

  const TopicCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
  });
}

/// Representation of an individual topic/pack.
class TopicItem {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final IconData icon;
  final String description;
  final int defaultQuestionCount;
  final Color accentColor;
  final List<String> tags;

  const TopicItem({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.description,
    required this.defaultQuestionCount,
    required this.accentColor,
    this.tags = const [],
  });
}

/// Modern screen to configure learning topics, languages, principles, and patterns.
class TopicsPage extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const TopicsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<TopicCategory> _categories = [
    TopicCategory(
      id: 'all',
      name: 'Todos',
      emoji: '⚡',
      icon: Icons.grid_view_rounded,
    ),
    TopicCategory(
      id: 'languages',
      name: 'Lenguajes',
      emoji: '💻',
      icon: Icons.code_rounded,
    ),
    TopicCategory(
      id: 'fundamentals',
      name: 'POO & Fundamentos',
      emoji: '🏛️',
      icon: Icons.account_balance_rounded,
    ),
    TopicCategory(
      id: 'architecture',
      name: 'Arquitectura',
      emoji: '🏗️',
      icon: Icons.architecture_rounded,
    ),
    TopicCategory(
      id: 'agile',
      name: 'Agile & SCRUM',
      emoji: '🏃',
      icon: Icons.groups_rounded,
    ),
    TopicCategory(
      id: 'databases',
      name: 'Bases de Datos',
      emoji: '🗄️',
      icon: Icons.storage_rounded,
    ),
    TopicCategory(
      id: 'networks',
      name: 'Redes & APIs',
      emoji: '🌐',
      icon: Icons.wifi_rounded,
    ),
    TopicCategory(
      id: 'security',
      name: 'Ciberseguridad',
      emoji: '🔒',
      icon: Icons.security_rounded,
    ),
    TopicCategory(
      id: 'devops',
      name: 'DevOps & Cloud',
      emoji: '☁️',
      icon: Icons.cloud_queue_rounded,
    ),
    TopicCategory(
      id: 'dsa',
      name: 'Estructuras & Algoritmos',
      emoji: '🧩',
      icon: Icons.psychology_rounded,
    ),
    TopicCategory(
      id: 'ai',
      name: 'Inteligencia Artificial',
      emoji: '🤖',
      icon: Icons.smart_toy_rounded,
    ),
  ];

  static const List<TopicItem> _allTopics = [
    // --- Lenguajes de Programación ---
    TopicItem(
      id: 'Python',
      title: 'Python',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.terminal_rounded,
      description:
          'Sintaxis concisa, tipado dinámico, decoradores, generadores y el ecosistema Pythonic.',
      defaultQuestionCount: 24,
      accentColor: Color(0xFF38BDF8),
      tags: ['python', 'backend', 'scripts', 'dynamic', 'data'],
    ),
    TopicItem(
      id: 'Java',
      title: 'Java',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.coffee_rounded,
      description:
          'Ecosistema JVM, recolector de basura, concurrencia multihilo y fuerte tipado estático.',
      defaultQuestionCount: 28,
      accentColor: Color(0xFFFB923C),
      tags: ['java', 'jvm', 'backend', 'enterprise', 'threading'],
    ),
    TopicItem(
      id: 'JavaScript',
      title: 'JavaScript',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.javascript_rounded,
      description:
          'Event Loop, closures, prototipos, programación asíncrona (Promises, async/await) y ES6+.',
      defaultQuestionCount: 22,
      accentColor: Color(0xFFFBBF24),
      tags: ['javascript', 'js', 'frontend', 'async', 'web', 'node'],
    ),
    TopicItem(
      id: 'Go',
      title: 'Go (Golang)',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.bolt_rounded,
      description:
          'Concurrencia nativa mediante Goroutines y Channels, tipado estático y compilación ultra veloz.',
      defaultQuestionCount: 18,
      accentColor: Color(0xFF22D3EE),
      tags: ['go', 'golang', 'backend', 'concurrencia', 'cloud'],
    ),
    TopicItem(
      id: 'Dart',
      title: 'Dart',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.flutter_dash_rounded,
      description:
          'Sound null safety, compilación AOT/JIT, isolates, streams y optimización para Flutter.',
      defaultQuestionCount: 16,
      accentColor: Color(0xFF34D399),
      tags: ['dart', 'flutter', 'mobile', 'frontend', 'sound-null-safety'],
    ),

    // --- Fundamentos & POO ---
    TopicItem(
      id: 'POO',
      title: 'Programación Orientada a Objetos',
      categoryId: 'fundamentals',
      categoryName: '🏛️ POO',
      icon: Icons.category_rounded,
      description:
          'Pilares esenciales: encapsulamiento, herencia, abstracción, acoplamiento y cohesión.',
      defaultQuestionCount: 25,
      accentColor: Color(0xFFA78BFA),
      tags: ['poo', 'oop', 'objetos', 'clases', 'herencia', 'fundamentos'],
    ),
    TopicItem(
      id: 'Abstracción',
      title: 'Abstracción',
      categoryId: 'fundamentals',
      categoryName: '🏛️ POO',
      icon: Icons.layers_rounded,
      description:
          'Ocultamiento de complejidad, modelado conceptual, clases abstractas e interfaces puras.',
      defaultQuestionCount: 14,
      accentColor: Color(0xFFC084FC),
      tags: ['abstracción', 'interfaces', 'contratos', 'oop', 'modelado'],
    ),
    TopicItem(
      id: 'Polimorfismo',
      title: 'Polimorfismo',
      categoryId: 'fundamentals',
      categoryName: '🏛️ POO',
      icon: Icons.transform_rounded,
      description:
          'Despacho dinámico de métodos, sobreescritura (override), sobrecarga e interfaces polimórficas.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFFF472B6),
      tags: ['polimorfismo', 'overriding', 'overloading', 'oop', 'subtipos'],
    ),

    // --- Principios & Metodologías ---
    TopicItem(
      id: 'SOLID',
      title: 'Principios SOLID',
      categoryId: 'principles',
      categoryName: '📐 Principios',
      icon: Icons.verified_user_rounded,
      description:
          'Los 5 principios fundamentales: SRP, OCP, LSP, ISP y DIP para arquitecturas mantenibles.',
      defaultQuestionCount: 20,
      accentColor: Color(0xFF10B981),
      tags: ['solid', 'srp', 'ocp', 'lsp', 'isp', 'dip', 'arquitectura'],
    ),
    TopicItem(
      id: 'Clean Code',
      title: 'Clean Code',
      categoryId: 'principles',
      categoryName: '📐 Principios',
      icon: Icons.auto_awesome_rounded,
      description:
          'Nombres significativos, funciones de propósito único, eliminación de code smells y legibilidad.',
      defaultQuestionCount: 18,
      accentColor: Color(0xFF2DD4BF),
      tags: ['clean code', 'refactor', 'legibilidad', 'buenas practicas'],
    ),
    TopicItem(
      id: 'DRY/KISS',
      title: 'DRY & KISS',
      categoryId: 'principles',
      categoryName: '📐 Principios',
      icon: Icons.repeat_one_rounded,
      description:
          "Don't Repeat Yourself y Keep It Simple, Stupid: combate la duplicación y el sobre-diseño.",
      defaultQuestionCount: 12,
      accentColor: Color(0xFF059669),
      tags: ['dry', 'kiss', 'yagni', 'principios', 'simplicidad'],
    ),

    // --- Patrones & Arquitectura ---
    TopicItem(
      id: 'Singleton',
      title: 'Patrón Singleton',
      categoryId: 'patterns',
      categoryName: '🏗️ Patrones',
      icon: Icons.filter_1_rounded,
      description:
          'Instancia única global, control de concurrencia y acceso centralizado a recursos clave.',
      defaultQuestionCount: 12,
      accentColor: Color(0xFF818CF8),
      tags: ['singleton', 'patron', 'instancia', 'creacional', 'patrones'],
    ),
    TopicItem(
      id: 'Factory',
      title: 'Factory & Abstract Factory',
      categoryId: 'patterns',
      categoryName: '🏗️ Patrones',
      icon: Icons.precision_manufacturing_rounded,
      description:
          'Desacoplamiento de la creación de objetos respecto de sus implementaciones concretas.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFF6366F1),
      tags: ['factory', 'abstract factory', 'creacional', 'patrones'],
    ),
    TopicItem(
      id: 'Observer',
      title: 'Patrón Observer',
      categoryId: 'patterns',
      categoryName: '🏗️ Patrones',
      icon: Icons.sensors_rounded,
      description:
          'Mecanismo reactivo de suscripción para propagar cambios de estado entre objetos desacoplados.',
      defaultQuestionCount: 14,
      accentColor: Color(0xFF38BDF8),
      tags: ['observer', 'reactivo', 'eventos', 'pubsub', 'comportamiento'],
    ),
    TopicItem(
      id: 'TypeScript',
      title: 'TypeScript',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.integration_instructions_rounded,
      description:
          'Tipado estático sobre JavaScript, interfaces, genéricos, utility types y type narrowing.',
      defaultQuestionCount: 20,
      accentColor: Color(0xFF3178C6),
      tags: ['typescript', 'ts', 'javascript', 'frontend', 'types'],
    ),
    TopicItem(
      id: 'Rust',
      title: 'Rust',
      categoryId: 'languages',
      categoryName: '💻 Lenguaje',
      icon: Icons.shield_rounded,
      description:
          'Ownership, Borrowing, Lifetimes, cero costos de abstracción y ausencia total de data races.',
      defaultQuestionCount: 18,
      accentColor: Color(0xFFDEA584),
      tags: ['rust', 'systems', 'memory', 'ownership', 'concurrency'],
    ),
    TopicItem(
      id: 'Patrones de Diseño',
      title: 'Patrones de Diseño (GoF)',
      categoryId: 'architecture',
      categoryName: '🏗️ Arquitectura',
      icon: Icons.account_tree_rounded,
      description:
          'Catálogo de soluciones estándar: Strategy, Adapter, Decorator, Facade, Command y más.',
      defaultQuestionCount: 24,
      accentColor: Color(0xFFFB7185),
      tags: ['patrones', 'gof', 'strategy', 'adapter', 'decorator', 'facade'],
    ),
    TopicItem(
      id: 'arquitectura_hexagonal',
      title: 'Arquitectura Hexagonal & Clean',
      categoryId: 'architecture',
      categoryName: '🏗️ Arquitectura',
      icon: Icons.hexagon_outlined,
      description:
          'Puertos y Adaptadores, regla de dependencia, dominio desacoplado, Sagas distribuidas y Circuit Breaker.',
      defaultQuestionCount: 18,
      accentColor: Color(0xFF38BDF8),
      tags: ['arquitectura', 'hexagonal', 'clean', 'ports', 'adapters', 'sagas', 'microservicios'],
    ),
    TopicItem(
      id: 'metodologia_scrum',
      title: 'Metodología SCRUM & Agile',
      categoryId: 'agile',
      categoryName: '🏃 Agile',
      icon: Icons.groups_rounded,
      description:
          'Roles (PO, SM, Devs), ceremonias (Daily, Review, Retro), Definition of Done (DoD) y límites WIP en Kanban.',
      defaultQuestionCount: 16,
      accentColor: Color(0xFFF59E0B),
      tags: ['scrum', 'agile', 'kanban', 'sprint', 'dod', 'planning'],
    ),
    // --- Bases de Datos ---
    TopicItem(
      id: 'bases_de_datos',
      title: 'Bases de Datos (Fundamentos)',
      categoryId: 'databases',
      categoryName: '🗄️ Bases de Datos',
      icon: Icons.storage_rounded,
      description:
          'ACID vs BASE, Teorema CAP, Sharding, normalización 3NF, bloqueos optimistas vs pesimistas y deadlocks.',
      defaultQuestionCount: 12,
      accentColor: Color(0xFF10B981),
      tags: ['sql', 'nosql', 'acid', 'cap', 'indices', 'database', 'sharding', 'transacciones'],
    ),
    TopicItem(
      id: 'postgresql',
      title: 'PostgreSQL',
      categoryId: 'databases',
      categoryName: '🗄️ Bases de Datos',
      icon: Icons.storage_rounded,
      description:
          'MVCC, dead tuples, VACUUM/autovacuum, índices GIN/GiST/BRIN, tipos JSONB, aislamiento Serializable y pgvector.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFF336791),
      tags: ['postgres', 'postgresql', 'mvcc', 'vacuum', 'gin', 'gist', 'jsonb', 'pgvector', 'sql'],
    ),
    TopicItem(
      id: 'mysql',
      title: 'MySQL & MariaDB',
      categoryId: 'databases',
      categoryName: '🗄️ Bases de Datos',
      icon: Icons.dns_rounded,
      description:
          'Motores InnoDB vs MyISAM, Buffer Pool LRU, Record/Gap/Next-Key locks, replicación con binlog y planes EXPLAIN.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFF00758F),
      tags: ['mysql', 'mariadb', 'innodb', 'buffer-pool', 'binlog', 'locks', 'explain', 'sql'],
    ),
    TopicItem(
      id: 'mongodb',
      title: 'MongoDB & NoSQL',
      categoryId: 'databases',
      categoryName: '🗄️ Bases de Datos',
      icon: Icons.folder_copy_rounded,
      description:
          'Documentos BSON, motor WiredTiger, Aggregation Pipelines, Replica Sets con Raft, Sharding horizontal y transacciones ACID.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFF47A248),
      tags: ['mongodb', 'mongo', 'nosql', 'bson', 'wiredtiger', 'aggregation', 'replica-sets', 'sharding'],
    ),
    TopicItem(
      id: 'redis',
      title: 'Redis & In-Memory',
      categoryId: 'databases',
      categoryName: '🗄️ Bases de Datos',
      icon: Icons.bolt_rounded,
      description:
          'Multiplexación I/O monohilo, Hashes, Sorted Sets, persistencia RDB vs AOF, Eviction LRU/LFU, Redlock y mitigación de stampede.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFFDC382D),
      tags: ['redis', 'cache', 'in-memory', 'rdb', 'aof', 'pub-sub', 'lru', 'redlock'],
    ),
    TopicItem(
      id: 'sqlite',
      title: 'SQLite & Embebidas',
      categoryId: 'databases',
      categoryName: '🗄️ Bases de Datos',
      icon: Icons.save_rounded,
      description:
          'Arquitectura serverless en un archivo, modo WAL (Write-Ahead Logging) para lecturas concurrentes, pragmas de rendimiento y FTS5.',
      defaultQuestionCount: 12,
      accentColor: Color(0xFF003B57),
      tags: ['sqlite', 'wal', 'embedded', 'mobile', 'local', 'sql', 'serverless'],
    ),
    TopicItem(
      id: 'redes_y_apis',
      title: 'Redes & Protocolos HTTP',
      categoryId: 'networks',
      categoryName: '🌐 Redes & APIs',
      icon: Icons.wifi_rounded,
      description:
          'Idempotencia REST, HTTP/2 multiplexado, gRPC vs REST, WebSockets vs SSE y TCP vs UDP.',
      defaultQuestionCount: 16,
      accentColor: Color(0xFF6366F1),
      tags: ['http', 'rest', 'grpc', 'websockets', 'tcp', 'udp', 'redes'],
    ),
    TopicItem(
      id: 'ciberseguridad_web',
      title: 'Ciberseguridad Web (OWASP)',
      categoryId: 'security',
      categoryName: '🔒 Seguridad',
      icon: Icons.security_rounded,
      description:
          'Mitigación de XSS, CSRF, Inyección SQL, cookies HttpOnly, autenticación JWT y políticas CORS.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFFEF4444),
      tags: ['seguridad', 'owasp', 'xss', 'csrf', 'jwt', 'cors', 'sql-injection'],
    ),
    TopicItem(
      id: 'devops_cloud',
      title: 'DevOps, Docker & Cloud',
      categoryId: 'devops',
      categoryName: '☁️ DevOps',
      icon: Icons.cloud_queue_rounded,
      description:
          'Contenedores vs VMs, multi-stage builds, pods en Kubernetes, Trunk-Based vs GitFlow y SemVer.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFF06B6D4),
      tags: ['docker', 'kubernetes', 'devops', 'gitflow', 'ci-cd', 'cloud'],
    ),
    TopicItem(
      id: 'estructuras_algoritmos',
      title: 'Estructuras & Algoritmos (DSA)',
      categoryId: 'dsa',
      categoryName: '🧩 Algoritmos',
      icon: Icons.psychology_rounded,
      description:
          'Complejidad Big-O, resolución de colisiones en HashMaps, Árboles BST y recorridos BFS vs DFS.',
      defaultQuestionCount: 15,
      accentColor: Color(0xFFA855F7),
      tags: ['dsa', 'big-o', 'arboles', 'grafos', 'hashmap', 'algoritmos', 'busqueda'],
    ),

    // --- Inteligencia Artificial ---
    TopicItem(
      id: 'ia_generativa_llms',
      title: 'IA Generativa & LLMs',
      categoryId: 'ai',
      categoryName: '🤖 Inteligencia Artificial',
      icon: Icons.psychology_alt_rounded,
      description:
          'Mecanismo de Self-Attention en Transformers, RAG híbrido, Embeddings vectoriales, Fine-Tuning y Function Calling.',
      defaultQuestionCount: 6,
      accentColor: Color(0xFF10B981),
      tags: ['ia', 'llm', 'rag', 'transformers', 'gpt', 'embeddings', 'prompt-engineering', 'ai'],
    ),
    TopicItem(
      id: 'ia_machine_learning',
      title: 'Machine Learning & Deep Learning',
      categoryId: 'ai',
      categoryName: '🤖 Inteligencia Artificial',
      icon: Icons.auto_awesome_rounded,
      description:
          'Aprendizaje supervisado vs no supervisado, Tradeoff Sesgo-Varianza, Precisión vs Recall, Backpropagation y RLHF.',
      defaultQuestionCount: 5,
      accentColor: Color(0xFF8B5CF6),
      tags: ['machine-learning', 'deep-learning', 'backpropagation', 'rlhf', 'datos', 'ia', 'ml'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isTopicActive(TopicItem topic) {
    return widget.settings.activeLanguages.any(
      (lang) =>
          lang.toLowerCase() == topic.id.toLowerCase() ||
          lang.toLowerCase() == topic.title.toLowerCase(),
    );
  }

  void _toggleTopic(TopicItem topic) {
    final current = List<String>.from(widget.settings.activeLanguages);
    final index = current.indexWhere(
      (lang) =>
          lang.toLowerCase() == topic.id.toLowerCase() ||
          lang.toLowerCase() == topic.title.toLowerCase(),
    );

    if (index >= 0) {
      if (current.length <= 1) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Debes mantener al menos un tema activo para tus recordatorios.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.amberAccent, width: 1),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      current.removeAt(index);
    } else {
      current.add(topic.id);
    }

    widget.onSettingsChanged(widget.settings.copyWith(activeLanguages: current));
  }

  void _selectAllTopics() {
    final allIds = _allTopics.map((t) => t.id).toSet();
    final updated = Set<String>.from(widget.settings.activeLanguages)..addAll(allIds);
    widget.onSettingsChanged(widget.settings.copyWith(activeLanguages: updated.toList()));
  }

  void _resetToDefaultTopics() {
    widget.onSettingsChanged(
      widget.settings.copyWith(activeLanguages: const ['Python', 'Java']),
    );
  }

  int _getQuestionCount(TopicItem topic) {
    final cm = ContentManager();
    final questions = cm.getQuestionsByLanguage(topic.id.toLowerCase());
    if (questions.isNotEmpty) {
      return questions.length;
    }
    return topic.defaultQuestionCount;
  }

  List<TopicItem> _filterTopics(List<TopicItem> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final query = _searchQuery.trim().toLowerCase();

    return list.where((topic) {
      final matchesTitle = topic.title.toLowerCase().contains(query);
      final matchesId = topic.id.toLowerCase().contains(query);
      final matchesDesc = topic.description.toLowerCase().contains(query);
      final matchesCat = topic.categoryName.toLowerCase().contains(query);
      final matchesTags = topic.tags.any((tag) => tag.toLowerCase().contains(query));
      return matchesTitle || matchesId || matchesDesc || matchesCat || matchesTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _allTopics.where(_isTopicActive).length;
    final filteredTopics = _filterTopics(_allTopics);

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(activeCount),
            const SizedBox(height: 24),
            _buildSearchAndFilters(activeCount),
            const SizedBox(height: 28),
            _buildContentSection(filteredTopics),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int activeCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFF10B981),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Temas & Categorías',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Personaliza los lenguajes, fundamentos de POO, metodologías y patrones que nutren tus repasos espaciados.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Badges y botones de acción rápida
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$activeCount de ${_allTopics.length} activos',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: _selectAllTopics,
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Activar Todos'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton.icon(
                  onPressed: _resetToDefaultTopics,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Predeterminados'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(int activeCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de búsqueda moderna
        TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar temas, conceptos o tecnologías (ej: SOLID, Python, Singleton, POO)...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF10B981)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF1F2937),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF374151)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ChoiceChips de categorías
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              final categoryTopics = category.id == 'all'
                  ? _allTopics
                  : _allTopics.where((t) => t.categoryId == category.id).toList();
              final categoryActive = categoryTopics.where(_isTopicActive).length;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  avatar: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(category.emoji, style: const TextStyle(fontSize: 14)),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.name),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withOpacity(0.25)
                              : const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$categoryActive/${categoryTopics.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  backgroundColor: const Color(0xFF1F2937),
                  selectedColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade300,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF374151),
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(List<TopicItem> filteredTopics) {
    if (filteredTopics.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF374151)),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(
              'No se encontraron temas con "$_searchQuery"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con otra palabra clave o limpia el filtro de búsqueda.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategoryId = 'all';
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Limpiar Filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Si está en 'all' y no hay búsqueda, mostramos secciones categorizadas organizadas
    if (_selectedCategoryId == 'all' && _searchQuery.trim().isEmpty) {
      final categorySections = _categories.where((c) => c.id != 'all').toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categorySections.map((cat) {
          final catTopics = _allTopics.where((t) => t.categoryId == cat.id).toList();
          final activeInCat = catTopics.where(_isTopicActive).length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: '${cat.emoji} ${cat.name}',
                  activeCount: activeInCat,
                  totalCount: catTopics.length,
                ),
                const SizedBox(height: 16),
                _buildTopicGrid(catTopics),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Si hay categoría específica seleccionada o búsqueda activa
    final displayedCategory = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => _categories.first,
    );

    final topicsToDisplay = _selectedCategoryId == 'all'
        ? filteredTopics
        : filteredTopics.where((t) => t.categoryId == _selectedCategoryId).toList();

    final activeInSelection = topicsToDisplay.where(_isTopicActive).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: _selectedCategoryId == 'all'
              ? 'Resultados de búsqueda (${topicsToDisplay.length})'
              : '${displayedCategory.emoji} ${displayedCategory.name}',
          activeCount: activeInSelection,
          totalCount: topicsToDisplay.length,
        ),
        const SizedBox(height: 16),
        _buildTopicGrid(topicsToDisplay),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int activeCount,
    required int totalCount,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: activeCount > 0
                ? const Color(0xFF10B981).withOpacity(0.15)
                : const Color(0xFF374151),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activeCount > 0
                  ? const Color(0xFF10B981).withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            '$activeCount/$totalCount activos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activeCount > 0 ? const Color(0xFF34D399) : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid(List<TopicItem> topics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1250) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 780) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 220,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            final isActive = _isTopicActive(topic);
            final questionCount = _getQuestionCount(topic);
            return _buildTopicCard(topic, isActive, questionCount);
          },
        );
      },
    );
  }

  Widget _buildTopicCard(TopicItem topic, bool isActive, int questionCount) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isActive ? null : const Color(0xFF1F2937),
        gradient: isActive
            ? const LinearGradient(
                colors: [
                  Color(0xFF0F2C22),
                  Color(0xFF15222E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : const Color(0xFF374151),
          width: isActive ? 1.6 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _toggleTopic(topic),
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF10B981).withOpacity(0.1),
          highlightColor: const Color(0xFF10B981).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fila Superior: Icono + Categoría + Switch
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: topic.accentColor.withOpacity(isActive ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: topic.accentColor.withOpacity(isActive ? 0.5 : 0.2),
                        ),
                      ),
                      child: Icon(
                        topic.icon,
                        color: isActive ? topic.accentColor : Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF374151).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              topic.categoryName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: isActive,
                        activeColor: const Color(0xFF10B981),
                        activeTrackColor: const Color(0xFF065F46),
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: const Color(0xFF374151),
                        onChanged: (_) => _toggleTopic(topic),
                      ),
                    ),
                  ],
                ),

                // Título y Descripción
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),

                // Fila Inferior: Contador de Preguntas y Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 14,
                          color: isActive ? const Color(0xFF34D399) : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$questionCount preguntas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive ? const Color(0xFF34D399) : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF065F46).withOpacity(0.5)
                            : const Color(0xFF374151).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF10B981).withOpacity(0.6)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? const Color(0xFF10B981) : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isActive ? 'Activo' : 'Pausado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isActive ? const Color(0xFF34D399) : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
