import 'package:flutter/material.dart';
import '../../models/eleve.dart';
import '../../services/database_service.dart';
import '../appel_page.dart';
import 'eleve_page.dart';
import 'eleve_add_page.dart';

class ListeElevesPage extends StatefulWidget {
  final int coursId;
  final String coursNom;

  const ListeElevesPage({super.key, required this.coursId, required this.coursNom});

  @override
  State<ListeElevesPage> createState() => _ListeElevesPageState();
}

class _ListeElevesPageState extends State<ListeElevesPage> {
  final db = DatabaseService();
  List<Eleve> eleves = [];

  @override
  void initState() {
    super.initState();
    loadEleves();
  }

  Future<void> loadEleves() async {
    final data = await db.getElevesByCours(widget.coursId);
    setState(() {
      eleves = data.map((e) => Eleve.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Élèves - ${widget.coursNom}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
            tooltip: "Faire l'appel",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppelPage(
                    coursId: widget.coursId,
                    coursNom: widget.coursNom,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: eleves.isEmpty
          ? const Center(child: Text("Aucun élève pour ce cours"))
          : ListView.builder(
        itemCount: eleves.length,
        itemBuilder: (context, index) {
          final eleve = eleves[index];
          return ListTile(
            title: Text("${eleve.prenom} ${eleve.nom}"),
            subtitle: Text("Né le ${eleve.dateNaissance}"), // String directement
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ElevePage(eleve: eleve),
                ),
              );
              loadEleves(); // recharger après modification éventuelle
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        tooltip: "Ajouter un élève",
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EleveAddPage(coursId: widget.coursId),
            ),
          );
          loadEleves(); // recharger la liste après ajout
        },
      ),
    );
  }
}
