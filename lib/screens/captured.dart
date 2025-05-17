import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon.dart';
import '../services/api_service.dart';
import 'pokemon_detail_page.dart';

class CapturedPokemonPage extends StatefulWidget {
  final int userId;

  const CapturedPokemonPage({super.key, required this.userId});

  @override
  _CapturedPokemonPageState createState() => _CapturedPokemonPageState();
}

class _CapturedPokemonPageState extends State<CapturedPokemonPage> {
  final ApiService _apiService = ApiService();
  List<Pokemon> _capturedPokemon = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCapturedPokemon();
  }

  Future<void> _fetchCapturedPokemon() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/captured/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final capturedIds = List<String>.from(
            data['captured_pokemon'].map((id) => id.toString()));
        List<Pokemon> pokemonList = [];

        for (String id in capturedIds) {
          final pokemon = await _apiService.fetchPokemonDetailsById(id);
          pokemonList.add(pokemon);
        }

        setState(() {
          _capturedPokemon = pokemonList;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load captured Pokémon');
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
          'Captured Pokémon',
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
                : _capturedPokemon.isEmpty
                    ? const Center(
                        child: Text(
                          'No Pokémon captured yet',
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
                        itemCount: _capturedPokemon.length,
                        itemBuilder: (context, index) {
                          final pokemon = _capturedPokemon[index];
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
