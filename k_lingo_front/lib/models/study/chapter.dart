import 'dart:convert';
import 'package:http/http.dart' as http;

class Chapter {
  final int id;
  final String nameKr;
  final String nameEn;
  final String description;
  final String icon;

  Chapter({
    required this.id,
    required this.nameKr,
    required this.nameEn,
    required this.description,
    required this.icon,
  });

  // JSON 데이터를 Dart 객체로 변환하는 공장(Factory)
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      nameKr: json['nameKr'],
      nameEn: json['nameEn'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}