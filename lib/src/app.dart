import 'package:catotinder/src/presentation/breeds_screen.dart';
import 'package:catotinder/src/presentation/cats_screen.dart';
import 'package:catotinder/src/repository/data_manager.dart';
import 'package:catotinder/src/service/cat_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Главный виджет приложения: отвечает за создание виджета переключения
/// вкладок [TabControllerWidget]; инициализирует и устанавливает тему приложения.
class AppWidget extends StatefulWidget {
  final CatService _catService;
  final CatDataManager _catDataManager;
  final BreedDataManager _breedDataManager;

  const AppWidget({
    super.key,
    required CatService catService,
    required CatDataManager catDataManager,
    required BreedDataManager breedDataManager,
  }) : _catService = catService,
       _catDataManager = catDataManager,
       _breedDataManager = breedDataManager;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  // Флаг тёмной темы.
  final _prefs = SharedPreferencesAsync();
  final _isDarkPrefsStr = 'IS_DARK';
  bool _isDark = false;
  bool _isSystemTheme = true;

  void _toggleTheme() {
    _isSystemTheme = false;
    setState(() {
      _isDark = !_isDark;
      _prefs.setBool(_isDarkPrefsStr, _isDark);
    });
  }

  @override
  void initState() {
    super.initState();

    Future.wait([
      // Загружаем ранее установленную тему.
      _prefs.getBool(_isDarkPrefsStr).then((res) {
        if (res == null) {
          return;
        }

        _isSystemTheme = false;

        if (mounted) {
          setState(() => _isDark = res);
        } else {
          _isDark = res;
        }
      }),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Если тема установлена (не как в системе).
    if (!_isSystemTheme) {
      return;
    }

    // Устанавливаем тему как в системе (по умолчанию).
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (mounted) {
      setState(() => _isDark = isDark);
    } else {
      _isDark = isDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Кототиндер',

      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // ----------------- СВЕТЛАЯ ТЕМА -----------------
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 167, 121, 208),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 167, 121, 208),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),

        scaffoldBackgroundColor: Colors.white,

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 167, 121, 208),
          foregroundColor: Colors.white,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),

        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),

      // ----------------- ТЕМНАЯ ТЕМА -----------------
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 167, 121, 208),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 94, 63, 124),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),

        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 167, 121, 208),
          foregroundColor: Colors.black,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),

        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),

      home: TabControllerWidget(
        catService: widget._catService,
        catDataManager: widget._catDataManager,
        breedDataManager: widget._breedDataManager,
        onToggleTheme: _toggleTheme,
        isDark: _isDark,
      ),
    );
  }
}

/// Виджет для переключения вкладок и переключения темы приложения.
class TabControllerWidget extends StatefulWidget {
  final CatService _catService;
  final CatDataManager _catDataManager;
  final BreedDataManager _breedDataManager;

  final VoidCallback _onToggleTheme;
  final bool _isDark;

  const TabControllerWidget({
    super.key,
    required CatService catService,
    required CatDataManager catDataManager,
    required BreedDataManager breedDataManager,
    required VoidCallback onToggleTheme,
    required bool isDark,
  }) : _catService = catService,
       _catDataManager = catDataManager,
       _breedDataManager = breedDataManager,
       _onToggleTheme = onToggleTheme,
       _isDark = isDark;

  @override
  State<TabControllerWidget> createState() => TabControllerWidgetState();
}

class TabControllerWidgetState extends State<TabControllerWidget> {
  int _index = 0;
  late final List<Map<String, dynamic>> tabs;

  @override
  void initState() {
    super.initState();
    tabs = [
      {
        'title': 'Кототиндер',
        'screen': CatsScreen(
          catService: widget._catService,
          dataManager: widget._catDataManager,
        ),
      },
      {
        'title': 'Породы',
        'screen': BreedsScreen(
          catService: widget._catService,
          dataManager: widget._breedDataManager,
        ),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[_index]['title']),
        actions: [
          IconButton(
            icon: Icon(widget._isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget._onToggleTheme,
          ),
        ],
      ),
      body: tabs[_index]['screen'],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Котики'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Породы'),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
