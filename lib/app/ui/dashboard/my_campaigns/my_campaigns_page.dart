import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/models/campaign_model.dart';
import 'package:lestari_flutter/widgets/custom_campaign_card.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../../blocs/campaigns/campaigns_bloc.dart';
import '../../../repositories/repositories.dart';

class MyCampaignsPage extends StatefulWidget {
  const MyCampaignsPage({Key? key}) : super(key: key);

  @override
  State<MyCampaignsPage> createState() => _MyCampaignsPageState();
}

class _MyCampaignsPageState extends State<MyCampaignsPage> {
  late BuildContext _context;
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isSearching = false;

  @override
  void initState() {
    _loadAd();
    super.initState();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: SharedCode.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: ${err.message}');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AdSize.banner.height.toDouble()),
            child: BlocProvider(
              create: (context) =>
              CampaignsBloc(RepositoryProvider.of<CampaignsRepository>(context))
                ..add(GetCampaignsEvent(id: FirebaseAuth.instance.currentUser?.uid)),
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshPage();
                },
                child: BlocBuilder<CampaignsBloc, CampaignsState>(
                    builder: (context, state) {
                      _context = context;
                      if (state is CampaignsLoading) {
                        if (!_isSearching) {
                          context.loaderOverlay.show();
                        } else {
                          _isSearching = false;
                        }
                        return Container();
                      }
                      if (state is CampaignsInitial) {
                        context.loaderOverlay.hide();
                      }
                      if (state is CampaignsError) {
                        context.loaderOverlay.hide();
                        return Center(child: Text(state.message));
                      }
                      if (state is CampaignsLoaded) {
                        context.loaderOverlay.hide();
                        return _buildCampaignGrid(state.campaignModels);
                      }
                      return Container();
                    }
                ),
              ),
            ),
          ),
          if (_bannerAd != null && _isLoaded)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 100.w,
                      height: _bannerAd!.size.height.toDouble(),
                      color: Colors.white,
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCampaignGrid(List<CampaignModel> campaignModels) {
    return (campaignModels.isNotEmpty)
      ? GridView.builder(
        padding: SharedCode.defaultPagePadding,
        itemCount: campaignModels.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 48.w / 43.h, mainAxisSpacing: 8.0, crossAxisSpacing: 4.0),
        itemBuilder: (BuildContext context, int index) {
          return CustomCampaignCard(campaignModel: campaignModels[index]);
        },
      )
      : const Center(child: Text('Anda belum mengunggah kampanye.'));
  }

  Future<void> _refreshPage() async {
    BlocProvider.of<CampaignsBloc>(_context).add(GetCampaignsEvent(id: FirebaseAuth.instance.currentUser?.uid));
  }

  AppBar _buildSearchAppBar() {
    return SharedCode.buildSearchAppBar(context: context, searchHint: 'Cari kampanye', title: 'Kampanye Saya', onChanged: (s) {
      _isSearching = true;
      if (s == null || s.isEmpty) {
        _refreshPage();
      } else {
        BlocProvider.of<CampaignsBloc>(_context).add(SearchCampaignsEvent(keyword: s, id: FirebaseAuth.instance.currentUser?.uid));
      }
    });
  }
}
