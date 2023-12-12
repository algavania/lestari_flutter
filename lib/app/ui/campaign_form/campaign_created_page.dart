import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/ui/dashboard/dashboard_page.dart';
import 'package:sizer/sizer.dart';

class CampaignCreatedPage extends StatefulWidget {
  const CampaignCreatedPage({Key? key}) : super(key: key);

  @override
  State<CampaignCreatedPage> createState() => _CampaignCreatedPageState();
}

class _CampaignCreatedPageState extends State<CampaignCreatedPage> {
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
          Center(child: Image.asset('assets/icon_check.png', width: 25.w, height: 20.h, fit: BoxFit.contain)),
          Text('Kampanye Telah Dibuat', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
          const SizedBox(height: 10.0),
          Text('Kampanye berhasil dibuat. Kamu bisa menemukan kampanye buatanmu di halaman “Kampanye Saya”.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10)),
        ]),
      ),
    );
  }
}
