import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

AnimalModel animalModelFromMap(String str) =>
    AnimalModel.fromMap(json.decode(str));

String animalModelToMap(AnimalModel data) => json.encode(data.toMap());

class AnimalModel {
  final String
      name,
      id,
      modelUrl,
      conservationStatus,
      vore,
      classification,
      scientificName,
      habitat,
      location,
      weight,
      length,
      description,
      cause,
      prevention;
  final List<String> imageUrls;
  final DateTime updatedAt;
  final String? searchableName;

  AnimalModel({
    required this.id,
    this.searchableName,
    required this.name,
    required this.modelUrl,
    required this.conservationStatus,
    required this.vore,
    required this.classification,
    required this.scientificName,
    required this.habitat,
    required this.location,
    required this.weight,
    required this.length,
    required this.description,
    required this.cause,
    required this.prevention,
    required this.imageUrls,
    required this.updatedAt,
  });

  factory AnimalModel.fromMap(Map<String, dynamic> json) {
    Timestamp updatedAt = json["updated_at"];
    return AnimalModel(
        id: json["id"],
        searchableName: json["searchable_name"],
        name: json["name"],
        modelUrl: json["model_url"],
        conservationStatus: json["conservation_status"],
        vore: json["vore"],
        classification: json["classification"],
        scientificName: json["scientific_name"],
        habitat: json["habitat"],
        location: json["location"],
        weight: json["weight"],
        length: json["length"],
        description: json["description"],
        cause: json["cause"],
        prevention: json["prevention"],
        imageUrls: List<String>.from(json["image_urls"].map((x) => x)),
        updatedAt: updatedAt.toDate());
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "searchable_name": name.toUpperCase(),
        "model_url": modelUrl,
        "conservation_status": conservationStatus,
        "vore": vore,
        "classification": classification,
        "scientific_name": scientificName,
        "habitat": habitat,
        "location": location,
        "weight": weight,
        "length": length,
        "description": description,
        "cause": cause,
        "prevention": prevention,
        "image_urls": List<String>.from(imageUrls.map((x) => x)),
        "updated_at": Timestamp.fromDate(updatedAt),
      };
}
