import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Size minWindowSize = const Size(1280, 720);
Size windowSize = const Size(1400, 900);

WindowOptions winOptions = WindowOptions(
  center: true,
  size: windowSize,
  minimumSize: minWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

WindowOptions macosOptions = WindowOptions(
  center: true,
  size: windowSize,
  minimumSize: minWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

WindowOptions linuxOptions = WindowOptions(
  center: true,
  size: windowSize,
  minimumSize: minWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

WindowOptions getOptions() {
  if (Platform.isMacOS) return macosOptions;
  if (Platform.isLinux) return linuxOptions;

  return winOptions;
}
