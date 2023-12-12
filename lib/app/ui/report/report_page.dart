import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/models/report_model.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';

class ReportPage extends StatefulWidget {
  final String type, id, title;

  const ReportPage({Key? key, required this.type, required this.id, required this.title}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<String> _animalReasons = [
    'Pilih alasan',
    'Misinformasi',
    'Status hewan bukan tergolong langka',
    'Hewan bukan dari Indonesia'
  ];
  final List<String> _campaignReasons = [
    'Pilih alasan',
    'Kampanye tidak berkaitan dengan konservasi hewan',
    'Kampanye menyinggung SARA',
    'Kampanye fiktif'
  ];
  final List<String> _articleReasons = [
    'Pililh alasan',
    'Misinformasi',
    'Artikel menyinggung SARA',
    'Artikel fiktif'
  ];
  List<String> _reasonValues = [];
  late String _selectedReason;
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    switch (widget.type) {
      case 'animals':
        _selectedReason = _animalReasons[0];
        _reasonValues = _animalReasons;
        break;
      case 'campaigns':
        _selectedReason = _campaignReasons[0];
        _reasonValues = _campaignReasons;
        break;
      case 'articles':
        _selectedReason = _articleReasons[0];
        _reasonValues = _articleReasons;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildReasonField(),
          const SizedBox(height: 25.0),
          _buildDescriptionField(),
          const SizedBox(height: 25.0),
          _buildImageField(),
        ]),
      ),
      bottomNavigationBar: _buildBottomWidget(),
    );
  }

  Future<TaskSnapshot> _uploadImage(String id, XFile? image) async {
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('reports/$id/${DateTime.now().toIso8601String()}.png');
    late UploadTask uploadTask;
    if (kIsWeb) {
      var bytes = await image!.readAsBytes();
      uploadTask = firebaseStorageRef.putData(
          bytes, SettableMetadata(contentType: 'image/png'));
    } else {
      uploadTask = firebaseStorageRef.putFile(File(image!.path));
    }
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot;
  }

  Future<void> _uploadToFirebase() async {
    context.loaderOverlay.show();
    ReportModel reportModel;
    try {
      reportModel = ReportModel(
          id: '',
          createdAt: DateTime.now(),
          objectId: widget.id,
          category: widget.type.toLowerCase(),
          subject: _selectedReason,
          description: _controller.text,
          isOpenIssue: true,
          title: widget.title,
          imageUrls: []);
      DocumentReference reference = await ReportsRepository().addReport(reportModel);
      reportModel.id = reference.id;

      if (_images.isNotEmpty) {
        List<String> urls = [];
        for (var image in _images) {
          TaskSnapshot snapshot = await _uploadImage(reportModel.id, image);
          String url = await snapshot.ref.getDownloadURL();
          urls.add(url);
        }
        reportModel.imageUrls = urls;

        await ReportsRepository().updateReport(reportModel);
      }
      Future.delayed(Duration.zero, () {
        context.loaderOverlay.hide();
        SharedCode.showSnackBar(context, true, 'Laporan terkirim');
        Navigator.pop(context);
      });
    } catch (e) {
      SharedCode.showSnackBar(context, false, e.toString());
    }
    context.loaderOverlay.hide();
  }


  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFileList = await _picker.pickMultiImage();
      if (pickedFileList.length > 5) {
        SharedCode.showSnackBar(context, false, 'Gambar maksimal 5');
      } else {
        setState(() {
          _images = pickedFileList;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _buildBottomWidget() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ]),
      child: ElevatedButton(
        onPressed: () {
          if (_selectedReason != _animalReasons.first && _controller.text.trim().isNotEmpty) {
            _uploadToFirebase();
          } else {
            SharedCode.showSnackBar(context, false, 'Field tidak boleh kosong');
          }
        },
        child: const Text('Kirim Laporan'),
      ),
    );
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Gambar',
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          height: 20.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (_, i) {
              return (i == 0)
                  ? InkWell(
                onTap: () {
                  _pickImages();
                },
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                      border: Border.all(
                          style: BorderStyle.solid,
                          width: 1.0,
                          color: ColorValues.grey.withOpacity(0.75)),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_upload_outlined,
                            color: ColorValues.grey.withOpacity(0.75)),
                        const SizedBox(height: 1.0),
                        Text('Unggah',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: ColorValues.grey.withOpacity(0.75),
                                fontWeight: FontWeight.w500))
                      ]),
                ),
              )
                  : SizedBox(
                width: 20.w,
                height: 20.w,
                child: Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.file(
                          File(_images[i - 1].path),
                          fit: BoxFit.cover,
                          width: 20.w,
                          height: 20.w,
                        )),
                    Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(i - 1);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(3.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.red),
                            child: const Icon(Icons.delete,
                                color: Colors.white, size: 12.0),
                          ),
                        )),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10.0),
            itemCount: _images.length + 1,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alasan*',
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5.0),
        InputDecorator(
          decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 10.0),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: ColorValues.lightGrey),
                  borderRadius: BorderRadius.circular(7.0))
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                style: GoogleFonts.poppins(fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.onyx),
                value: _selectedReason,
                isDense: true,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 20.0),
                onChanged: (String? value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
                items: _reasonValues.map<DropdownMenuItem<String>>((
                    String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Deskripsi*',
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 5.0),
      CustomTextField(controller: _controller, isRequired: true, minLines: 5, maxLines: 10),
    ]);
  }

  AppBar _buildAppBar() {
    String title = 'Laporkan Hewan';
    if (widget.type == 'Campaign') title = 'Laporkan Kampanye';
    if (widget.type == 'Article') title = 'Laporkan Artikel';

    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(
            Icons.arrow_back_ios, size: 20.0, color: ColorValues.grey),
      ),
      elevation: 0,
    );
  }
}
