import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonListItem>> fetchPokemonList(
      //refers to an obj that represents the value that is not yet available - but fetched at some point.
      {int limit = 100,
      int offset = 0}) async {
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
}
