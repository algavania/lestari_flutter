import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lestari_flutter/app/repositories/campaigns/campaigns_repository.dart';
import 'package:lestari_flutter/models/campaign_model.dart';

part 'campaigns_event.dart';
part 'campaigns_state.dart';

class CampaignsBloc extends Bloc<CampaignsEvent, CampaignsState> {
  final CampaignsRepository _repository;

  CampaignsBloc(this._repository) : super(CampaignsInitial()) {
    on<GetCampaignsEvent>(_getCampaigns);
    on<SearchCampaignsEvent>(_getCampaignsByKeyword);
  }

  Future<void> _getCampaigns(GetCampaignsEvent event, Emitter<CampaignsState> emit) async {
    emit(CampaignsLoading());
    try {
      List<CampaignModel> model = await _repository.getCampaigns(event.id);
      emit(CampaignsLoaded(model));
    } catch (e) {
      emit(CampaignsError(e.toString()));
    }
  }

  Future<void> _getCampaignsByKeyword(SearchCampaignsEvent event, Emitter<CampaignsState> emit) async {
    try {
      List<CampaignModel> model = await _repository.getCampaignsByKeyword(event.id, event.keyword);
      debugPrint('get campaigns by keyword ${event.keyword} ${model.length}');
      emit(CampaignsLoaded(model));
    } catch (e) {
      emit(CampaignsError(e.toString()));
    }
  }
}
