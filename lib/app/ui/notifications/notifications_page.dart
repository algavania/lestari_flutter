import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/blocs/notifications/notifications_bloc.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/models/notification_model.dart';
import 'package:lestari_flutter/app/ui/notification_detail/notification_detail_page.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:lestari_flutter/widgets/custom_loading.dart';
import 'package:sizer/sizer.dart';

class NotificationsPage extends StatefulWidget {
  final ValueNotifier<UserModel?> currentUser;
  const NotificationsPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late BuildContext _context;

  Future<void> _refreshPage() async {
    BlocProvider.of<NotificationsBloc>(_context).add(GetNotificationsEvent(widget.currentUser.value?.uid ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Notifikasi'),
      body: BlocProvider(
        create: (context) =>
        NotificationsBloc(RepositoryProvider.of<NotificationsRepository>(context))
          ..add(GetNotificationsEvent(widget.currentUser.value?.uid ?? '')),
        child: RefreshIndicator(
          onRefresh: () async {
            await _refreshPage();
          },
          child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                _context = context;
                if (state is NotificationsLoading) {
                  return const CustomLoading();
                }
                if (state is NotificationsInitial) {
                  return const SizedBox.shrink();
                }
                if (state is NotificationsError) {
                  return Center(child: Text(state.message));
                }
                if (state is NotificationsLoaded) {
                  return _buildList(state.notificationModels);
                }
                return Container();
              }
          ),
        ),
      ),
    );
  }
  
  Widget _buildList(List<NotificationModel> notificationModels) {
    return (notificationModels.isNotEmpty)
        ? ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, i) {
              return _buildNotification(i, notificationModels[i]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 5.0),
            itemCount: notificationModels.length
        )
        : const Center(child: Text('Anda tidak memiliki notfikasi.'));
  }

  Widget _buildNotification(int i, NotificationModel notificationModel) {
    String title = '';
    String description = '';
    switch (notificationModel.action) {
      case 'rejected':
        title = 'Publikasi Kampanye "${notificationModel.campaignTitle}" Ditolak';
        description = 'Klik untuk melihat detail terhadap penolakan.';
        break;
      case 'removed':
        title = 'Kampanye "${notificationModel.campaignTitle}" Dinonaktifkan';
        description = 'Klik untuk melihat detail terhadap penonaktifkan.';
        break;
    }

    return InkWell(
      onTap: () async {
        SharedCode.navigatorPush(context, NotificationDetailPage(notificationModel: notificationModel, currentUser: widget.currentUser));
        if (!notificationModel.isRead) await _refreshPage();
      },
      child: Container(
        width: 100.w,
        padding: const EdgeInsets.all(15.0),
        color: !notificationModel.isRead ? Theme.of(context).primaryColor.withOpacity(0.15) : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            SharedCode.dateFormat.format(notificationModel.createdAt),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6.0),
          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
        ]),
      ),
    );
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
