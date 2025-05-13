// import 'dart:convert';

class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({required this.name, required this.url});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'],
      url: json['url'],
    );
  }
}

class Pokemon {
  final String name;
  final String imageUrl;
  final List<String> types;
  final double height;
  final double weight;
  final List<String> abilities;
  final Map<String, int> stats; // added stats property

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats, // added to constructor
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ?? '',
      types: (json['types'] as List)
          .map((type) => type['type']['name'].toString())
          .toList(),
      height: (json['height'] / 10).toDouble(),
      weight: (json['weight'] / 10).toDouble(),
      abilities: (json['abilities'] as List)
          .map((ability) => ability['ability']['name'].toString())
          .toList(),
      stats: Map.fromEntries(
        (json['stats'] as List).map(
          (stat) => MapEntry(
            stat['stat']['name'].toString(),
            stat['base_stat'] as int,
          ),
        ),
      ), // parse stats into a Map
    );
  }
}
