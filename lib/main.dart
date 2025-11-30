import 'package:catotinder/src/app.dart';
import 'package:catotinder/src/repository/data_manager.dart';
import 'package:catotinder/src/service/cat_service.dart';
import 'package:dio_http/dio_http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');

  // Инициализация зависимостей.
  final Dio httpClient = Dio(
    BaseOptions(
      baseUrl: dotenv.get('CATS_ENDPOINT'),
      headers: {'x-api-key': dotenv.get('API_KEY')},
    ),
  );

  final catService = CatService(client: httpClient);
  final catDataManager = CatDataManager();
  final breedDataManager = BreedDataManager();

  // Запуск приложения.
  runApp(
    AppWidget(
      catService: catService,
      catDataManager: catDataManager,
      breedDataManager: breedDataManager,
    ),
  );
}
