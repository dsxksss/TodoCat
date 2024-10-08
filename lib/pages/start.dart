import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    goHomePage();
    super.initState();
  }

  void goHomePage() async {
    await 1.delay();
    Get.offAllNamed("/");
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imgs/logo-light-rounded.png',
                width: 250,
                height: 250,
                filterQuality: FilterQuality.medium,
              ),
              Text(
                "Todo Cat",
                style: GoogleFonts.getFont(
                  'Ubuntu',
                  textStyle: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ).animate().fade(duration: 800.ms, curve: Curves.easeInSine),
    );
  }
}
