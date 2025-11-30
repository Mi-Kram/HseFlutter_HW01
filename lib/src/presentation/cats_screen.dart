import 'dart:io';
import 'package:catotinder/src/presentation/cat_details_screen.dart';
import 'package:catotinder/src/presentation/widgets/cat_card.dart';
import 'package:catotinder/src/repository/data_manager.dart';
import 'package:synchronized/synchronized.dart' as synchronized;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:catotinder/src/domain/cat.dart';
import 'package:catotinder/src/service/cat_service.dart';
import 'package:dio_http/dio_http.dart';
import 'package:flutter/material.dart';

/// Основная страница приложения - просмотр/лайк/дизлайк котов.
class CatsScreen extends StatefulWidget {
  /// Сервис для загрузки котов.
  final CatService _catService;

  /// Хранение данных.
  final CatDataManager _dataManager;

  const CatsScreen({
    super.key,
    required CatService catService,
    required CatDataManager dataManager,
  }) : _catService = catService,
       _dataManager = dataManager;

  @override
  State<CatsScreen> createState() => _CatsScreenState();
}

class _CatsScreenState extends State<CatsScreen> {
  /// Сервис для загрузки котов.
  late final CatService _catService;

  /// Хранение данных.
  late final CatDataManager _dataManager;

  /// Синхронизированный доступ к данным.
  final _lockData = synchronized.Lock();

  /// [Future], загружающий данные.
  Future<void>? _futureDataLoader;

  // Лайки.
  final _prefs = SharedPreferencesAsync();
  final _likesPrefsStr = 'LIKES';
  int _likes = 0;

  /// Заглужка для загрузки котов.
  final _loadingCat = Cat(
    id: '',
    url: 'assets/placeholder.gif',
    breeds: [Breed(id: '', name: '')],
  );

  @override
  void initState() {
    super.initState();

    // Инициализация данных.
    _dataManager = widget._dataManager;
    _catService = widget._catService;

    // Загрузка данных.
    checkDataToLoad();

    // Восстанавливаем лайки, если они были раньше.
    Future.wait([
      _prefs.getInt(_likesPrefsStr).then((x) {
        if (x == null) return;

        if (mounted) {
          setState(() => _likes += x);
        } else {
          _likes += x;
        }
      }),
    ]);
  }

  // Проверка в необходимости в подгрузке данных.
  void checkDataToLoad() {
    if (_futureDataLoader != null || _dataManager.queue.length >= 10) return;
    _futureDataLoader = _loadCatObjects(10);
  }

  /// Загрузка информации о котах.
  Future<void> _loadCatObjects(int count) async {
    late String errMsg;

    try {
      // Загрузка данных.
      final cats = await _catService.getRandomCats(limit: count);

      // Добавление в репозиторий.
      await _lockData.synchronized(() {
        if (mounted) {
          setState(() => _dataManager.queue.addAll(cats));
        } else {
          _dataManager.queue.addAll(cats);
        }
      });

      return;
    } on DioError catch (e) {
      // Обработка сетевой ошибки.
      switch (e.response?.statusCode) {
        case HttpStatus.tooManyRequests:
          errMsg = 'Много запросов по API, подождите';
          break;
        default:
          errMsg = e.message;
          break;
      }
    } on Exception catch (e) {
      // Обработка ошибки.
      errMsg = e.toString();
    } catch (e) {
      // Обработка ошибки.
      errMsg = 'Не удось загрузить данные о котах';
    } finally {
      _futureDataLoader = null;
    }

    // Вывод информации пользователю.
    BuildContext ctx = context;
    if (ctx.mounted) {
      ScaffoldMessengerState sms = ScaffoldMessenger.of(ctx);
      sms.hideCurrentSnackBar();
      sms.showSnackBar(SnackBar(content: Text(errMsg)));
    }

    // Повторная загрузка объекта.
    if (mounted) {
      checkDataToLoad();
    }
  }

  // Обработка "Лайка".
  Future<void> _onLike() async {
    // Увеличение счётчика.
    setState(() {
      _prefs.setInt(_likesPrefsStr, ++_likes);
    });

    // Переход к следующему коту.
    await _showNextCat();
  }

  // Обработка "Дизлайка".
  Future<void> _onDislike() async {
    // Переход к следующему коту.
    await _showNextCat();
  }

  /// Переход к следующему коту.
  Future<void> _showNextCat() async {
    await _lockData.synchronized(() async {
      if (_dataManager.queue.isEmpty) return;

      // Удаление текущего кота.
      setState(() => _dataManager.queue.removeFirst());

      // Загрузка данных.
      checkDataToLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Карточка кота.
            Expanded(
              child: _dataManager.queue.isEmpty
                  // Данных нет - отображать карточку загрузки.
                  ? CatCard(cat: _loadingCat, onTap: () {})
                  // Элемент для смахивания по горизонтали.
                  : Dismissible(
                      key: ValueKey(_dataManager.queue.first.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (d) async {
                        // обработка лайка/дизлайка.
                        if (d == DismissDirection.endToStart) {
                          await _onDislike();
                        } else {
                          await _onLike();
                        }
                      },
                      // Отображение карточки кота.
                      child: CatCard(
                        cat: _dataManager.queue.first,
                        // Переход к детальной информации о коте.
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CatDetailScreen(
                                cat: _dataManager.queue.first,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            // Строка под карточкой: количество лайков и кнопки лайк/дизлайк.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Количество лайков
                Column(
                  children: [const Text('Лайков'), Text(_likes.toString())],
                ),
                // Отображение кнопок лайк/дизлайк, если есть объект.
                if (_dataManager.queue.isNotEmpty)
                  Row(
                    children: [
                      // Дизлайк.
                      IconButton(
                        onPressed: _onDislike,
                        icon: const Icon(Icons.clear, size: 36),
                      ),
                      const SizedBox(width: 12),
                      // Лайк.
                      IconButton(
                        onPressed: _onLike,
                        icon: const Icon(
                          Icons.favorite,
                          size: 36,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
