import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lestari_flutter/app/repositories/campaigns/base_campaigns_repository.dart';
import 'package:lestari_flutter/models/campaign_model.dart';

class CampaignsRepository extends BaseCampaignsRepository {
  CollectionReference campaigns =
      FirebaseFirestore.instance.collection('campaigns');

  @override
  Future<List<CampaignModel>> getCampaigns(String? id) async {
    List<CampaignModel> models = [];
    try {
      QuerySnapshot snapshot;
      if (id == null) {
        snapshot = await FirebaseFirestore.instance
            .collection('campaigns')
            .where('status', isEqualTo: 'online')
            .orderBy('date', descending: false)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('campaigns')
            .where('status', isNotEqualTo: 'archived')
            .where('organizer_id', isEqualTo: id)
            .orderBy('status')
            .orderBy('date', descending: false)
            .get();
      }
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        CampaignModel model = CampaignModel.fromMap(map);
        models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<CampaignModel>> getCampaignsByKeyword(
      String? id, String keyword) async {
    List<CampaignModel> models = [];
    keyword = keyword.toUpperCase();
    try {
      QuerySnapshot snapshot;
      if (id == null) {
        snapshot = await FirebaseFirestore.instance
            .collection('campaigns')
            .where('searchable_title', isGreaterThanOrEqualTo: keyword)
            .where('searchable_title', isLessThanOrEqualTo: "$keyword\uf7ff")
            .where('status', isEqualTo: 'online')
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('campaigns')
            .where('searchable_title', isGreaterThanOrEqualTo: keyword)
            .where('searchable_title', isLessThanOrEqualTo: "$keyword\uf7ff")
            // .where('status', isNotEqualTo: 'archived')
            .where('organizer_id', isEqualTo: id)
            .get();
      }
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        CampaignModel model = CampaignModel.fromMap(map);
        if (model.status != 'archived') models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<DocumentReference> addCampaign(CampaignModel campaign) async {
    Map<String, Object?> json = campaign.toMap();
    return await campaigns.add(json);
  }

  @override
  Future<void> updateCampaign(CampaignModel campaign) async {
    await campaigns.doc(campaign.id).update(campaign.toMap());
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    await campaigns.doc(campaignId).delete();
    await FirebaseStorage.instance.ref('campaigns/$campaignId').listAll().then((value) {
      for (Reference element in value.items) {
        FirebaseStorage.instance.ref(element.fullPath).delete();
      }
    });
  }
}
