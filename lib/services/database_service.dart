import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/eleve.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // ------------------- ÉLÈVES -------------------

  Future<List<Map<String, dynamic>>> getAllEleves() async {
    final data = await supabase.from('eleves').select();
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getElevesByCours(int coursId) async {
    final response = await supabase
        .from('eleves_cours')
        .select('id, eleves(*)')
        .eq('cours_id', coursId);

    if (response == null || response.isEmpty) return [];

    return response
        .where((e) => e['eleves'] != null)
        .map((e) => {
      ...Map<String, dynamic>.from(e['eleves']),
      'eleve_cours_id': e['id'],
    })
        .toList();
  }

  Future<void> addEleve(Eleve eleve) async {
    try {
      final res = await supabase.from("eleves").insert({
        "nom": eleve.nom,
        "prenom": eleve.prenom,
        "date_naissance": eleve.dateNaissance?.toIso8601String(),
        "parent_nom": eleve.nomParent,
        "parent_prenom": eleve.prenomParent,
        "parent_email": eleve.emailParent,
        "parent_telephone": eleve.telParent,
        "adhesion_valide": eleve.adhesionAJour,
      }).select();

      if (res == null || res.isEmpty || res[0]['id'] == null) {
        throw Exception("L'insertion de l'élève a échoué.");
      }

      final int eleveId = res[0]['id'];

      if (eleve.coursIds.isNotEmpty) {
        final relations = eleve.coursIds.map((coursId) => {
          'eleve_id': eleveId,
          'cours_id': coursId,
        }).toList();

        await supabase.from('eleves_cours').insert(relations);
      }
    } catch (e) {
      throw Exception("Erreur lors de l'ajout de l'élève : $e");
    }
  }

  Future<void> updateEleve(Eleve eleve) async {
    try {
      await supabase.from('eleves').update({
        "nom": eleve.nom,
        "prenom": eleve.prenom,
        "date_naissance": eleve.dateNaissance.toIso8601String(),
        "parent_nom": eleve.nomParent,
        "parent_prenom": eleve.prenomParent,
        "parent_email": eleve.emailParent,
        "parent_telephone": eleve.telParent,
        "adhesion_valide": eleve.adhesionAJour,
      }).eq("id", eleve.id);

      await supabase.from('eleves_cours').delete().eq('eleve_id', eleve.id);

      if (eleve.coursIds.isNotEmpty) {
        final relations = eleve.coursIds.map((coursId) => {
          'eleve_id': eleve.id,
          'cours_id': coursId,
        }).toList();

        await supabase.from('eleves_cours').insert(relations);
      }
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de l'élève : $e");
    }
  }

  Future<Eleve> getEleveComplet(int eleveId) async {
    final eleveData = await supabase
        .from('eleves')
        .select()
        .eq('id', eleveId)
        .single();

    final coursData = await getCoursByEleve(eleveId);

    return Eleve.fromJson({
      ...Map<String, dynamic>.from(eleveData),
      'cours': coursData.map((e) => e['cours']).toList(),
    });
  }

  Future<List<Map<String, dynamic>>> getCoursByEleve(int eleveId) async {
    final data = await supabase
        .from('eleves_cours')
        .select('cours(*)')
        .eq('eleve_id', eleveId);

    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getEleveCours() async {
    final data = await supabase.from('eleves_cours').select();
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ------------------- PRÉSENCES -------------------
  Future<List<Map<String, dynamic>>> getPresences(int coursId) async {
    final elevesCours = await supabase
        .from('eleves_cours')
        .select('eleve_id')
        .eq('cours_id', coursId);

    final eleveIds = elevesCours
        .map((e) => e['eleve_id'])
        .whereType<int>()
        .toList();

    if (eleveIds.isEmpty) return [];

    final response = await supabase
        .from('presences')
        .select('*')
        .inFilter('eleve_id', eleveIds);

    return response.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, int>> getStatsForCours(int coursId) async {
    final response = await supabase
        .from('presences')
        .select('statut')
        .eq('cours_id', coursId);

    final data = response.map((e) => Map<String, dynamic>.from(e)).toList();

    int present = 0;
    int absent = 0;

    for (var entry in data) {
      if (entry['statut'] == 'Présent') present++;
      if (entry['statut'] == 'Absent') absent++;
    }

    return {
      'nombre_present': present,
      'nombre_absent': absent,
    };
  }

  // ------------------- COURS -------------------

  Future<List<Map<String, dynamic>>> getCours() async {
    final response = await supabase.from("cours").select();
    return response.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getCoursById(int coursId) async {
    final res = await supabase.from('cours').select().eq('id', coursId);
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getCoursByProfesseurAndJour(String prenom, String jour) async {
    final response = await supabase
        .from('cours')
        .select()
        .eq('professeur', prenom)
        .eq('jour', jour);

    return response.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
