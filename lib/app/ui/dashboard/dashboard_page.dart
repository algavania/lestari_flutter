import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/app/ui/campaign_form//campaign_form_page.dart';
import 'package:lestari_flutter/app/ui/dashboard/animals/animals_page.dart';
import 'package:lestari_flutter/app/ui/dashboard/campaigns/campaigns_page.dart';
import 'package:lestari_flutter/app/ui/dashboard/home/home_page.dart';
import 'package:lestari_flutter/app/ui/dashboard/my_campaigns/my_campaigns_page.dart';
import 'package:lestari_flutter/app/ui/dashboard/profile/profile_page.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ValueNotifier<UserModel?> _currentUser = ValueNotifier(null);
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  List<Map<String, Widget>> _navigationItems = [];
  List<Widget> _navigationViews = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _navigationItems = [
      {'Beranda': const Icon(Icons.home)},
      {'Hewan Langka Indonesia': const Icon(Icons.pets)},
      {'Kampanye Konservasi': const Icon(Icons.campaign)},
      {'Kampanye Saya': const Icon(Icons.add_box)},
      {'Profil': const Icon(Icons.account_circle)},
    ];

    _navigationViews = [
      ValueListenableBuilder(
        valueListenable: _currentUser,
        builder: (_, __, ___) {
          return HomePage(bottomIndex: _selectedIndex, currentUser: _currentUser);
        }
      ),
      const AnimalsPage(),
      const CampaignsPage(),
      const MyCampaignsPage(),
      ValueListenableBuilder(
          valueListenable: _currentUser,
          builder: (_, __, ___) {
            return ProfilePage(currentUser: _currentUser);
          }
      ),
    ];


    _listenToUser();
  }

  Future<void> _listenToUser() async {
    context.loaderOverlay.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserModel userData = (await UserRepository().getUserById(prefs.getString('uid')!))!;
    _currentUser.value = userData;
    await UserRepository().listenToCurrentUser(_currentUser);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectedIndex,
      builder: (context, _, __) {
        return Scaffold(
          body: IndexedStack(index: _selectedIndex.value, children: _navigationViews),
          floatingActionButton: (_selectedIndex.value == 3) ? _buildFloatingActionButton() : null,
          bottomNavigationBar: BottomNavigationBar(
            items: _navigationItems.map((item) => BottomNavigationBarItem(icon: item.values.first, label: item.keys.first)).toList(),
            currentIndex: _selectedIndex.value,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => _selectedIndex.value = index,
          ),
        );
      }
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: AdSize.banner.height.toDouble()),
      child: FloatingActionButton(
        onPressed: () {
          SharedCode.navigatorPush(context, const CampaignFormPage());
        },
        elevation: 1.0,
        child: const Icon(Icons.add, color: Colors.white, size: 35.0),
      ),
    );
  }
}
