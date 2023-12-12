import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/report_model.dart';

abstract class BaseReportsRepository {
  Future<DocumentReference> addReport(ReportModel report);
  Future<void> updateReport(ReportModel report);
}
