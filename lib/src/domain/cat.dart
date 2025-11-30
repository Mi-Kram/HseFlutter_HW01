class Cat {
  final String id;
  final String url;
  List<Breed> breeds;

  Cat({required this.id, required this.url, this.breeds = const []});
}

class Breed {
  final String id;
  final String name;
  final String? description;
  final int? adaptability;
  final int? affectionLevel;
  final int? intelligence;

  Breed({
    required this.id,
    required this.name,
    this.description,
    this.adaptability,
    this.affectionLevel,
    this.intelligence,
  });
}
