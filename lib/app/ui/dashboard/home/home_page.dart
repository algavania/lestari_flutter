import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lestari_flutter/app/blocs/animals/animals_bloc.dart';
import 'package:lestari_flutter/app/blocs/articles/articles_bloc.dart';
import 'package:lestari_flutter/app/blocs/campaigns/campaigns_bloc.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/app/ui/notifications/notifications_page.dart';
import 'package:lestari_flutter/models/animal_model.dart';
import 'package:lestari_flutter/models/article_model.dart';
import 'package:lestari_flutter/models/campaign_model.dart';
import 'package:lestari_flutter/app/ui/articles/articles_page.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:lestari_flutter/widgets/custom_animal_card.dart';
import 'package:lestari_flutter/widgets/custom_article_card.dart';
import 'package:lestari_flutter/widgets/custom_campaign_card.dart';
import 'package:lestari_flutter/widgets/custom_small_loading.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<UserModel?> currentUser;
  final ValueNotifier<int> bottomIndex;
  const HomePage({Key? key, required this.bottomIndex, required this.currentUser}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  late BuildContext _animalsContext, _campaignsContext, _articlesContext;

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

  Future<void> _refreshPage() async {
    BlocProvider.of<AnimalsBloc>(_animalsContext).add(const GetAnimalsEvent());
    BlocProvider.of<CampaignsBloc>(_campaignsContext).add(const GetCampaignsEvent());
    BlocProvider.of<ArticlesBloc>(_articlesContext).add(const GetArticlesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await _refreshPage();
          },
          child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AdSize.banner.height.toDouble()),
              child: Column(children: [
                _buildProfile(),
                const SizedBox(height: 20.0),
                _buildAnimals(),
                const SizedBox(height: 30.0),
                _buildCampaigns(),
                const SizedBox(height: 30.0),
                _buildArticles(),
                const SizedBox(height: 30.0),
              ])
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
    );
  }

  Widget _buildProfile() {
    return Container(
      width: 100.w,
      padding: SharedCode.altPagePadding,
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/home_background.png'), fit: BoxFit.cover),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
      ),
      child: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: ValueListenableBuilder(
              valueListenable: widget.currentUser,
              builder: (_, __, ___) {
                return RichText(
                  text: TextSpan(
                    text: 'Halo,',
                    style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\n${widget.currentUser.value?.name ?? ""}',
                        style: GoogleFonts.poppins(fontSize: 20, decoration: TextDecoration.underline, fontWeight: FontWeight.w600, height: 1.5),
                      )
                    ]
                  ),
                );
              }
            )),
            const SizedBox(width: 25.0),
            GestureDetector(
              onTap: () {
                SharedCode.navigatorPush(context, NotificationsPage(currentUser: widget.currentUser));
              },
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: Stack(
                  children: [
                    const Icon(Icons.notifications, size: 24.0, color: ColorValues.onyx),
                    ValueListenableBuilder(valueListenable: widget.currentUser, builder: (_, __, ___) {
                      return ((widget.currentUser.value?.notifications ?? 0) > 0) ? Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(color: ColorValues.universityRed, borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ) : const SizedBox.shrink();
                    })
                  ],
                ),
              )
            )
          ]),
          const SizedBox(height: 10.0),
          Text(
            'Yuk, bersama-sama lestarikan hewan endemik langka Indonesia.',
            style: GoogleFonts.poppins(fontSize: 14, height: 1.3),
          )
        ],
      )),
    );
  }

  Widget _buildAnimals() {
    return Column(children: [
      _buildSectionTitle('Kenali Hewan Nusantara', () => widget.bottomIndex.value = 1),
      BlocProvider(
        create: (context) =>
        AnimalsBloc(RepositoryProvider.of<AnimalsRepository>(context))
          ..add(const GetAnimalsEvent()),
        child: BlocBuilder<AnimalsBloc, AnimalsState>(
            builder: (context, state) {
              _animalsContext = context;
              if (state is AnimalsLoading) {
                return const CustomSmallLoading();
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
      )
    ]);
  }

  Widget _buildCampaigns() {
    return Column(children: [
      _buildSectionTitle('Ikuti Kampanye Menarik', () => widget.bottomIndex.value = 2),
      BlocProvider(
        create: (context) =>
        CampaignsBloc(RepositoryProvider.of<CampaignsRepository>(context))
          ..add(const GetCampaignsEvent()),
        child: BlocBuilder<CampaignsBloc, CampaignsState>(
            builder: (context, state) {
              _campaignsContext = context;
              if (state is CampaignsLoading) {
                return const CustomSmallLoading();
              }
              if (state is CampaignsInitial) {
                return const SizedBox.shrink();
              }
              if (state is CampaignsError) {
                return Center(child: Text(state.message));
              }
              if (state is CampaignsLoaded) {
                return _buildCampaignList(state.campaignModels);
              }
              return Container();
            }
        ),
      )
    ]);
  }

  Widget _buildArticles() {
    return Column(children: [
      _buildSectionTitle('Artikel Terbaru', () => SharedCode.navigatorPush(context, const ArticlesPage())),
      BlocProvider(
        create: (context) =>
        ArticlesBloc(RepositoryProvider.of<ArticlesRepository>(context))
          ..add(const GetArticlesEvent()),
        child: BlocBuilder<ArticlesBloc, ArticlesState>(
            builder: (context, state) {
              _articlesContext = context;
              if (state is ArticlesLoading) {
                return const CustomSmallLoading();
              }
              if (state is ArticlesInitial) {
                return const SizedBox.shrink();
              }
              if (state is ArticlesError) {
                return Center(child: Text(state.message));
              }
              if (state is ArticlesLoaded) {
                return _buildArticleList(state.articleModels);
              }
              return Container();
            }
        ),
      ),
    ]);
  }

  Widget _buildAnimalList(List<AnimalModel> animalModels) {
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          itemBuilder: (_, i) {
            return CustomAnimalCard(animalModel: animalModels[i]);
          },
          separatorBuilder: (_, __) => const SizedBox(width: 5.0),
          itemCount: animalModels.length),
    );
  }

  Widget _buildCampaignList(List<CampaignModel> campaignModels) {
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          itemBuilder: (_, i) {
            return CustomCampaignCard(campaignModel: campaignModels[i]);
          },
          separatorBuilder: (_, __) => const SizedBox(width: 5.0),
          itemCount: campaignModels.length),
    );
  }

  Widget _buildArticleList(List<ArticleModel> articleModels) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          itemBuilder: (_, i) {
            return CustomArticleCard(articleModel: articleModels[i], isPreview: true);
          },
          separatorBuilder: (_, __) => const SizedBox(width: 20.0),
          itemCount: articleModels.length),
    );
  }

  Widget _buildSectionTitle(String title, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
      child: Row(children: [
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600))),
        const SizedBox(width: 15.0),
        GestureDetector(
          onTap: onTap,
          child: Text('Lihat Semua', style: GoogleFonts.poppins(fontSize: 14, decoration: TextDecoration.underline, color: ColorValues.accentGreen)),
        )
      ]),
    );
  }
}
