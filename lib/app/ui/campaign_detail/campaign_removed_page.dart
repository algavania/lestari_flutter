import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/ui/dashboard/dashboard_page.dart';
import 'package:sizer/sizer.dart';

class CampaignRemovedPage extends StatefulWidget {
  const CampaignRemovedPage({Key? key}) : super(key: key);

  @override
  State<CampaignRemovedPage> createState() => _CampaignRemovedPageState();
}

class _CampaignRemovedPageState extends State<CampaignRemovedPage> {
  Future<void> _navigateToDashboard() async {
    await Future.delayed(const Duration(seconds: 3));
    SharedCode.navigatorReplace(context, const DashboardPage());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: SharedCode.defaultPagePadding,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(child: Image.asset('assets/icon_remove.png', width: 25.w, height: 20.h, fit: BoxFit.contain)),
          Text('Kampanye Dihapus', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
        ]),
      ),
    );
  }
}
