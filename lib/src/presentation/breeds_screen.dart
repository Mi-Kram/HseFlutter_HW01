import 'dart:io';

import 'package:catotinder/src/domain/cat.dart';
import 'package:catotinder/src/presentation/breed_details_screen.dart';
import 'package:catotinder/src/repository/data_manager.dart';
import 'package:catotinder/src/service/cat_service.dart';
import 'package:dio_http/dio_http.dart';
import 'package:flutter/material.dart';

/// Страница просмотра списка пород котов.
class BreedsScreen extends StatefulWidget {
  /// Сервис для загрузки пород.
  final CatService _catService;

  /// Хранение данных.
  final BreedDataManager _dataManager;

  const BreedsScreen({
    super.key,
    required CatService catService,
    required BreedDataManager dataManager,
  }) : _catService = catService,
       _dataManager = dataManager;

  @override
  State<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends State<BreedsScreen> {
  /// Сервис для загрузки пород.
  late final CatService _catService;

  /// Хранение данных.
  late final BreedDataManager _dataManager;

  /// Флаг ошибки загрузки информации.
  bool? _loadFailed;

  // [Future], который грузит информацию.
  Future<void>? _futureLoadBreeds;

  @override
  void initState() {
    super.initState();

    // Инициализация данных.
    _catService = widget._catService;
    _dataManager = widget._dataManager;

    // Первичная загрузка информации.
    if (_dataManager.list.isEmpty) _futureLoadBreeds = _loadBreeds();
  }

  /// Загрузка информации.
  Future<void> _loadBreeds() async {
    setState(() => _loadFailed = false);
    late String errMsg;

    try {
      // Получение списка пород.
      List<Breed> breeds = await _catService.getAllBreeds();

      // Обновление списка в хранилище.
      if (mounted) {
        setState(() {
          _dataManager.list.clear();
          _dataManager.list.addAll(breeds);
        });
      } else {
        _dataManager.list.clear();
        _dataManager.list.addAll(breeds);
      }

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
      _futureLoadBreeds = null;
    }

    // Вывод информации пользователю.
    BuildContext ctx = context;
    if (ctx.mounted) {
      ScaffoldMessengerState sms = ScaffoldMessenger.of(ctx);
      sms.hideCurrentSnackBar();
      sms.showSnackBar(SnackBar(content: Text(errMsg)));
      setState(() => _loadFailed = true);
    }
  }

  /// Ручное команда обновления данных.
  Future<void> _pullRefresh() async {
    // Если данные уже обновляются.
    if (_futureLoadBreeds != null) return;

    // Запуск обновления информации.
    _futureLoadBreeds = _loadBreeds();
    await _futureLoadBreeds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Индикатор для прокрутки вниз для обновления информации.
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: _dataManager.list.isEmpty
            // Данных о породах нет.
            ? Center(
                child: _loadFailed == true
                    // Если произошла ошибка.
                    ? const Text('Ошибка при загрузке данных')
                    // Данные загружаются.
                    : const CircularProgressIndicator(),
              )
            // Отображения данных.
            : ListView.builder(
                itemCount: _dataManager.list.length,
                itemBuilder: (c, i) {
                  final b = _dataManager.list[i];
                  return Column(
                    children: [
                      ListTile(
                        // Название породы
                        title: Text(b.name),
                        // Часть описания
                        subtitle: Text(b.description?.split('.').first ?? ''),
                        titleTextStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        // Обработка нажатия на породу.
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BreedDetailScreen(breed: b),
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
