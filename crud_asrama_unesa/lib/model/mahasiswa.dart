class Mahasiswa {
  String? nokamar;
  String? nama;
  String? jurusan;
  String? tanggalLahir;
  String? alamat;
  String? foto;

  Mahasiswa({
    this.nokamar,
    this.nama,
    this.jurusan,
    this.tanggalLahir,
    this.alamat,
    this.foto,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) => Mahasiswa(
        nokamar: json['nokamar'],
        nama: json['nama'],
        jurusan: json['jurusan'],
        tanggalLahir: json['tanggal_lahir'],
        alamat: json['alamat'],
        foto: json['foto'],
      );

  Map<String, dynamic> toJson() => {
        'nokamar': nokamar,
        'nama': nama,
        'jurusan': jurusan,
        'tanggal_lahir': tanggalLahir,
        'alamat': alamat,
        'foto': foto,
      };
}
