import 'package:cloud_firestore/cloud_firestore.dart';

class Cube {
  String name;
  DateTime date;
  int count;
  int weight;

  Cube(
      {required this.name,
      required this.date,
      required this.count,
      required this.weight});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['name'] = name;
    data['date'] = date;
    data['count'] = count;
    data['weight'] = weight;
    return data;
  }

  factory Cube.fromQuerySnapshot(QueryDocumentSnapshot snapshot) {
    return Cube(
        name: snapshot['name'],
        date: DateTime.parse(snapshot['date'].toDate().toString()),
        count: snapshot['count'],
        weight: snapshot['weight']);
  }
}
