part of 'campaigns_bloc.dart';

abstract class CampaignsEvent extends Equatable {
  const CampaignsEvent();
}

class GetCampaignsEvent extends CampaignsEvent {
  const GetCampaignsEvent({this.id});
  final String? id;

  @override
  List<Object?> get props => [id];
}

class SearchCampaignsEvent extends CampaignsEvent {
  const SearchCampaignsEvent({required this.keyword, this.id});
  final String keyword;
  final String? id;

  @override
  List<Object?> get props => [keyword, id];
}
