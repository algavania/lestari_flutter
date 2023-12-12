import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lestari_flutter/models/report_model.dart';

import 'base_reports_repository.dart';

class ReportsRepository extends BaseReportsRepository {
  CollectionReference reports = FirebaseFirestore.instance.collection('reports');

  @override
  Future<DocumentReference> addReport(ReportModel report) async {
    Map<String, Object?> json = report.toMap();
    return await reports.add(json);
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    await reports.doc(report.id).update(report.toMap());
  }

}