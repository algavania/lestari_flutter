import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/notifications/notification_repository.dart';
import 'package:lestari_flutter/app/repositories/user/user_repository.dart';
import 'package:lestari_flutter/models/notification_model.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:sizer/sizer.dart';

class NotificationDetailPage extends StatefulWidget {
  final ValueNotifier<UserModel?> currentUser;
  final NotificationModel notificationModel;

  const NotificationDetailPage({Key? key, required this.notificationModel, required this.currentUser})
      : super(key: key);

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  @override
  void initState() {
    if (!widget.notificationModel.isRead) _updateReadStatus();
    super.initState();
  }

  Future<void> _updateReadStatus() async {
    widget.notificationModel.isRead = true;
    await NotificationsRepository().updateNotification(widget.notificationModel, widget.currentUser.value?.uid ?? '');

    widget.currentUser.value?.notifications = (widget.currentUser.value?.notifications ?? 1) - 1;
    await UserRepository().updateUser(widget.currentUser.value!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Detail Notifikasi'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: _buildDetail(),
      ),
    );
  }

  Widget _buildDetail() {
    String title = '';
    String description = '';
    String reason = '';
    switch (widget.notificationModel.action) {
      case 'rejected':
        title = 'Publikasi Kampanye "${widget.notificationModel.campaignTitle}" Ditolak';
        description = 'Publikasi kampanye dengan judul "${widget.notificationModel.campaignTitle}" ditolak oleh admin dikarenakan adanya pelanggaran terhadap kebijakan Lestari. Silakan ulas alasan penolakan di bawah ini.';
        reason = 'Alasan Penolakan';
        break;
      case 'removed':
        title = 'Kampanye "${widget.notificationModel.campaignTitle}" Dinonaktifkan';
        description = 'Kampanye dengan judul "${widget.notificationModel.campaignTitle}" dinonaktifkan oleh admin dikarenakan adanya pelanggaran terhadap kebijakan Lestari. Silakan ulas alasan penghapusan di bawah ini.';
        reason = 'Alasan Penghapusan';
        break;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(SharedCode.dateFormat.format(widget.notificationModel.createdAt),
          style: GoogleFonts.poppins(fontSize: 10, color: ColorValues.grey)),
      const SizedBox(height: 10.0),
      Text(title,
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 25.0),
      Text(description,
          style: GoogleFonts.poppins(fontSize: 14),
          textAlign: TextAlign.justify),
      const SizedBox(height: 20.0),
      Container(
        width: 100.w,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: ColorValues.primaryYellow.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(reason,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: ColorValues.universityRed),
              textAlign: TextAlign.justify),
          Text(widget.notificationModel.reason,
              style: GoogleFonts.poppins(fontSize: 14),
              textAlign: TextAlign.justify),
        ]),
      ),
      const SizedBox(height: 20.0),
      Text('Kami sangat menjunjung tinggi kepuasan pengguna. Maka dari itu, kami mohon kerja samanya dalam menjaga keamanan serta kenyamanan dalam bersosialisasi dengan Lestari. Terima kasih.',
          style: GoogleFonts.poppins(fontSize: 14),
          textAlign: TextAlign.justify),
    ]);
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back_ios,
            size: 20.0, color: ColorValues.grey),
      ),
      elevation: 0,
    );
  }
}
