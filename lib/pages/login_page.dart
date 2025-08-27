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
      // Récupère l'utilisateur par prénom
      final data = await supabase
          .from('users')
          .select('id, role')
          .ilike('prenom', prenom);

      if (data.isEmpty) {
        setState(() => error = "Utilisateur inconnu");
        return;
      }

      final user = data[0];
      final role = user['role'];

      if (role == 'professeur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageProf(prenom: prenom),
          ),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageAdmin()),
        );
      } else {
        setState(() => error = "Rôle inconnu");
      }
    } catch (e) {
      setState(() => error = "Erreur lors de la connexion : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(labelText: "Prénom"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Se connecter"),
            ),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(error, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
