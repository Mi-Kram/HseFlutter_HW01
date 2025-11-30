import 'package:cached_network_image/cached_network_image.dart';
import 'package:catotinder/src/domain/cat.dart';
import 'package:flutter/material.dart';

/// Детальная информация о коте.
class CatDetailScreen extends StatelessWidget {
  final Cat _cat;

  const CatDetailScreen({super.key, required Cat cat}) : _cat = cat;

  @override
  Widget build(BuildContext context) {
    // Список пород в одной строке.
    final title = _cat.breeds.isEmpty
        ? 'Неизвестная порода'
        : _cat.breeds.map((x) => x.name).join(', ');
    // Первая порода.
    final breed = _cat.breeds.isEmpty ? null : _cat.breeds[0];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      // Прокрутка страницы.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Картинка кота.
            SizedBox(
              child: CachedNetworkImage(
                imageUrl: _cat.url,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (c, u) =>
                    Image.asset('assets/placeholder.gif', fit: BoxFit.contain),
                errorWidget: (c, u, e) =>
                    Image.asset('assets/fail.jpg', fit: BoxFit.contain),
              ),
            ),
            // Информация о породе.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: breed == null
                  // Порода не указана.
                  ? const Text('Информация о породе недоступна')
                  // Порода указана.
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Название породы.
                        Text(
                          breed.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Описание породы.
                        Text(breed.description ?? ''),
                        const SizedBox(height: 12),
                        // Характеристика породы.
                        Text('Адаптивность: ${breed.adaptability ?? '-'}'),
                        Text('Привязанность: ${breed.affectionLevel ?? '-'}'),
                        Text('Интеллект: ${breed.intelligence ?? '-'}'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
