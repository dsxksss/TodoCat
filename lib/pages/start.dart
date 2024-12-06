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
  bool _isLoading = true;
  final _minimumLoadingTime = const Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();

    try {
      // 并行预加载所需资源
      await Future.wait([
        _precacheImages(context),
        _loadFonts(),
      ]);

      // 确保至少显示最小加载时间，以避免闪烁
      final elapsed = stopwatch.elapsed;
      if (elapsed < _minimumLoadingTime) {
        await Future.delayed(_minimumLoadingTime - elapsed);
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    } finally {
      stopwatch.stop();
      if (mounted) {
        setState(() => _isLoading = false);
      }
      Get.offAllNamed("/");
    }
  }

  Future<void> _precacheImages(BuildContext context) async {
    // 预加载图片
    await precacheImage(
      const AssetImage('assets/imgs/logo-light-rounded.png'),
      context,
    );
  }

  Future<void> _loadFonts() async {
    // 预加载字体
    await GoogleFonts.pendingFonts([
      GoogleFonts.ubuntu(
        textStyle: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
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
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ).animate().fade(duration: 800.ms, curve: Curves.easeInSine),
    );
  }
}
