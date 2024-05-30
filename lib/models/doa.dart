import 'dart:convert';
import 'package:my_quran/models/ayat.dart';

List<Doa> doaFromJson(String str) =>
    List<Doa>.from(json.decode(str).map((x) => Doa.fromJson(x)));

String doaToJson(List<Doa> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Doa {
  Doa(
      {required this.id,
      required this.grup,
      required this.nama,
      required this.ar,
      required this.tr,
      required this.idn,
      required this.tentang,
      required this.mood,
      required this.tag,
      this.ayat});

  int id;
  String grup;
  String nama;
  String ar;
  String tr;
  String idn;
  String tentang;
  String mood;
  String tag;
  List<Ayat>? ayat;

  factory Doa.fromJson(Map<String, dynamic> json) => Doa(
      id: json["id"],
      grup: json["grup"],
      nama: json["nama"],
      ar: json["ar"],
      tr: json["tr"],
      idn: json["idn"],
      tentang: json["tentang"],
      mood: json["mood"],
      tag: json["tag"],
      ayat: json.containsKey('ayat')
          ? List<Ayat>.from(json["ayat"]!.map((x) => Ayat.fromJson(x)))
          : null);

  Map<String, dynamic> toJson() => {
        "id": id,
        "grup": grup,
        "nama": nama,
        "ar": ar,
        "tr": tr,
        "idn": idn,
        "tentang": tentang,
        "mood": mood,
        "tag": tag,
        "ayat":
            ayat != null ? List<dynamic>.from(ayat!.map((e) => e.toJson())) : []
      };
}