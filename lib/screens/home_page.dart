import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';
import 'pokemon_detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<PokemonListItem> _allPokemon = [];
  List<PokemonListItem> _filteredPokemon = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
    _searchController.addListener(_filterPokemon);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPokemon() async {
    try {
      final pokemonList = await _apiService.fetchPokemonList();
      setState(() {
        _allPokemon = pokemonList;
        _filteredPokemon = pokemonList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPokemon() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPokemon = _allPokemon
          .where((pokemon) => pokemon.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.cyan,
            size: 28,
          ),
          tooltip: 'Back to Login',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        title: const Text(
          'Pok-Codéx',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 217, 0),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                filled: true,
                fillColor: const Color.fromARGB(255, 158, 158, 158),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Pokémon Collection Header
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Pokémons: .... ',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 247, 0, 255),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Pokémon Grid
            Expanded(
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
                      : _filteredPokemon.isEmpty
                          ? const Center(
                              child: Text(
                                'No Pokémon found',
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
                              itemCount: _filteredPokemon.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder<Pokemon>(
                                  future: _apiService.fetchPokemonDetails(
                                      _filteredPokemon[index].url),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                          'Error',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'Roboto',
                                            fontSize: 18,
                                          ),
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PokemonDetailPage(
                                                pokemon: snapshot.data!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              snapshot.data!.imageUrl,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.error,
                                                color: Color.fromARGB(
                                                    255, 255, 17, 0),
                                                size: 50,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              snapshot.data!.name,
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 230, 255, 88),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
