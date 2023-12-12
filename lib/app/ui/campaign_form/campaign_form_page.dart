import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/app/ui/campaign_form/campaign_created_page.dart';
import 'package:lestari_flutter/models/campaign_model.dart';
import 'package:lestari_flutter/models/city_model.dart';
import 'package:lestari_flutter/models/province_model.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

class CampaignFormPage extends StatefulWidget {
  const CampaignFormPage({Key? key}) : super(key: key);

  @override
  State<CampaignFormPage> createState() => _CampaignFormPageState();
}

class _CampaignFormPageState extends State<CampaignFormPage> {
  final List<String> _categoryValues = <String>[
    'Pilih kategori',
    'Aksi',
    'Donasi',
    'Sosialisasi',
    'Lainnya'
  ];
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<bool> _isOnsite = ValueNotifier<bool>(true);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();
  List<XFile> _images = [];
  String _selectedCategory = 'Pilih kategori';
  DateTime _selectedDate = DateTime.now();
  late CampaignModel _campaignModel;
  final List<City> _cities = [], _allCities = [];
  final List<Province> _provinces = [];
  bool _isLoading = true;
  City? _selectedCity;
  Province? _selectedProvince;
  final _formKey = GlobalKey<FormState>();
  int _key = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    _dateController.text = 'Pilih tanggal';
    _provinceController.text = 'Pilih provinsi';
    _cityController.text = 'Pilih kota/kabupaten';
  }

  Future<void> _getData() async {
    Future.delayed(Duration.zero, () {
      context.loaderOverlay.show();
    });
    await _getProvinces();
    await _getCities();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _isLoading = false;
    }
    Future.delayed(Duration.zero, () {
      context.loaderOverlay.hide();
    });
  }

  Future<void> _getCities() async {
    String data = await rootBundle.loadString("assets/cities.json");
    CityModel model = cityModelFromJson(data);
    _allCities.addAll(model.results);
  }

  Future<void> _getProvinces() async {
    String data = await rootBundle.loadString("assets/provinces.json");
    ProvinceModel model = provinceModelFromJson(data);
    _provinces.addAll(model.results);
  }

  void _getCitiesByProvinceId(String provinceId) {
    setState(() {
      _cities.clear();
      _cities.addAll(
          _allCities.where((element) => element.provinceId == provinceId));
      _selectedCity = null;
      _key++;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Tambah Kampanye Baru'),
      body: SingleChildScrollView(
        padding: SharedCode.defaultPagePadding,
        child: _isLoading ? Container() : _buildForm(),
      ),
      bottomNavigationBar: _buildBottomWidget(),
    );
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTextField('Judul Kampanye', _titleController,
              hintText: 'Gerakan Perlindungan Hewan',
              validator: SharedCode().emptyValidator),
          const SizedBox(height: 15.0),
          _buildImageField(),
          const SizedBox(height: 15.0),
          _buildCategoryField(),
          const SizedBox(height: 15.0),
          _buildDatePicker(),
          const SizedBox(height: 15.0),
          _buildLocationRadio(),
          const SizedBox(height: 10.0),
          _buildOnsiteLocation(),
          _buildTextField('Deskripsi Singkat', _descriptionController,
              isMultiline: true,
              hintText: 'Kampanye kami merupakan ...',
              validator: SharedCode().emptyValidator),
          const SizedBox(height: 15.0),
          _buildTextField('Link Resmi Situs Kampanye', _urlController,
              hintText: 'https://www.situsresmi.com/',
              validator: SharedCode().urlValidator),
        ]));
  }

  Widget _buildOnsiteLocation() {
    return ValueListenableBuilder(
        valueListenable: _isOnsite,
        builder: (_, __, ___) {
          return _isOnsite.value
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLocationField('Provinsi Lokasi', true),
                  const SizedBox(height: 15.0),
                  _buildLocationField('Kota/Kabupaten Lokasi', false),
                  const SizedBox(height: 15.0),
                ])
              : const SizedBox.shrink();
        });
  }

  Widget _buildLocationRadio() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Teknik Pelaksanaan*',
        style:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 5.0),
      ValueListenableBuilder(
          valueListenable: _isOnsite,
          builder: (_, __, ___) {
            return Row(
              children: [
                Radio(
                  value: true,
                  groupValue: _isOnsite.value,
                  onChanged: (v) {
                    _isOnsite.value = v!;
                  },
                ),
                const Expanded(child: Text('Onsite')),
                Radio(
                  value: false,
                  groupValue: _isOnsite.value,
                  onChanged: (v) {
                    _isOnsite.value = v!;
                  },
                ),
                const Expanded(child: Text('Online')),
              ],
            );
          })
    ]);
  }

  Widget _buildLocationField(String labelText, bool isProvince) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        '$labelText*',
        style:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 5.0),
      isProvince
          ? DropdownSearch<Province>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                    decoration: _getDecoration(
                        isDense: false,
                        hintText: 'Cari provinsi ...',
                        hintTextColor: Colors.grey.shade400)),
                searchDelay: Duration.zero,
              ),
              items: _provinces,
              itemAsString: (Province model) => model.province,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration:
                    _getDecoration(hintText: 'Pilih provinsi'),
              ),
              onChanged: (s) {
                _selectedProvince = s;
                if (s != null) {
                  _getCitiesByProvinceId(s.provinceId);
                }
              },
              selectedItem: _selectedProvince,
            )
          : DropdownSearch<City>(
              key: Key(_key.toString()),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                    decoration: _getDecoration(
                        isDense: false,
                        hintText: 'Cari kota/kabupaten ...',
                        hintTextColor: Colors.grey.shade400)),
                searchDelay: Duration.zero,
              ),
              items: _cities,
              itemAsString: (City model) => model.cityName,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration:
                    _getDecoration(hintText: 'Pilih kota/kabupaten'),
              ),
              onChanged: (s) {
                _selectedCity = s;
              },
              selectedItem: _selectedCity,
            ),
    ]);
  }

  InputDecoration _getDecoration(
      {bool isDense = true,
      String hintText = '',
      Color hintTextColor = Colors.black}) {
    OutlineInputBorder border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
        borderSide: const BorderSide(color: ColorValues.lightGrey));
    return InputDecoration(
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorValues.grey),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: hintTextColor),
        isDense: isDense,
        enabledBorder: border,
        focusedBorder: border,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 25));
  }

  Widget _buildDatePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Tanggal Pelaksanaan*',
        style:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 5.0),
      GestureDetector(
          onTap: () async {
            DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100));
            if (date != null) {
              setState(() {
                _selectedDate = date;
                _dateController.text =
                    SharedCode.dateFormat.format(_selectedDate);
              });
            }
            // DatePicker.showDatePicker(
            //   context,
            //   showTitleActions: true,
            //   minTime: DateTime.now(),
            //   onConfirm: (date) {
            //     setState(() {
            //       _selectedDate = date;
            //       _dateController.text =
            //           SharedCode.dateFormat.format(_selectedDate);
            //     });
            //   },
            //   currentTime: DateTime.now(),
            //   locale: LocaleType.id,
            // );
          },
          child: AbsorbPointer(
              child: CustomTextField(
            isRequired: true,
            controller: _dateController,
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20.0),
          ))),
    ]);
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Kampanye*',
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5.0),
        InputDecorator(
          decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: ColorValues.lightGrey),
                  borderRadius: BorderRadius.circular(7.0))),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.onyx),
                value: _selectedCategory,
                isDense: true,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 20.0),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: _categoryValues
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (_selectedCategory == 'Lainnya')
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: CustomTextField(
                validator: SharedCode().emptyValidator,
                isRequired: true,
                controller: _otherCategoryController,
                textInputType: TextInputType.text,
                hintText: 'Masukkan kategori kampanye'),
          ),
      ],
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {bool isMultiline = false,
      String? hintText,
      String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        '$labelText*',
        style:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 5.0),
      CustomTextField(
          validator: validator,
          isRequired: true,
          controller: controller,
          minLines: isMultiline ? 5 : 1,
          maxLines: isMultiline ? 10 : 1,
          textInputType:
              isMultiline ? TextInputType.multiline : TextInputType.text,
          hintText: hintText),
    ]);
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Poster atau Gambar Kampanye*',
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
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
          String category = _selectedCategory;
          if (category == 'Lainnya') category = _otherCategoryController.text;

          bool isValid = false;
          if (_isOnsite.value) {
            isValid = _selectedCity != null && _selectedProvince != null;
          } else {
            isValid = true;
          }
          if ((_formKey.currentState?.validate() ?? false) &&
              isValid &&
              _images.isNotEmpty &&
              category != 'Pilih kategori' &&
              _dateController.text != 'Pilih tanggal') {
            _uploadToFirebase(category);
          } else {
            SharedCode.showSnackBar(context, false, 'Field tidak boleh kosong');
          }
        },
        child: const Text('Buat Kampanye'),
      ),
    );
  }

  Future<TaskSnapshot> _uploadImage(String id, XFile? image) async {
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('campaigns/$id/${DateTime.now().toIso8601String()}.png');
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

  Future<void> _uploadToFirebase(String category) async {
    context.loaderOverlay.show();
    try {
      _campaignModel = CampaignModel(
          id: '',
          title: _titleController.text,
          organizerId: FirebaseAuth.instance.currentUser?.uid ?? '',
          category: category,
          province: _isOnsite.value ? _selectedProvince!.province : 'Online',
          city: _isOnsite.value ? _selectedCity!.cityName : 'Online',
          imageUrls: [],
          description: _descriptionController.text,
          websiteUrl: _urlController.text,
          date: _selectedDate,
          status: 'waiting');
      DocumentReference reference =
          await CampaignsRepository().addCampaign(_campaignModel);
      _campaignModel.id = reference.id;

      if (_images.isNotEmpty) {
        List<String> urls = [];
        for (var image in _images) {
          TaskSnapshot snapshot = await _uploadImage(_campaignModel.id, image);
          String url = await snapshot.ref.getDownloadURL();
          urls.add(url);
        }
        _campaignModel.imageUrls = urls;

        await CampaignsRepository().updateCampaign(_campaignModel);
      }

      Future.delayed(Duration.zero, () {
        context.loaderOverlay.hide();
        SharedCode.navigatorReplace(context, const CampaignCreatedPage());
      });
    } catch (e) {
      SharedCode.showSnackBar(context, false, e.toString());
    }
    context.loaderOverlay.hide();
  }
}
