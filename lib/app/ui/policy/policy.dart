import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lestari_flutter/app/common/color_values.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({Key? key}) : super(key: key);

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Syarat dan Ketentuan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 20.0),
        child: Text(
          'Mohon untuk membaca Syarat dan Ketentuan Penggunaan yang tertulis di bawah ini dengan seksama sebelum mengakses aplikasi Lestari dan/atau menggunakan layanan dari Lestari. Bahwa dengan menggunakan platform kami, Anda menyatakan telah membaca, memahami dengan seksama, dan menyetujui untuk terikat dengan Syarat dan Ketentuan Penggunaan ini ("Syarat dan Ketentuan"), serta menjamin bahwa Anda adalah individu yang secara hukum berhak untuk mengadakan perjanjian yang mengikat berdasarkan hukum Negara Republik Indonesia dan bahwa Anda telah berusia minimal 13 tahun. Atau apabila Anda berusia di bawah 13 tahun, Anda telah mendapatkan izin dari orang tua atau wali Anda. Dengan begitu, Syarat dan Ketentuan ini merupakan suatu perjanjian yang sah antara Anda dan Lestari dan afiliasinya. Dengan tetap mengakses platform dan/atau menggunakan layanan Lestari, Anda telah setuju untuk terikat pada syarat dan ketentuan ini.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
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
