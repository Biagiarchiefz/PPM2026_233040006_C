class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
      'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Catatan.fromMap(Map<String, dynamic> map) => Catatan(
        id: map['id'] as int?,
        judul: map['judul'] as String,
        isi: map['isi'] as String,
        kategori: map['kategori'] as String,
        dibuatPada:
            DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
      );

  Catatan copyWith({
    int? id,
    String? judul,
    String? isi,
    String? kategori,
    DateTime? dibuatPada,
  }) =>
      Catatan(
        id: id ?? this.id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        dibuatPada: dibuatPada ?? this.dibuatPada,
      );
}