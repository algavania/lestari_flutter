import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel userModel;
  const EditProfilePage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ValueNotifier<XFile> _selectedImage = ValueNotifier(XFile(''));
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _nameController.text = widget.userModel.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Ubah Profil'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: Column(children: [
          _buildPicture(),
          const SizedBox(height: 30.0),
          CustomTextField(labelText: 'Nama', controller: _nameController, isRequired: true),
        ]),
      ),
      bottomNavigationBar: _buildBottomWidget(),
    );
  }

  Widget _buildPicture() {
    return Center(
      child: Stack(children: [
        ValueListenableBuilder(
          valueListenable: _selectedImage,
          builder: (_, __, ___) {
            return _selectedImage.value.path == ''
            ? Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  image: DecorationImage(
                    image: NetworkImage(widget.userModel.imageUrl),
                    fit: BoxFit.cover,
                  )
              ),
            )
            : Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  image: DecorationImage(
                    image: FileImage(File(_selectedImage.value.path)),
                    fit: BoxFit.cover,
                  )
              ),
            );
          }
        ),
        InkWell(
          onTap: () async {
            _selectedImage.value = await _picker.pickImage(source: ImageSource.gallery) ?? XFile('');
          },
          child: Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: ColorValues.onyx.withOpacity(0.5)
            ),
            child: const Center(child: Icon(Icons.edit_rounded, color: Colors.white, size: 26.0)),
          ),
        ),
      ]),
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
          context.loaderOverlay.show();
          await UserRepository().updateProfile(_nameController.text, widget.userModel.imageUrl, File(_selectedImage.value.path));
          context.loaderOverlay.hide();
          SharedCode.showSnackBar(context, true, 'Profil berhasil diperbarui.');
          Navigator.of(context).pop();
        },
        child: const Text('Simpan'),
      ),
    );
  }
}
