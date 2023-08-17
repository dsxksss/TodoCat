import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Size minWindowSize = const Size(1280, 720);

WindowOptions windowOptions = WindowOptions(
  size: minWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);
