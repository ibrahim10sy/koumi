class Abonnement {
  String? idAbonnement;
  String? typeAbonnement;
  String? codeAbonnement;
  List<String>? options;
  DateTime? dateAjout;
  DateTime? dateFin;
  int? montant;
  bool? statutAbonnement;

  Abonnement({
    this.idAbonnement,
    this.typeAbonnement,
    this.codeAbonnement,
    this.options,
    this.dateAjout,
    this.dateFin,
    this.montant,
    this.statutAbonnement,
  });

  factory Abonnement.fromJson(Map<String, dynamic> json) {
    return Abonnement(
      idAbonnement: json['idAbonnement'] as String?,
      typeAbonnement: json['typeAbonnement'] as String?,
      codeAbonnement: json['codeAbonnement'] as String?,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dateAjout: json['dateAjout'] != null ? DateTime.parse(json['dateAjout']) : null,
      dateFin: json['dateFin'] != null ? DateTime.parse(json['dateFin']) : null,
      montant: json['montant'] != null ? (json['montant']) : null,
      statutAbonnement: json['statutAbonnement'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAbonnement': idAbonnement,
      'typeAbonnement': typeAbonnement,
      'codeAbonnement': codeAbonnement,
      'options': options,
      'dateAjout': dateAjout?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'montant': montant,
      'statutAbonnement': statutAbonnement,
    };
  }

   factory Abonnement.fromMap(Map<String, dynamic> map) {
    return Abonnement(
      idAbonnement: map['idAbonnement'] as String?,
      typeAbonnement: map['typeAbonnement'] as String?,
      codeAbonnement: map['codeAbonnement'] as String?,
      options: (map['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dateAjout: map['dateAjout'] != null ? DateTime.parse(map['dateAjout']) : null,
      dateFin: map['dateFin'] != null ? DateTime.parse(map['dateFin']) : null,
      montant: map['montant'] != null ? (map['montant']) : null,
      statutAbonnement: map['statutAbonnement'] as bool?,
    );
  }

  // Méthode toMap (Abonnement vers Map)
  Map<String, dynamic> toMap() {
    return {
      'idAbonnement': idAbonnement,
      'typeAbonnement': typeAbonnement,
      'codeAbonnement': codeAbonnement,
      'options': options,
      'dateAjout': dateAjout?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'montant': montant,
      'statutAbonnement': statutAbonnement,
    };
  }
  
}
