import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String id, authorId, title, imageUrl, description;
  final DateTime createdAt;

  ArticleModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> json) {
    Timestamp createdAt = json["created_at"];
    return ArticleModel(
      id: json["id"],
      title: json["title"],
      authorId: json["author_id"],
      imageUrl: json["image_url"],
      description: json["description"],
      createdAt: createdAt.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "author_id": authorId,
    "image_url": imageUrl,
    "description": description,
    "created_at": Timestamp.fromDate(createdAt),
  };
}