import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/eleve.dart';

class EleveEditPage extends StatefulWidget {
  final Eleve eleve;
  const EleveEditPage({super.key, required this.eleve});

  @override
  State<EleveEditPage> createState() => _EleveEditPageState();
}

class _EleveEditPageState extends State<EleveEditPage> {
  final db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController dateNaissanceController;
  late TextEditingController nomParentController;
  late TextEditingController prenomParentController;
  late TextEditingController emailParentController;
  late TextEditingController telParentController;
  late TextEditingController anneePremiereDanseController;
  late bool adhesionAJour;

  List<Map<String, dynamic>> coursDisponibles = [];
  List<int> coursSelectionnes = [];

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.eleve.nom);
    prenomController = TextEditingController(text: widget.eleve.prenom);
    dateNaissanceController = TextEditingController(
        text: widget.eleve.dateNaissance.toIso8601String().split('T')[0]
    );
    nomParentController = TextEditingController(text: widget.eleve.nomParent);
    prenomParentController = TextEditingController(text: widget.eleve.prenomParent);
    emailParentController = TextEditingController(text: widget.eleve.emailParent);
    telParentController = TextEditingController(text: widget.eleve.telParent);
    anneePremiereDanseController = TextEditingController(text: widget.eleve.anneePremiereDanse);
    adhesionAJour = widget.eleve.adhesionAJour;

    coursSelectionnes = List<int>.from(widget.eleve.coursIds ?? []);
    loadCours();
  }

  Future<void> loadCours() async {
    final data = await db.getCours();
    setState(() {
      coursDisponibles = data;
    });
  }

  Future<void> saveEleve() async {
    if (!_formKey.currentState!.validate()) return;
    if (coursSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un cours")),
      );
      return;
    }

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
      id: widget.eleve.id,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      dateNaissance: dateNaissance,
      nomParent: nomParentController.text.trim(),
      prenomParent: prenomParentController.text.trim(),
      emailParent: emailParentController.text.trim(),
      telParent: telParentController.text.trim(),
      anneePremiereDanse: anneePremiereDanseController.text.trim(),
      adhesionAJour: adhesionAJour,
      coursIds: coursSelectionnes,
    );

    await db.updateEleve(updatedEleve);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier l'élève")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nomController, decoration: const InputDecoration(labelText: "Nom"), validator: (v) => v!.isEmpty ? "Champ requis" : null),
              TextFormField(controller: prenomController, decoration: const InputDecoration(labelText: "Prénom"), validator: (v) => v!.isEmpty ? "Champ requis" : null),
              TextFormField(controller: dateNaissanceController, decoration: const InputDecoration(labelText: "Date de naissance")),
              TextFormField(controller: nomParentController, decoration: const InputDecoration(labelText: "Nom parent")),
              TextFormField(controller: prenomParentController, decoration: const InputDecoration(labelText: "Prénom parent")),
              TextFormField(controller: emailParentController, decoration: const InputDecoration(labelText: "Email parent")),
              TextFormField(controller: telParentController, decoration: const InputDecoration(labelText: "Téléphone parent")),
              TextFormField(controller: anneePremiereDanseController, decoration: const InputDecoration(labelText: "1ère année danse")),
              SwitchListTile(title: const Text("Adhésion à jour"), value: adhesionAJour, onChanged: (v) => setState(() => adhesionAJour = v)),
              const SizedBox(height: 16),
              const Text("Cours", style: TextStyle(fontWeight: FontWeight.bold)),
              ...coursDisponibles.map((cours) {
                final id = cours['id'] as int;
                return CheckboxListTile(
                  title: Text(cours['nom']),
                  value: coursSelectionnes.contains(id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        coursSelectionnes.add(id);
                      } else {
                        coursSelectionnes.remove(id);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: saveEleve, child: const Text("Modifier l'élève")),
            ],
          ),
        ),
      ),
    );
  }
}
