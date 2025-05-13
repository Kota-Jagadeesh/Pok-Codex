// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  // Fetch list of Pokémon
  Future<List<PokemonListItem>> fetchPokemonList({int limit = 151}) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=$limit'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((item) => PokemonListItem.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load Pokémon list');
    }
  }

  // Fetch Pokémon details by URL
  Future<Pokemon> fetchPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }
}
