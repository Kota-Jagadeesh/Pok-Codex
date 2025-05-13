// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';
import 'pokemon_detail_page.dart';

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

  // Fetch Pokémon list
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

  // Filter Pokémon based on search input
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
        title: const Text(
          'Pokedex',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 40,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Heading Pokémon
            const Text(
              'Featured Pokémon',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 255, 255),
              ),
            ),
            const SizedBox(height: 0),
            _isLoading
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
                    : FutureBuilder<Pokemon>(
                        future:
                            _apiService.fetchPokemonDetails(_allPokemon[0].url),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Failed to load featured Pokémon',
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
                                    builder: (context) => PokemonDetailPage(
                                      pokemon: snapshot.data!,
                                    ),
                                  ),
                                );
                              },
                              child: _buildFeaturedPokemonCard(
                                snapshot.data!.name,
                                snapshot.data!.imageUrl,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
            const SizedBox(height: 10),
            // Pokémon Collection Header
            const Text(
              'Your Pokémon Collection',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 247, 0, 255),
              ),
            ),
            const SizedBox(height: 0),
            // Horizontally Scrollable Pokémon Cards
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
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filteredPokemon.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder<Pokemon>(
                                  future: _apiService.fetchPokemonDetails(
                                      _filteredPokemon[index].url),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 150,
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const SizedBox(
                                        width: 150,
                                        child: Center(
                                          child: Text(
                                            'Error',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'Roboto',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: GestureDetector(
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
                                          child: _buildPokemonCard(
                                            snapshot.data!.name,
                                            snapshot.data!.imageUrl,
                                          ),
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

  // Featured Pokémon Card (Larger for Heading)
  Widget _buildFeaturedPokemonCard(String name, String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 71, 255, 34),
            ),
          ),
        ],
      ),
    );
  }

  // Regular Pokémon Card (Scrollable)
  Widget _buildPokemonCard(String name, String imageUrl) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
