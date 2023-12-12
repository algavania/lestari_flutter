import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/models/campaign_model.dart';
import 'package:lestari_flutter/widgets/custom_campaign_card.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:sizer/sizer.dart';

class FavoriteCampaignsPage extends StatefulWidget {
  const FavoriteCampaignsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteCampaignsPage> createState() => _FavoriteCampaignsPageState();
}

class _FavoriteCampaignsPageState extends State<FavoriteCampaignsPage> {
  late CampaignModel _campaignModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _campaignModel = CampaignModel(id: '', status: 'online', organizerId: '', title: 'ITB Street Feeding', category: 'Donasi', province: 'Online', city: 'Online', description: 'Kampanye ITB Street Feeding merupakan upaya untuk melindungi dan menyelamatkan kucing-kucing di sekitar kampus. Upaya ini memiliki banyak kendala yang harus dihadapi, mulai dari banyaknya angka kucing liar yang kelaparan, hingga adanya kemungkinan kucing sakit yang berpotensi menular.\n\nDalam kampanye ini kami ingin mengajak masyarakat untuk memberikan bantuan berupa donasi dana untuk mendukung pemberian makan kepada kucing liar di sekitar ITB. Yuk, ikut serta dalam gerakan kami!', websiteUrl: 'https://kitabisa.com/', imageUrls: ['https://pbs.twimg.com/media/E_QzGyVVIAQJ_YV.jpg'], date: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GridView.builder(
        padding: SharedCode.defaultPagePadding,
        itemCount: 5,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 48.w / 45.h, mainAxisSpacing: 8.0, crossAxisSpacing: 4.0),
        itemBuilder: (BuildContext context, int index) {
          return CustomCampaignCard(campaignModel: _campaignModel);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 115,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.arrow_back_ios, color: ColorValues.grey, size: 20.0,)),
                  const SizedBox(width: 8.0),
                  Text('Kampanye Favorit', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(children: [
                Expanded(
                    child: CustomTextField(
                      verticalPadding: 10.0,
                      prefixIcon: const Icon(Icons.search, size: 22.0),
                      hintText: 'Cari kampanye',
                      fontSize: 14,
                    )
                ),
                const SizedBox(width: 10.0),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: 41.0,
                    height: 41.0,
                    decoration: BoxDecoration(border: Border.all(color: ColorValues.lightGrey), borderRadius: BorderRadius.circular(10.0)),
                    child: Icon(Icons.filter_alt, color: Theme.of(context).primaryColor,),
                  ),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
