import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon.dart';

class PokemonDetailPage extends StatelessWidget {
  final Pokemon pokemon;
  final int userId;

  const PokemonDetailPage({
    super.key,
    required this.pokemon,
    required this.userId,
  });

  Future<void> _capturePokemon(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/capture'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'pokemon_id': pokemon.id,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor:
                response.statusCode == 201 ? Colors.green : Colors.orange,
          ),
        );
      } else {
        throw Exception('Failed to capture Pokémon');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/users'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['users']);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<void> _tradePokemon(BuildContext context) async {
    try {
      // fetches the list of users
      final users = await _fetchUsers();

      // filters out the current user
      final otherUsers = users.where((user) => user['id'] != userId).toList();

      if (otherUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No other users available to trade with'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      //shows a dialog to select a user to trade with
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Select User to Trade With'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: otherUsers.length,
                itemBuilder: (context, index) {
                  final user = otherUsers[index];
                  return ListTile(
                    title: Text(user['username']),
                    onTap: () async {
                      Navigator.of(dialogContext).pop(); // cloae the dialog
                      //initiate the trade
                      try {
                        final response = await http.post(
                          Uri.parse('http://localhost:5000/trade'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'sender_user_id': userId,
                            'receiver_user_id': user['id'],
                            'pokemon_id': pokemon.id,
                          }),
                        );

                        if (response.statusCode == 201 ||
                            response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(data['message']),
                              backgroundColor: response.statusCode == 201
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                          );
                        } else {
                          throw Exception('Failed to trade Pokémon');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.network(
                  pokemon.imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                pokemon.name,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 43, 244),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Type: ${pokemon.types.isNotEmpty ? pokemon.types.join(', ') : 'Unknown'}\n'
                'Height: ${pokemon.height} m\n'
                'Weight: ${pokemon.weight} kg\n'
                'HP: ${pokemon.stats['hp'] ?? 'Unknown'}\n'
                'Attack: ${pokemon.stats['attack'] ?? 'Unknown'}\n'
                'Defense: ${pokemon.stats['defense'] ?? 'Unknown'}\n'
                'Special Attack: ${pokemon.stats['special-attack'] ?? 'Unknown'}\n'
                'Special Defense: ${pokemon.stats['special-defense'] ?? 'Unknown'}\n'
                'Speed: ${pokemon.stats['speed'] ?? 'Unknown'}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _capturePokemon(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Capture',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _tradePokemon(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Trade',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
