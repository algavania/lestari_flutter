import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lestari_flutter/app/repositories/articles/base_articles_repository.dart';
import 'package:lestari_flutter/models/article_model.dart';

class ArticlesRepository extends BaseArticlesRepository {
  @override
  Future<List<ArticleModel>> getArticles() async {
    List<ArticleModel> models = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('articles').orderBy('created_at', descending: true).get();
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        ArticleModel model = ArticleModel.fromMap(map);
        models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<ArticleModel>> getArticlesByKeyword(String keyword) async {
    List<ArticleModel> models = [];
    keyword = keyword.toUpperCase();
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('articles')
          .where('searchable_title', isGreaterThanOrEqualTo: keyword)
          .where('searchable_title', isLessThanOrEqualTo: "$keyword\uf7ff")
          .get();
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        ArticleModel model = ArticleModel.fromMap(map);
        models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }
}