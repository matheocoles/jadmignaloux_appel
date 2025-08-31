import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
  final client = Supabase.instance.client;
  RealtimeChannel? channel;

  bool loading = true;
  List<Map<String, dynamic>> coursDisponibles = [];
  Map<int, List<Eleve>> elevesParCours = {};

  @override
  void initState() {
    super.initState();
    loadData();
    setupRealtime();
  }

  void setupRealtime() {
    channel = client.channel('public:eleves');

    channel!
        .onPostgresChanges(
      schema: 'public',
      table: 'eleves',
      event: PostgresChangeEvent.all,
      callback: (_) => loadData(),
    )
        .subscribe();
  }

  @override
  void dispose() {
    if (channel != null) {
      client.removeChannel(channel!);
    }
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    final elevesRaw = await db.getAllEleves();
    final eleveCoursRaw = await db.getEleveCours();
    final coursRaw = await db.getCours();

    final Map<int, Eleve> elevesMap = {
      for (var e in elevesRaw) Eleve.fromJson(e).id: Eleve.fromJson(e)
    };

    final Map<int, List<Eleve>> map = {};

    for (var ec in eleveCoursRaw) {
      final int eleveId = ec['eleve_id'];
      final int coursId = ec['cours_id'];
      if (elevesMap.containsKey(eleveId)) {
        map.putIfAbsent(coursId, () => []);
        map[coursId]!.add(elevesMap[eleveId]!);
      }
    }

    setState(() {
      elevesParCours = map;
      coursDisponibles = coursRaw;
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
          final int idCours = cours['id'] as int;
          final String nomCours = cours['nom'] as String;
          final List<Eleve> listeEleves = elevesParCours[idCours] ?? [];

          return ExpansionTile(
            title: Text(
              "$nomCours (${listeEleves.length} élève${listeEleves.length > 1 ? 's' : ''})",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: listeEleves.isEmpty
                ? [const ListTile(title: Text("Aucun élève"))]
                : listeEleves.map((e) {
              return Container(
                color: e.adhesionAJour
                    ? const Color(0xFFECC440)
                    : const Color(0xFFDDAC17),
                child: ListTile(
                  title: Text("${e.prenom} ${e.nom}"),
                  subtitle: Text(
                        "Adhésion : ${e.adhesionAJour ? 'OK' : 'Non'}",
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EleveEditPage(eleveId: e.id),
                      ),
                    );
                    await loadData();
                  },
                ),
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
