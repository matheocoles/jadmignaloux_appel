import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'HomePageMode/Admin/home_page.dart';
import 'HomePageMode/Professeur/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final prenomController = TextEditingController();
  String error = "";

  Future<void> login() async {
    final prenom = prenomController.text.trim();

    if (prenom.isEmpty) {
      setState(() => error = "Veuillez saisir un prénom");
      return;
    }

    try {
      // 🔎 Recherche dans Supabase
      final response = await supabase
          .from('users')
          .select('id, role, prenom, cours_id')
          .ilike('prenom', prenom);

      if (response.isEmpty) {
        setState(() => error = "Utilisateur inconnu");
        return;
      }

      final user = response[0];
      final role = user['role'] as String;

      // 🎯 Redirection selon rôle
      if (role == 'professeur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageProf(
              prenom: user['prenom'],
              coursId: user['cours_id'],
            ),
          ),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageAdmin()),
        );
      } else {
        setState(() => error = "Rôle inconnu dans Supabase");
      }
    } catch (e) {
      setState(() => error = "Erreur de connexion à Supabase : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFA8A),
              Color(0xFFECC440),
              Color(0xFFDDAC17),
              Color(0xFFFFF995),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/logo.png", width: 100),
                  const SizedBox(height: 20),
                  TextField(
                    controller: prenomController,
                    decoration: const InputDecoration(labelText: "Prénom"),
                  ),
                  const SizedBox(height: 16),
                  if (error.isNotEmpty) ...[
                    Text(error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDDAC17),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: login,
                    child: const Text("Se connecter"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
