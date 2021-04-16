import 'package:flutter/material.dart';

class Statistic {
  String id;
  String value;
  String description;
  Color textColor;
  Color backgroundColor;

  Statistic();

  Statistic.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      value = jsonMap['value'].toString() ?? '0';
      description = jsonMap['description'].toString() ?? '';
    } catch (e) {
      id = '';
      value = '0';
      description = '';
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["value"] = value;
    map["description"] = description;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
