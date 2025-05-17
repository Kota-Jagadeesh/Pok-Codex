import 'dart:convert'; // Tool for encoding and decoding data
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonListItem>> fetchPokemonList(
      {int limit = 1500, int offset = 0}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((item) => PokemonListItem.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load Pokémon list');
    }
  }

  Future<Pokemon> fetchPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  Future<Pokemon> fetchPokemonDetailsById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));
    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Pokémon details for ID $id');
    }
  }
}
