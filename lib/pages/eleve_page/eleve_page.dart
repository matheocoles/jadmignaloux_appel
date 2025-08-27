import 'package:flutter/material.dart';
import '../../models/eleve.dart';
import 'eleve_edit_page.dart';

class ElevePage extends StatelessWidget {
  final Eleve eleve;

  const ElevePage({super.key, required this.eleve});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${eleve.prenom} ${eleve.nom}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("👤 Informations Élève", style: Theme.of(context).textTheme.titleLarge),
            Text("Nom : ${eleve.nom}"),
            Text("Prénom : ${eleve.prenom}"),
            Text("Date de naissance : ${eleve.dateNaissance}"), // déjà une String

            const SizedBox(height: 16),

            Text("👪 Parent", style: Theme.of(context).textTheme.titleLarge),
            Text("Nom : ${eleve.nomParent}"),
            Text("Prénom : ${eleve.prenomParent}"),
            Text("Email : ${eleve.emailParent}"),
            Text("Téléphone : ${eleve.telParent}"),

            const SizedBox(height: 16),

            Text("📅 Historique", style: Theme.of(context).textTheme.titleLarge),
            Text("Première année : ${eleve.anneePremiereDanse}"),
            Row(
              children: [
                const Text("Adhésion à jour : "),
                Icon(
                  eleve.adhesionAJour ? Icons.check_circle : Icons.cancel,
                  color: eleve.adhesionAJour ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EleveEditPage(eleve: eleve),
            ),
          );
        },
      ),
    );
  }
}
