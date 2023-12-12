import 'package:flutter/material.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../repositories/repositories.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Ubah Email'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: Form(
          key: _formKey,
          child: Column(children: [
            CustomTextField(controller: _emailController, validator: SharedCode().emptyValidator, labelText: 'Email Baru', isRequired: true, textInputType: TextInputType.emailAddress),
            const SizedBox(height: 25.0),
            CustomTextField(controller: _passwordController, validator: SharedCode().emptyValidator, labelText: 'Password Akun Anda', isRequired: true, isPassword: true,),
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
          String newEmail = _emailController.text;
          if (_formKey.currentState?.validate() ?? true) {
            context.loaderOverlay.show();
            try {
              await AuthRepository().changeEmail(currentPassword, newEmail);
              Future.delayed(Duration.zero, () {
                SharedCode.showSnackBar(context, true, 'Email berhasil diubah');
                Navigator.pop(context);
              });
            } catch (e) {
              String error = e.toString();
              error = error.substring(error.indexOf(']')+2, error.length);
              SharedCode.showSnackBar(context, false, error);
            }
            context.loaderOverlay.hide();
          }

        },
        child: const Text('Simpan'),
      ),
    );
  }
}
