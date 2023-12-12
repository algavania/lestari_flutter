import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:sizer/sizer.dart';

class SubscriptionOfferPage extends StatefulWidget {
  const SubscriptionOfferPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionOfferPage> createState() => _SubscriptionOfferPageState();
}

class _SubscriptionOfferPageState extends State<SubscriptionOfferPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Informasi Langganan'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: Column(children: [
          _buildMainInfo(),
          const SizedBox(height: 40.0),
          _buildOffer(),
        ]),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
      Center(child: Image.asset('assets/subscribe_art.png', width: 80.w, height: 30.h, fit: BoxFit.contain)),
      Padding(
        padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
        child: Text(
          'Nikmati Layanan Lestari Bebas Iklan',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)
        ),
      ),
      const Text('Mulai berlangganan dan dapatkan akses seluruh fitur tanpa iklan.'),
    ]);
  }

  Widget _buildOffer() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 100.w,
          padding: const EdgeInsets.all(15.0),
          decoration: const BoxDecoration(
            color: ColorValues.juneBud,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
          ),
          child: Text('Paket Bebas Iklan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
              text: 'Rp99.000',
                style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 16, fontWeight: FontWeight.w500),
                children: <TextSpan>[
                  TextSpan(
                    text: '  /bulan',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            _buildOfferInfo('Mulai dari', '31 Januari 2023'),
            const SizedBox(height: 3.0),
            _buildOfferInfo('Selesai pada', '28 Februari 2023'),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Mulai Berlangganan')
            ),
          ])
        ),
      ]),
    );
  }

  Widget _buildOfferInfo(String title, String description) {
    return Row(children: [
      Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500))),
      Text(description, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
    ]);
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back_ios, size: 20.0, color: ColorValues.grey),
      ),
      elevation: 0,
    );
  }
}
