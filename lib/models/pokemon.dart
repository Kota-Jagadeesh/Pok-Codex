// import 'dart:convert'; // for json parsing

// class to represent Pokemon in api list responses
class PokemonListItem {
  final int id; // added id field
  final String name;
  final String url; // contins the data for each Pokémon in the list

  PokemonListItem({required this.id, required this.name, required this.url});

  //factory method converts json to PokemonListItem
  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    // extracts the id from the URL
    final id = int.parse(url.split('/').where((part) => part.isNotEmpty).last);
    return PokemonListItem(
      id: id,
      name: json['name'],
      url: url,
    );
  }
}

// class for detailed Pokemon page to stores complete info of Pokemon
class Pokemon {
  final int id; //added ID field
  final String name;
  final String imageUrl;
  final List<String> types;
  final double height;
  final double weight;
  final Map<String, int> stats; //added stats property

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
  });

  // factory method to convert JSON data to Pokeon object
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'], // this directly use the ID from the JSON
      name: json['name'],
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ?? '',
      types: (json['types'] as List)
          .map((type) => type['type']['name'].toString())
          .toList(),
      height: (json['height'] / 10).toDouble(),
      weight: (json['weight'] / 10).toDouble(),
      stats: Map.fromEntries(
        (json['stats'] as List).map(
          (stat) => MapEntry(
            stat['stat']['name'].toString(),
            stat['base_stat'] as int,
          ),
        ),
      ), // Parse stats into a map
    );
  }
}
