import 'package:flutter/material.dart';
import 'package:lestari_flutter/models/animal_model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerPage extends StatelessWidget {
  const ModelViewerPage({Key? key, required this.animal}) : super(key: key);
  final AnimalModel animal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(animal.name)),
      body: ModelViewer(
        src: animal.modelUrl,
        alt: animal.name,
        ar: true,
        disableZoom: true,
      ),
    );
  }
}
