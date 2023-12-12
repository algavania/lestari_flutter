import 'package:lestari_flutter/models/article_model.dart';

abstract class BaseArticlesRepository {
  Future<List<ArticleModel>> getArticles();
  Future<List<ArticleModel>> getArticlesByKeyword(String keyword);
}