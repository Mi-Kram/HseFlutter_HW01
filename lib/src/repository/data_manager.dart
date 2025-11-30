import 'dart:collection';

import 'package:catotinder/src/domain/cat.dart';

/// Репозиторий данных о котах.
class CatDataManager {
  final _queue = Queue<Cat>();

  Queue<Cat> get queue {
    return _queue;
  }
}

/// Репозиторий данных о породах.
class BreedDataManager {
  final List<Breed> _list = [];

  List<Breed> get list {
    return _list;
  }
}
