import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/eleve.dart';
import '../../../services/database_service.dart';
import '../../eleve_page/eleve_add_page.dart';
import '../../eleve_page/eleve_edit_page.dart';
import 'package:intl/intl.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  final db = DatabaseService();
  final client = Supabase.instance.client;
  RealtimeChannel? channel;
  List<Eleve> eleves = [];
  Map<int, List<Map<String, dynamic>>> eleveCoursMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    setupRealtime();
  }

  void setupRealtime() {
    channel = client.channel('public:eleves');

    // Utilisez onPostgresChanges pour écouter tous les événements (insert, update, delete)
    channel!.onPostgresChanges(
      schema: 'public',
      table: 'eleves',
      event: PostgresChangeEvent.all,
      callback: (payload) {
        // Rechargez les données dès qu'il y a un changement
        loadData();
      },
    ).subscribe();
  }

  @override
  void dispose() {
    if (channel != null) {
      client.removeChannel(channel!);
    }
    super.dispose();
  }

  Map<int, List<Eleve>> elevesParCours = {};
  List<Map<String, dynamic>> coursDisponibles = [];

  Future<void> loadData() async {
    setState(() => loading = true);

    final elevesData = await db.getAllEleves();
    final eleveCoursData = await db.getEleveCours();
    final coursData = await db.getCours();

    // Construire map eleveId -> eleve
    Map<int, Eleve> elevesMap = {
      for (var e in elevesData) Eleve.fromJson(e).id : Eleve.fromJson(e)
    };

    // Initialiser Map pour eleves par cours
    Map<int, List<Eleve>> map = {};

    // Pour chaque relation eleve-cours
    for (var ec in eleveCoursData) {
      int eleveId = ec['eleve_id'];
      int coursId = ec['cours_id'];
      if (elevesMap.containsKey(eleveId)) {
        map.putIfAbsent(coursId, () => []);
        map[coursId]!.add(elevesMap[eleveId]!);
      }
    }

    setState(() {
      elevesParCours = map;
      coursDisponibles = coursData;
      loading = false;
    });
  }


  String formatDate(DateTime? date) {
    if (date == null) return "Date inconnue";
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "Date invalide";
    }
  }

  String getNomsCours(int eleveId) {
    final cours = eleveCoursMap[eleveId];
    if (cours == null || cours.isEmpty) return "Aucun cours";
    return cours.map((c) => c['nom']).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administration")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : coursDisponibles.isEmpty
          ? const Center(child: Text("Aucun cours trouvé"))
          : ListView(
        children: coursDisponibles.map((cours) {
          final idCours = cours['id'] as int;
          final nomCours = cours['nom'] as String;
          final listeEleves = elevesParCours[idCours] ?? [];

          return ExpansionTile(
            title: Text(nomCours),
            children: listeEleves.isEmpty
                ? [const ListTile(title: Text("Aucun élève"))]
                : listeEleves.map((e) {
              return ListTile(
                title: Text("${e.prenom} ${e.nom}"),
                subtitle: Text(
                  "1ère année danse : ${e.anneePremiereDanse}\nAdhésion : ${e.adhesionAJour ? 'OK' : 'Non'}",
                ),
                onTap: () async {
                  // Ouvrir la page éditeur pour cet élève
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EleveEditPage(eleve: e),
                    ),
                  );
                  // Recharger les données afin que les changements soient visibles
                  await loadData();
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Ajouter un élève",
        child: const Icon(Icons.person_add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EleveAddPage()),
          );
          await loadData();
        },
      ),
    );
  }

}
