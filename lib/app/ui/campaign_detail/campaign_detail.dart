import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/blocs/user/user_bloc.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/app/ui/campaign_detail/campaign_removed_page.dart';
import 'package:lestari_flutter/app/ui/dashboard/dashboard_page.dart';
import 'package:lestari_flutter/models/campaign_model.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:lestari_flutter/widgets/custom_loading.dart';
import 'package:lestari_flutter/widgets/custom_tag.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignDetailPage extends StatefulWidget {
  final CampaignModel campaignModel;
  const CampaignDetailPage({Key? key, required this.campaignModel}) : super(key: key);

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  final ValueNotifier<int> _carouselIndex = ValueNotifier<int>(0);
  late UserModel _organizerModel;
  late String _uid;

  void _showMoreMenus(){
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100.w, 0.0, 0.0, 0.0),
      items: [
        const PopupMenuItem<String>(
          value: 'Delete',
          child: Text('Hapus Kampanye'),
        ),
      ],
      elevation: 3.0,
    ).then((value) async {
      if (value == 'Delete') {
        await _deleteCampaign();
      }
      // if (value == 'Report') SharedCode.navigatorPush(context, ReportPage(type: 'campaigns', id: widget.campaignModel.id, title: widget.campaignModel.title,));
    });
  }

  Future<void> _getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid')!;
  }

  Future<void> _deleteCampaign() async {
    SharedCode.showAlertDialog(context, 'Hapus Kampanye', 'Yakin untuk menghapus kampanye ini?', 'Hapus', () async {
      context.loaderOverlay.show();

      try {
        await CampaignsRepository().deleteCampaign(widget.campaignModel.id);

        Future.delayed(Duration.zero, () {
          context.loaderOverlay.hide();
          SharedCode.navigatorReplace(context, const CampaignRemovedPage());
        });
      } catch (e) {
        context.loaderOverlay.hide();
        SharedCode.navigatorReplace(context, const DashboardPage());
        SharedCode.showSnackBar(context, false, e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUid(),
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Scaffold(body: CustomLoading());
          default:
            if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text(snapshot.error.toString())));
            } else {
              return BlocProvider(
                create: (context) =>
                UserBloc(RepositoryProvider.of<UserRepository>(context))
                  ..add(GetUserByIdEvent(widget.campaignModel.organizerId)),
                child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      if (state is UserLoading) {
                        return const Scaffold(body: CustomLoading());
                      }
                      if (state is UserInitial) {
                        return const Scaffold(body: CustomLoading());
                      }
                      if (state is UserError) {
                        return Scaffold(body: Center(child: Text(state.message)));
                      }
                      if (state is UserLoaded) {
                        _organizerModel = state.userModel;
                        return Scaffold(
                          appBar: _buildAppBar(),
                          body: _buildCampaignDetail(),
                          bottomNavigationBar: _buildBottomWidget(),
                        );
                      }
                      return Scaffold(body: Container());
                    }
                ),
              );
            }
        }
      }
    );
  }

  Widget _buildCampaignDetail() {
    return SingleChildScrollView(
      child: Stack(children: [
        _buildCarousel(),
        Column(children: [
          SizedBox(height: 32.h),
          _buildPageIndicator(),
          _buildInfoCard(),
          _buildDetails(),
        ]),
      ]),
    );
  }

  Widget _buildBottomWidget() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(color:Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, -3), // changes position of shadow
        ),
      ]),
      child: ElevatedButton(
        onPressed: () {
          _launchUrl();
        },
        child: const Text('Kunjungi Situs Kampanye'),
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(widget.campaignModel.websiteUrl), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${widget.campaignModel.websiteUrl}');
    }
  }

    Widget _buildInfoCard() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8.0, runSpacing: 8.0, children: [CustomTag(tag: widget.campaignModel.category)]),
          const SizedBox(height: 8.0),
          Text(widget.campaignModel.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12.0),
          Row(children: [
            Expanded(child: _buildMainInfo(Icons.calendar_today_rounded, SharedCode.dateFormat.format(widget.campaignModel.date))),
            const SizedBox(height: 5.0),
            Expanded(child: _buildMainInfo(Icons.location_pin, widget.campaignModel.city)),
          ]),
          const SizedBox(height: 15.0),
          if (_organizerModel.uid == _uid) Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text('Status: ${widget.campaignModel.status == 'online' ? 'Tampil secara publik' : 'Menunggu approval admin'}'),
          ),
          Row(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: CachedNetworkImage(imageUrl: _organizerModel.imageUrl, width: 30.0, height: 30.0, fit: BoxFit.cover)
            ),
            const SizedBox(width: 10.0),
            Expanded(child: Text(_organizerModel.name, style: GoogleFonts.poppins(fontSize: 14))),
          ])
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 38.h,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.campaignModel.imageUrls.length,
        onPageChanged: (index) {
          _carouselIndex.value = index;
        },
        itemBuilder: (_, int i) {
          return CachedNetworkImage(imageUrl: 
              widget.campaignModel.imageUrls[i],
              width: 100.w,
              height: 38.h,
              fit: BoxFit.cover
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return ValueListenableBuilder(
        valueListenable: _carouselIndex,
        builder: (_, __, ___) {
          return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(widget.campaignModel.imageUrls.length, (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildDotIndicator(_carouselIndex.value == index),
                ))
              ]
          );
        }
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return Container(
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? ColorValues.accentGreen : ColorValues.lightGrey),
    );
  }

  Widget _buildDetails() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 3,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        )],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      child: _buildDetailInfo('Deskripsi', widget.campaignModel.description.replaceAll('+', '\n')),
    );
  }

  Widget _buildDetailInfo(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        Text(description, style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.justify),
      ],
    );
  }

  Widget _buildMainInfo(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: ColorValues.grey, size: 16.0),
      const SizedBox(width: 8.0),
      Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 10, color: ColorValues.grey)))
    ]);
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text('Detail Kampanye', style: GoogleFonts.poppins(fontSize: 16)),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back_ios, size: 20.0, color: ColorValues.grey),
      ),
      actions: [
      //   InkWell(
      //       onTap: () {},
      //       child: const Icon(Icons.favorite_border_outlined)
      //   ),
        if (_organizerModel.uid == _uid) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: InkWell(
              onTap: _showMoreMenus,
              child: const Icon(Icons.more_vert_rounded)
          ),
        ),
      ],
    );
  }
}
