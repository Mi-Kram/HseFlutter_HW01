import 'package:catotinder/src/domain/cat.dart';
import 'package:flutter/material.dart';

/// Детальная информация о породе.
class BreedDetailScreen extends StatelessWidget {
  /// Данные породы.
  final Breed _breed;

  const BreedDetailScreen({super.key, required Breed breed}) : _breed = breed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_breed.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название породы.
            Text(
              _breed.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Описание породы.
            Text(_breed.description ?? 'Описание недоступно'),
            const SizedBox(height: 12),

            // Характеристики породы.
            const Text('Характеристики:'),
            const SizedBox(height: 8),
            Text('Адаптивность: ${_breed.adaptability ?? '-'}'),
            Text('Привязанность: ${_breed.affectionLevel ?? '-'}'),
            Text('Интеллект: ${_breed.intelligence ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
