import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/utils/appbar/appbar_viewmodel.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => AppbarViewModel(),
      builder: (context, viewModel, child) {
        return AppBar(
            backgroundColor: Colors.black87,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "ZubiZubi",
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ));
      },
    );
  }
}
