import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/blocs/auth/auth_bloc.dart';
import 'package:lestari_flutter/app/common/color_values.dart';
import 'package:lestari_flutter/app/common/shared_code.dart';
import 'package:lestari_flutter/app/repositories/repositories.dart';
import 'package:lestari_flutter/app/ui/dashboard/dashboard_page.dart';
import 'package:lestari_flutter/app/ui/register/register_page.dart';
import 'package:lestari_flutter/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                    SchedulerBinding.instance.addPostFrameCallback((_) {
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
        Center(
          child: Image.asset('assets/login.png', width: 80.w, height: 40.h, fit: BoxFit.contain),
        ),
        Text(
            'Selamat Datang',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 8.0),
        Text('Masukkan akun Anda untuk melanjutkan.', style: GoogleFonts.poppins(fontSize: 14)),
        const SizedBox(height: 15.0),
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
        const SizedBox(height: 30.0),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 15.0),
        //     child: GestureDetector(
        //       onTap: () {
        //         SharedCode.navigatorPush(context, const ForgotPasswordInputPage());
        //       },
        //       child: Text('Lupa Password?', style: GoogleFonts.poppins(color: ColorValues.accentGreen, fontSize: 10)),
        //     ),
        //   ),
        // ),
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(_context).add(LoginWithPasswordEvent(_emailController.text, _passwordController.text));
            },
            child: const Text('Masuk')
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
            BlocProvider.of<AuthBloc>(_context).add(const AuthWithGoogleEvent(true));
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon_google.png', width: 24.0),
                const SizedBox(width: 10.0),
                Text('Masuk dengan Google', style: GoogleFonts.poppins(color: ColorValues.grey)),
              ]
          ),
        ),
        const SizedBox(height: 15.0),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'Belum punya akun? ',
                style: GoogleFonts.poppins(color: ColorValues.onyx, fontSize: 14),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Daftar',
                      style: GoogleFonts.poppins(color: ColorValues.accentGreen, fontSize: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          SharedCode.navigatorReplace(context, const RegisterPage());
                        })
                ]),
          ),
        ),
      ],
    );
  }
}
