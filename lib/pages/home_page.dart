import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'eleve_page/liste_eleve_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DatabaseService();
  List<Map<String, dynamic>> cours = [];

  @override
  void initState() {
    super.initState();
    loadCours();
  }

  Future<void> loadCours() async {
    final data = await db.getCours();
    setState(() {
      cours = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("École de danse")),
      body: cours.isEmpty
          ? const Center(child: Text("Aucun cours disponible"))
          : ListView.builder(
        itemCount: cours.length,
        itemBuilder: (context, index) {
          final c = cours[index];
          return ListTile(
            title: Text(c['nom']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListeElevesPage(
                    coursId: c['id'],
                    coursNom: c['nom'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
