import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/models/onboard_model.dart';
import 'package:lestari_flutter/app/ui/login/login_page.dart';
import 'package:lestari_flutter/app/ui/register/register_page.dart';
import 'package:sizer/sizer.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
 final List<OnboardModel> _onboardContent = [
   OnboardModel(image: 'assets/onboard_1.png', title: 'Kenali Hewan Endemik Langka Indonesia', description: 'Ragam informasi menarik tentang hewan endemik langka Indonesia.'),
   OnboardModel(image: 'assets/onboard_2.png', title: 'Lihat Hewan dengan Augmented Reality', description: 'Melihat hewan dalam bentuk 3D melalui kameramu dalam bentuk AR.'),
   OnboardModel(image: 'assets/onboard_3.png', title: 'Temukan Kampanye Konservasi di Sekitarmu', description: 'Berpartisipasi dalam kampanye konservasi di sekitar atau membuat kampanye sendiri.')
 ];
 final ValueNotifier<int> _pageIndex = ValueNotifier<int>(0);
 late PageController _pageController;

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
      _pageController.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _buildPageView()),
          Padding(padding: const EdgeInsets.symmetric(vertical: 25.0), child: _buildPageIndicator()),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: _buildActions(),
          )
        ]
      ),
    );
  }

  Widget _buildPageView() {
   return PageView.builder(
     itemBuilder: (context, index) => _buildOnboard(_onboardContent[index]),
     itemCount: _onboardContent.length,
     controller: _pageController,
     onPageChanged: (index) {
       _pageIndex.value = index;
     },
   );
  }

  Widget _buildOnboard(OnboardModel onboardModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Image.asset(onboardModel.image, height: onboardModel.title.contains('Kampanye') ? 55.h : 60.h,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                    onboardModel.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 8,),
                Expanded(child: Text(onboardModel.description, textAlign: TextAlign.center,)),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPageIndicator() {
   return ValueListenableBuilder(
     valueListenable: _pageIndex,
     builder: (_, __, ___) {
       return Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           ...List.generate(_onboardContent.length, (index) => Padding(
             padding: const EdgeInsets.symmetric(horizontal: 4.0),
             child: _buildDotIndicator(_pageIndex.value == index),
           ))
         ]
       );
     }
   );
  }

  Widget _buildDotIndicator(bool isActive) {
    return Container(
      width: 35.0,
      height: 8.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? ColorValues.accentGreen : ColorValues.lightGrey),
    );
  }

  Widget _buildActions() {
    return ValueListenableBuilder(
      valueListenable: _pageIndex,
      builder: (_, __, ___) {
        return _pageIndex.value == 2
          ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  SharedCode.navigatorReplace(context, const RegisterPage());
                },
                child: const Text('Gabung Sekarang')
              ),
              const SizedBox(height: 15.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: 'Sudah punya akun? ',
                    style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 14),
                    children: [
                      TextSpan(
                          text: 'Masuk',
                          style: GoogleFonts.poppins(color: ColorValues.accentGreen, fontSize: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              SharedCode.navigatorReplace(context, const LoginPage());
                            })
                    ]),
              ),
            ],
          )
          : Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _pageController.animateToPage(2, duration: const Duration(seconds: 1), curve: Curves.ease);
                });
              },
              style: TextButton.styleFrom(foregroundColor: ColorValues.grey),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lewati'),
                  SizedBox(width: 2.0),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          );
        }
    );
  }
}
