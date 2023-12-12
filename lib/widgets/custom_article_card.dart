import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/models/article_model.dart';
import 'package:lestari_flutter/app/ui/article_detail/article_detail.dart';
import 'package:sizer/sizer.dart';

class CustomArticleCard extends StatelessWidget {
  final ArticleModel articleModel;
  final bool isPreview;
  const CustomArticleCard({Key? key, required this.articleModel, this.isPreview = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isPreview ? 80.w : 100.w,
      height: isPreview ? null : 37.h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          SharedCode.navigatorPush(context, ArticleDetailPage(articleModel: articleModel));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: CachedNetworkImage(imageUrl: articleModel.imageUrl, fit: BoxFit.cover, width: 100.w)
              ),
            ),
            const SizedBox(height: 7.0),
            Text(articleModel.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5.0),
            Text(articleModel.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 10.0),
            Text(SharedCode.dateFormat.format(articleModel.createdAt), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
