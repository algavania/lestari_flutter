
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/ui/edit_profile/edit_profile_page.dart';
import 'package:lestari_flutter/app/ui/settings/settings_page.dart';
import 'package:lestari_flutter/app/ui/subscription/subscription_offer_page.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  final ValueNotifier<UserModel?> currentUser;
  const ProfilePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

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
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AdSize.banner.height.toDouble()),
          child: ValueListenableBuilder(
              valueListenable: widget.currentUser,
              builder: (_, __, ___) {
              return Stack(children: [
                _buildBackground(),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 10.h, 20.0, 30.0),
                  child: Column(children: [
                    _buildProfileCard(),
                    // const SizedBox(height: 25.0),
                    // _buildSubscribeBanner(),
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: _buildProfilePicture(),
                ),
              ]);
            }
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
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
        width: 100.w,
        height: 25.h,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/home_background.png'), fit: BoxFit.cover))
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: CachedNetworkImage(imageUrl: 
          widget.currentUser.value?.imageUrl ?? 'https://firebasestorage.googleapis.com/v0/b/lestari-42054.appspot.com/o/default%2Fdefault_profile.jpg?alt=media&token=2257a163-0f7b-4194-8c4e-333256db8ce1',
          width: 22.w,
          height: 22.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(top: 11.w),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ]
      ),
      child: Column(children: [
        SizedBox(height: 10.w),
        Text(widget.currentUser.value?.name ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(widget.currentUser.value?.email ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: ColorValues.grey)),
        const SizedBox(height: 15.0),
        ElevatedButton(
          onPressed: () {
            SharedCode.navigatorPush(context, EditProfilePage(userModel: widget.currentUser.value!));
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(150.0, 45.0)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.edit_rounded, size: 16.0, color: ColorValues.onyx),
            SizedBox(width: 10.0),
            Text('Ubah Profil')
          ])
        ),
        const SizedBox(height: 25.0),
        // _buildMenu(Icons.favorite_rounded, 'Kampanye Favorit', () {
        //   SharedCode.navigatorPush(context, const FavoriteCampaignsPage());
        // }),
        // const SizedBox(height: 8.0),
        // _buildMenu(Icons.workspace_premium_rounded, 'Informasi Langganan', () {
        //   SharedCode.navigatorPush(context, const SubscriptionOfferPage());
        // }),
        const SizedBox(height: 8.0),
        _buildMenu(Icons.settings_rounded, 'Pengaturan', () {
          SharedCode.navigatorPush(context, const SettingsPage());
        }),
      ]),
    );
  }

  Widget _buildMenu(IconData icon, String text, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: ColorValues.onyx,),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Text(text, style: GoogleFonts.poppins(fontSize: 14)),
        )),
        const Icon(Icons.chevron_right),
      ]),
    );
  }

  Widget _buildSubscribeBanner() {
    return InkWell(
      onTap: () {
        SharedCode.navigatorPush(context, const SubscriptionOfferPage());
      },
      child: Container(
        width: 100.w,
        height: 150.0,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEED6),
          image: const DecorationImage(image: AssetImage('assets/subscribe_background.png'), alignment: Alignment.centerRight),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Jelajahi Tanpa Iklan', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 15.0),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme.of(context).primaryColor
                ),
                child: Text('Langganan Sekarang', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              )
            ]),
          ),
          const Expanded(child: SizedBox.shrink()),
        ]),
      ),
    );
  }
}
