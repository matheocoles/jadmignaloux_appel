import 'package:flutter/material.dart';
import 'Admin/home_page.dart';
import 'Professeur/home_page.dart';

class HomeModePage extends StatelessWidget {
  const HomeModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("École de danse")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // TODO: Remplacer 1 par l'id du cours du professeur
                const monCoursId = 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const HomePageProf(prenom: '',)),
                );
              },
              child: const Text("Professeur"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePageAdmin()),
                );
              },
              child: const Text("Admin"),
            ),
          ],
        ),
      ),
    );
  }
}
