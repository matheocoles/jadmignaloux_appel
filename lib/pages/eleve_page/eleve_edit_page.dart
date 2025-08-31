import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/eleve.dart';

class EleveEditPage extends StatefulWidget {
  final int eleveId;
  const EleveEditPage({super.key, required this.eleveId});

  @override
  State<EleveEditPage> createState() => _EleveEditPageState();
}

class _EleveEditPageState extends State<EleveEditPage> {
  final db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late Eleve eleve;
  bool isLoading = true;

  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController dateNaissanceController;
  late TextEditingController nomParentController;
  late TextEditingController prenomParentController;
  late TextEditingController emailParentController;
  late TextEditingController telParentController;
  late bool adhesionAJour;

  List<Map<String, dynamic>> coursDisponibles = [];
  List<int> coursSelectionnes = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final eleveComplet = await db.getEleveComplet(widget.eleveId);
    final allCours = await db.getCours();
    final coursDeLEleve = await db.getCoursByEleve(widget.eleveId);

    final idsSelectionnes = coursDeLEleve
        .map((c) => c['cours']['id'] as int)
        .toSet()
        .toList(); // évite les doublons

    setState(() {
      eleve = eleveComplet;
      coursDisponibles = allCours;
      coursSelectionnes = idsSelectionnes;
      nomController = TextEditingController(text: eleve.nom);
      prenomController = TextEditingController(text: eleve.prenom);
      dateNaissanceController = TextEditingController(
          text: eleve.dateNaissance.toIso8601String().split('T')[0]);
      nomParentController = TextEditingController(text: eleve.nomParent);
      prenomParentController = TextEditingController(text: eleve.prenomParent);
      emailParentController = TextEditingController(text: eleve.emailParent);
      telParentController = TextEditingController(text: eleve.telParent);
      adhesionAJour = eleve.adhesionAJour;
      isLoading = false;
    });
  }

  Future<void> saveEleve() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? dateNaissance;
    try {
      dateNaissance = DateTime.parse(dateNaissanceController.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date de naissance invalide")),
      );
      return;
    }

    final updatedEleve = Eleve(
      id: eleve.id,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      dateNaissance: dateNaissance,
      nomParent: nomParentController.text.trim(),
      prenomParent: prenomParentController.text.trim(),
      emailParent: emailParentController.text.trim(),
      telParent: telParentController.text.trim(),
      adhesionAJour: adhesionAJour,
      coursIds: coursSelectionnes,
    );


    await db.updateEleve(updatedEleve);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier l'élève")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (v) =>
                v == null || v.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: "Prénom"),
                validator: (v) =>
                v == null || v.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                controller: dateNaissanceController,
                decoration: const InputDecoration(
                    labelText: "Date de naissance (yyyy-mm-dd)"),
              ),
              TextFormField(
                controller: nomParentController,
                decoration: const InputDecoration(labelText: "Nom parent"),
              ),
              TextFormField(
                controller: prenomParentController,
                decoration: const InputDecoration(labelText: "Prénom parent"),
              ),
              TextFormField(
                controller: emailParentController,
                decoration: const InputDecoration(labelText: "Email parent"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: telParentController,
                decoration: const InputDecoration(labelText: "Téléphone parent"),
                keyboardType: TextInputType.phone,
              ),
              SwitchListTile(
                title: const Text("Adhésion à jour"),
                value: adhesionAJour,
                onChanged: (v) => setState(() => adhesionAJour = v),
              ),
              const SizedBox(height: 16),
              const Text("Cours", style: TextStyle(fontWeight: FontWeight.bold)),
              ...coursDisponibles.map((cours) {
                final int id = cours['id'] as int;
                return CheckboxListTile(
                  title: Text(cours['nom'] as String),
                  value: coursSelectionnes.contains(id),
                  onChanged: (bool? v) {
                    setState(() {
                      if (v == true) {
                        if (!coursSelectionnes.contains(id)) coursSelectionnes.add(id);
                      } else {
                        coursSelectionnes.remove(id);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveEleve,
                child: const Text("Modifier l'élève"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
