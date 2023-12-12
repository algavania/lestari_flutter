import 'package:lestari_flutter/models/animal_model.dart';

abstract class BaseAnimalsRepository {
  Future<List<AnimalModel>> getAnimals();
  Future<List<AnimalModel>> getAnimalsByKeyword(String keyword);
}
