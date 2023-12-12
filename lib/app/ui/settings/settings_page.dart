import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/ui/change_password_page/change_password.dart';
import 'package:lestari_flutter/app/ui/login/login_page.dart';
import 'package:lestari_flutter/app/ui/policy/policy.dart';

import '../change_email/change_email_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Pengaturan'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: Column(children: [
          if (FirebaseAuth.instance.currentUser?.providerData.first.providerId == 'password') _buildMenu(Icons.mail_rounded, 'Ubah Email', 'Ubah alamat email akun Anda.', () {
            SharedCode.navigatorPush(context, const ChangeEmailPage());
          }),
          if (FirebaseAuth.instance.currentUser?.providerData.first.providerId == 'password') _buildMenu(Icons.lock_rounded, 'Ubah Password', 'Ubah password akun Anda.', () {
            SharedCode.navigatorPush(context, const ChangePasswordPage());
          }),
          _buildMenu(Icons.policy_rounded, 'Syarat dan Ketentuan', 'Baca syarat dan ketentuan Lestari.', () {
            SharedCode.navigatorPush(context, const PolicyPage());
          }),
          _buildMenu(Icons.logout_rounded, 'Keluar', 'Logout akun Anda dari aplikasi.', () async {
            SharedCode.showAlertDialog(context, 'Konfirmasi', 'Apakah kamu yakin ingin keluar dari Lestari?', 'Ya', () async {
              await SharedCode.logout();
              SharedCode.navigatorReplace(context, const LoginPage());
            });
          }),
        ]),
      ),
    );
  }

  Widget _buildMenu(IconData iconData, String title, String description, Function() onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(children: [
              Icon(iconData, size: 24.0, color: title == 'Keluar' ? ColorValues.universityRed : ColorValues.grey),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: title == 'Keluar' ? ColorValues.universityRed : ColorValues.onyx)),
                  Text(description, style: GoogleFonts.poppins(fontSize: 14, color: title == 'Keluar' ? ColorValues.universityRed : ColorValues.grey, height: 1.3)),
                ]),
              ),
            ]),
          ),
        ),
        const Divider(color: ColorValues.lightGrey),
      ],
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
