import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lestari_flutter/app/blocs/animals/animals_bloc.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/models/animal_model.dart';
import 'package:lestari_flutter/widgets/custom_animal_card.dart';
import 'package:lestari_flutter/widgets/custom_loading.dart';
import 'package:sizer/sizer.dart';

class AnimalsPage extends StatefulWidget {
  const AnimalsPage({Key? key}) : super(key: key);

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
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
              AnimalsBloc(RepositoryProvider.of<AnimalsRepository>(context))
                ..add(const GetAnimalsEvent()),
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshPage();
                },
                child: BlocBuilder<AnimalsBloc, AnimalsState>(
                    builder: (context, state) {
                      _context = context;
                      if (state is AnimalsLoading) {
                        if (!_isSearching) {
                          return const CustomLoading();
                        } else {
                          _isSearching = false;
                          return const SizedBox.shrink();
                        }
                      }
                      if (state is AnimalsInitial) {
                        return const SizedBox.shrink();
                      }
                      if (state is AnimalsError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is AnimalsLoaded) {
                        return _buildAnimalList(state.animalModels);
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

  Widget _buildAnimalList(List<AnimalModel> animalModels) {
    return GridView.builder(
      padding: SharedCode.defaultPagePadding,
      itemCount: animalModels.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 48.w / 43.h, mainAxisSpacing: 8.0, crossAxisSpacing: 4.0),
      itemBuilder: (BuildContext context, int index) {
        return CustomAnimalCard(animalModel: animalModels[index]);
      },
    );
  }

  Future<void> _refreshPage() async {
    BlocProvider.of<AnimalsBloc>(_context).add(const GetAnimalsEvent());
  }

  AppBar _buildSearchAppBar() {
    return SharedCode.buildSearchAppBar(context: context, searchHint: 'Cari hewan', title: 'Hewan Langka Indonesia', onChanged: (s) {
      _isSearching = true;
      if (s == null || s.isEmpty) {
        _refreshPage();
      } else {
        BlocProvider.of<AnimalsBloc>(_context).add(SearchAnimalsEvent(s));
      }
    });
  }
}
