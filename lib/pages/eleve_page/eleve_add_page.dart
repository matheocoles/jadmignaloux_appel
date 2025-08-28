import 'dart:io';

import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/eleve.dart';

class EleveAddPage extends StatefulWidget {
  final List<int>? coursIds;

  const EleveAddPage({super.key, this.coursIds});

  @override
  State<EleveAddPage> createState() => _EleveAddPageState();
}

class _EleveAddPageState extends State<EleveAddPage> {
  final db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final dateNaissanceController = TextEditingController();
  final nomParentController = TextEditingController();
  final prenomParentController = TextEditingController();
  final emailParentController = TextEditingController();
  final telParentController = TextEditingController();
  final anneePremiereDanseController = TextEditingController();
  bool adhesionAJour = true;

  List<Map<String, dynamic>> coursDisponibles = [];
  List<int> coursSelectionnes = [];

  @override
  void initState() {
    super.initState();
    if (widget.coursIds != null) {
      coursSelectionnes = List.from(widget.coursIds!);
    }
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

    // Convertir la date en DateTime
    DateTime? dateNaissance;
    try {
      dateNaissance = DateTime.parse(dateNaissanceController.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date de naissance invalide")),
      );
      return;
    }

    final eleve = Eleve(
      id: 0,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      dateNaissance: dateNaissance, // DateTime
      nomParent: nomParentController.text.trim(),
      prenomParent: prenomParentController.text.trim(),
      emailParent: emailParentController.text.trim(),
      telParent: telParentController.text.trim(),
      anneePremiereDanse: anneePremiereDanseController.text.trim(),
      adhesionAJour: adhesionAJour,
      coursIds: coursSelectionnes, // List<int>
    );

    await db.addEleve(eleve); // supprime le paramètre coursIds

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un élève")),
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
              ElevatedButton(onPressed: saveEleve, child: const Text("Ajouter l'élève")),
            ],
          ),
        ),
      ),
    );
  }
}
