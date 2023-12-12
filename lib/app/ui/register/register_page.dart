import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/blocs/auth/auth_bloc.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/app/ui/dashboard/dashboard_page.dart';
import 'package:lestari_flutter/app/ui/login/login_page.dart';
import 'package:lestari_flutter/app/ui/policy/policy.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPolicyChecked = false;
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(AuthRepository()),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: SharedCode.altPagePadding,
            child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  _context = context;
                  if (state is AuthLoading) {
                    context.loaderOverlay.show();
                    return _buildContent();
                  }
                  if (state is AuthInitial) {
                    context.loaderOverlay.hide();
                    return _buildContent();
                  }
                  if (state is AuthError) {
                    context.loaderOverlay.hide();
                    Future.delayed(Duration.zero, () {
                      SharedCode.showSnackBar(context, false, state.message);
                    });
                    return _buildContent();
                  }
                  if (state is AuthLoaded) {
                    context.loaderOverlay.hide();
                    Future.delayed(Duration.zero, () {
                      SharedCode.navigatorReplace(context, const DashboardPage());
                    });
                    return _buildContent();
                  }
                  return Container();
                }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Daftar Sekarang',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 8.0),
        Text('Daftar dan mulai pelajari hewan-hewan Nusantara.', style: GoogleFonts.poppins(fontSize: 14)),
        const SizedBox(height: 15.0),
        CustomTextField(
          hintText: 'Nama*',
          isRequired: true,
          controller: _nameController,
        ),
        const SizedBox(height: 10.0),
        CustomTextField(
          hintText: 'Email*',
          isRequired: true,
          controller: _emailController,
          textInputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10.0),
        CustomTextField(
          hintText: 'Password*',
          isRequired: true,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 10.0),
        CustomTextField(
          hintText: 'Ketik Ulang Password*',
          isRequired: true,
          isPassword: true,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 20.0),
        Row(children: [
          SizedBox(
            width: 18.0,
            height: 18.0,
            child: Checkbox(
              value: _isPolicyChecked,
              onChanged: (v) => setState(() {
                _isPolicyChecked = !_isPolicyChecked;
              })
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: RichText(
              text: TextSpan(
                  text: 'Dengan mendaftar, Anda menyetujui',
                  style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                        text: ' Syarat dan Ketentuan ',
                        style: GoogleFonts.poppins(color: ColorValues.accentGreen, fontSize: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            SharedCode.navigatorPush(context, const PolicyPage());
                          }),
                    TextSpan(
                      text: 'Lestari',
                      style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 14),
                    ),
                  ]),
            ),
          ),
        ]),
        const SizedBox(height: 25.0),
        ElevatedButton(
            onPressed: () {
              if (_isPolicyChecked) {
                if (_passwordController.text == _confirmPasswordController.text) {
                  BlocProvider.of<AuthBloc>(_context).add(RegisterWithPasswordEvent(_emailController.text, _passwordController.text, _nameController.text));
                } else {
                  SharedCode.showSnackBar(context, false, 'Password tidak sama.');
                }
              } else {
                SharedCode.showSnackBar(context, false, 'Anda belum menyetujui syarat dan ketentuan.');
              }
            },
            child: const Text('Daftar')
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(children: [
            Expanded(child: Container(width: MediaQuery.of(context).size.width, height: 1, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text('Atau', style: GoogleFonts.poppins(color: ColorValues.grey, fontSize: 10)),
            ),
            Expanded(child: Container(width: MediaQuery.of(context).size.width, height: 1, color: Colors.grey)),
          ]),
        ),
        OutlinedButton(
          onPressed: () {
            BlocProvider.of<AuthBloc>(_context).add(const AuthWithGoogleEvent(false));
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon_google.png', width: 24.0),
                const SizedBox(width: 10.0),
                Text('Daftar dengan Google', style: GoogleFonts.poppins(color: ColorValues.grey)),
              ]
          ),
        ),
        const SizedBox(height: 15.0),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'Sudah punya akun? ',
                style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 14),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Masuk',
                      style: GoogleFonts.poppins(color: ColorValues.accentGreen, fontSize: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          SharedCode.navigatorReplace(context, const LoginPage());
                        })
                ]),
          ),
        ),
      ],
    );
  }
}
