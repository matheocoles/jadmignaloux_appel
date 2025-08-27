import 'package:flutter/material.dart';
import '../../../models/eleve.dart';
import '../../../services/database_service.dart';
import '../../eleve_page/eleve_add_page.dart';
import '../../eleve_page/eleve_edit_page.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  final db = DatabaseService();
  List<Eleve> eleves = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEleves();
  }

  Future<void> loadEleves() async {
    final data = await db.getAllEleves();
    setState(() {
      eleves = data.map((e) => Eleve.fromJson(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administration")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: eleves.length,
        itemBuilder: (context, index) {
          final e = eleves[index];
          final adhesionOk = e.adhesionAJour;
          return Card(
            color: adhesionOk ? Colors.green[50] : Colors.red[50],
            child: ListTile(
              title: Text("${e.prenom} ${e.nom}"),
              subtitle: Text(
                  "Parents: ${e.prenomParent} ${e.nomParent}\nEmail: ${e.emailParent}\nTéléphone: ${e.telParent}\nDate de naissance: ${e.dateNaissance}\n1ère année danse: ${e.anneePremiereDanse}"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EleveEditPage(eleve: e),
                    ),
                  );
                  loadEleves();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EleveAddPage(), // coursId optionnel
            ),
          );
          loadEleves();
        },
      ),
    );
  }
}
