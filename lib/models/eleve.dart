class Eleve {
  final int id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String nomParent;
  final String prenomParent;
  final String emailParent;
  final String telParent;
  final String? anneePremiereDanse;
  final bool adhesionAJour;
  final List<int> coursIds; // Liste des IDs de cours

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.nomParent,
    required this.prenomParent,
    required this.emailParent,
    required this.telParent,
    required this.anneePremiereDanse,
    required this.adhesionAJour,
    this.coursIds = const [],
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: DateTime.parse(json['date_naissance']),
      nomParent: json['parent_nom'],
      prenomParent: json['parent_prenom'],
      emailParent: json['parent_email'],
      telParent: json['parent_telephone'],
      anneePremiereDanse: json['premiere_annee'],
      adhesionAJour: json['adhesion_valide'],
      coursIds: List<int>.from(json['cours_ids'] ?? []),
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
    "premiere_annee": anneePremiereDanse,
    "adhesion_valide": adhesionAJour,
    "cours_ids": coursIds,
  };
}
