import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lestari_flutter/models/campaign_model.dart';

abstract class BaseCampaignsRepository {
  Future<List<CampaignModel>> getCampaigns(String? id);
  Future<List<CampaignModel>> getCampaignsByKeyword(String? id, String keyword);
  Future<DocumentReference> addCampaign(CampaignModel campaign);
  Future<void> updateCampaign(CampaignModel campaign);
  Future<void> deleteCampaign(String campaignId);
}
