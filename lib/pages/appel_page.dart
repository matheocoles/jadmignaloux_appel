import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AppelPage extends StatefulWidget {
  final int coursId;
  final String coursNom;

  const AppelPage({super.key, required this.coursId, required this.coursNom});

  @override
  State<AppelPage> createState() => _AppelPageState();
}

class _AppelPageState extends State<AppelPage> {
  final db = DatabaseService();
  List<Map<String, dynamic>> eleves = [];
  Map<int, String> statutEleves = {}; // clé : id élève, valeur : "Présent" / "Absent" / "Retard"
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEleves();
  }

  Future<void> loadEleves() async {
    final data = await db.getElevesByCours(widget.coursId);
    setState(() {
      eleves = data;
      for (var e in eleves) {
        statutEleves[e['id']] = "Présent"; // valeur par défaut
      }
      loading = false;
    });
  }

  Future<void> savePresence() async {
    for (var e in eleves) {
      final statut = statutEleves[e['id']]!;
      await db.savePresence(e['id'], statut, DateTime.now());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Présences sauvegardées")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Appel : ${widget.coursNom}")),
      body: ListView.builder(
        itemCount: eleves.length,
        itemBuilder: (context, index) {
          final e = eleves[index];
          return Card(
            child: ListTile(
              title: Text("${e['prenom']} ${e['nom']}"),
              subtitle: Text("Date de naissance : ${e['date_naissance']}"),
              trailing: DropdownButton<String>(
                value: statutEleves[e['id']],
                items: const [
                  DropdownMenuItem(value: "Présent", child: Text("Présent")),
                  DropdownMenuItem(value: "Absent", child: Text("Absent")),
                  DropdownMenuItem(value: "Retard", child: Text("Retard")),
                ],
                onChanged: (value) {
                  setState(() {
                    statutEleves[e['id']] = value!;
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: savePresence,
        child: const Icon(Icons.save),
      ),
    );
  }
}
