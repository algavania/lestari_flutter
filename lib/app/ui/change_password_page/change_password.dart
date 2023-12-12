import 'package:flutter/material.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Ubah Password'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: Form(
          key: _formKey,
          child: Column(children: [
            CustomTextField(controller: _passwordController, validator: SharedCode().emptyValidator, labelText: 'Password Akun Saat Ini', isRequired: true, isPassword: true),
            const SizedBox(height: 25.0),
            CustomTextField(controller: _newPasswordController, validator: SharedCode().emptyValidator, labelText: 'Password Baru', isRequired: true, isPassword: true),
            const SizedBox(height: 25.0),
            CustomTextField(controller: _confirmNewPasswordController, validator: SharedCode().emptyValidator, labelText: 'Ketik Ulang Password Baru', isRequired: true, isPassword: true),
          ]),
        ),
      ),
      bottomNavigationBar: _buildBottomWidget(),
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

  Widget _buildBottomWidget() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(color:Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ]),
      child: ElevatedButton(
        onPressed: () async {
          String currentPassword = _passwordController.text;
          String newPassword = _newPasswordController.text;
          String confirmPassword = _confirmNewPasswordController.text;
          if (_formKey.currentState?.validate() ?? true) {
            if (newPassword != confirmPassword) {
              SharedCode.showSnackBar(context, false, 'Password tidak sama');
            } else {
              context.loaderOverlay.show();
              try {
                await AuthRepository().changePassword(currentPassword, newPassword);
                Future.delayed(Duration.zero, () {
                  SharedCode.showSnackBar(context, true, 'Password berhasil diubah');
                  Navigator.pop(context);
                });
              } catch (e) {
                String error = e.toString();
                error = error.substring(error.indexOf(']')+2, error.length);
                SharedCode.showSnackBar(context, false, error);
              }
              context.loaderOverlay.hide();
            }
          }
        },
        child: const Text('Simpan'),
      ),
    );
  }
}
