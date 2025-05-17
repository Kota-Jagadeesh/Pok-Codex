import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon.dart';
import '../services/api_service.dart';
import 'pokemon_detail_page.dart';

class TradedPokemonPage extends StatefulWidget {
  final int userId;

  const TradedPokemonPage({super.key, required this.userId});

  @override
  _TradedPokemonPageState createState() => _TradedPokemonPageState();
}

class _TradedPokemonPageState extends State<TradedPokemonPage> {
  final ApiService _apiService = ApiService();
  List<Pokemon> _tradedPokemon = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTradedPokemon();
  }

  Future<void> _fetchTradedPokemon() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/traded/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tradedIds = List<String>.from(
            data['traded_pokemon'].map((id) => id.toString()));
        List<Pokemon> pokemonList = [];

        for (String id in tradedIds) {
          final pokemon = await _apiService.fetchPokemonDetailsById(id);
          pokemonList.add(pokemon);
        }

        setState(() {
          _tradedPokemon = pokemonList;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load traded Pokémon');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Traded Pokémon',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 217, 0),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Roboto',
                        fontSize: 18,
                      ),
                    ),
                  )
                : _tradedPokemon.isEmpty
                    ? const Center(
                        child: Text(
                          'No Pokémon traded yet',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 0.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _tradedPokemon.length,
                        itemBuilder: (context, index) {
                          final pokemon = _tradedPokemon[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PokemonDetailPage(
                                    pokemon: pokemon,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  pokemon.imageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.error,
                                    color: Color.fromARGB(255, 255, 17, 0),
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pokemon.name,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
