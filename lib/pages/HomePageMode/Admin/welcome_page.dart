import 'package:flutter/material.dart';
import 'home_page.dart'; // ← ta page admin principale

class WelcomeAdminPage extends StatefulWidget {
  final String prenom;

  const WelcomeAdminPage({super.key, required this.prenom});

  @override
  State<WelcomeAdminPage> createState() => _WelcomeAdminPageState();
}

class _WelcomeAdminPageState extends State<WelcomeAdminPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePageAdmin(), // tu peux aussi passer le prénom ici
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "Bienvenue ${widget.prenom} 👋",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Chargement de votre tableau de bord...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
