import 'package:dio_http/dio_http.dart';
import 'package:catotinder/src/domain/cat.dart';

/// Сервис для загрузки данных.
class CatService {
  Dio client;

  CatService({required this.client});

  /// Получить случайный список котов.
  Future<List<Cat>> getRandomCats({int limit = 10}) async {
    if (limit <= 0) return Future.value([]);

    final res = await client.get(
      '/v1/images/search?limit=$limit&has_breeds=true',
    );
    if (res.statusCode != 200) {
      throw DioError(requestOptions: res.requestOptions, response: res);
    }

    return (res.data as Iterable).map((x) => _catFromJson(x)).toList();
  }

  /// Получить список всех пород.
  Future<List<Breed>> getAllBreeds() async {
    final res = await client.get('/v1/breeds');
    if (res.statusCode != 200) {
      throw DioError(requestOptions: res.requestOptions, response: res);
    }

    return (res.data as Iterable).map((x) => _breedFromJson(x)).toList();
  }

  /// Конвертация словаря в Cat.
  Cat _catFromJson(Map<String, dynamic> dict) {
    return Cat(
      id: dict['id'],
      url: dict['url'],
      breeds:
          (dict['breeds'] as Iterable?)
              ?.map((x) => _breedFromJson(x))
              .toList() ??
          [],
    );
  }

  /// Конвертация словаря в Breed.
  Breed _breedFromJson(Map<String, dynamic> dict) {
    return Breed(
      id: dict['id'],
      name: dict['name'],
      description: dict['description'],
      adaptability: dict['adaptability'],
      affectionLevel: dict['affection_level'],
      intelligence: dict['intelligence'],
    );
  }
}
