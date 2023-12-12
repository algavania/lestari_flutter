import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lestari_flutter/app/repositories/animals/base_animals_repository.dart';
import 'package:lestari_flutter/models/animal_model.dart';

class AnimalsRepository extends BaseAnimalsRepository {
  @override
  Future<List<AnimalModel>> getAnimals() async {
    List<AnimalModel> models = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('animals')
          .orderBy('updated_at', descending: true)
          .get();
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        AnimalModel model = AnimalModel.fromMap(map);
        models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<AnimalModel>> getAnimalsByKeyword(String keyword) async {
    List<AnimalModel> models = [];
    keyword = keyword.toUpperCase();
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('animals')
          .where('searchable_name', isGreaterThanOrEqualTo: keyword)
          .where('searchable_name', isLessThanOrEqualTo: "$keyword\uf7ff")
          .get();
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        AnimalModel model = AnimalModel.fromMap(map);
        models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }
}
