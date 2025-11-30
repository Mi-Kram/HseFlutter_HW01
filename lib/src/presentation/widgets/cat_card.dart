import 'package:catotinder/src/domain/cat.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Карточка кота для свайпа.
class CatCard extends StatelessWidget {
  /// Данные кота.
  final Cat _cat;

  /// Callback на нажатие.
  final VoidCallback onTap;

  const CatCard({super.key, required Cat cat, required this.onTap})
    : _cat = cat;

  @override
  Widget build(BuildContext context) {
    // Список пород в одной строке.
    final title = _cat.breeds.isEmpty
        ? 'Неизвестная порода'
        : _cat.breeds.map((x) => x.name).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        // Округление карточки.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Область картинки кота.
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                // Картинка - CachedNetworkImage
                child: CachedNetworkImage(
                  imageUrl: _cat.url,
                  // Заглужка на время, пока картинка грузится из интернета.
                  placeholder: (c, u) => Image.asset(
                    'assets/placeholder.gif',
                    fit: BoxFit.contain,
                  ),
                  // Заглужка, если при загрузке картинки произошла ошибка.
                  errorWidget: (c, u, e) =>
                      Image.asset('assets/fail.jpg', fit: BoxFit.contain),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
            // Отображение пород кота.
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
