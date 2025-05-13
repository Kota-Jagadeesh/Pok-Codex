// lib/models/pokemon.dart
import 'dart:convert';

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

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ?? '',
      types: (json['types'] as List)
          .map((type) => type['type']['name'].toString())
          .toList(),
      height: (json['height'] / 10).toDouble(), // Convert decimeters to meters
      weight:
          (json['weight'] / 10).toDouble(), // Convert hectograms to kilograms
      abilities: (json['abilities'] as List)
          .map((ability) => ability['ability']['name'].toString())
          .toList(),
    );
  }
}
