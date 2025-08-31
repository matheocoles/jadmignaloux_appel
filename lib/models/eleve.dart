class Eleve {
  final int id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String nomParent;
  final String prenomParent;
  final String emailParent;
  final String telParent;
  final bool adhesionAJour;
  final List<int> coursIds;
  final List<Map<String, dynamic>>? cours; // cours complets

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.nomParent,
    required this.prenomParent,
    required this.emailParent,
    required this.telParent,
    required this.adhesionAJour,
    this.coursIds = const [],
    this.cours,
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      nomParent: json['parent_nom'] as String,
      prenomParent: json['parent_prenom'] as String,
      emailParent: json['parent_email'] as String,
      telParent: json['parent_telephone'] as String,
      adhesionAJour: json['adhesion_valide'] as bool,
      coursIds: (json['cours_ids'] as List?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList() ??
          [],
      cours: (json['cours'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nom": nom,
    "prenom": prenom,
    "date_naissance": dateNaissance.toIso8601String(),
    "parent_nom": nomParent,
    "parent_prenom": prenomParent,
    "parent_email": emailParent,
    "parent_telephone": telParent,
    "adhesion_valide": adhesionAJour,
    "cours_ids": coursIds,
  };
}
