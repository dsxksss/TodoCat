import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const Size minWindowSize = Size(1280, 720);
const Size maxWindowSize = Size(1920, 1080);
const Size windowSize = Size(1400, 900);
const Size winWindowSize = Size(1400, 800);

WindowOptions winOptions = const WindowOptions(
  center: true,
  size: winWindowSize,
  minimumSize: minWindowSize,
  maximumSize: maxWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

WindowOptions macosOptions = const WindowOptions(
  center: true,
  size: windowSize,
  minimumSize: minWindowSize,
  maximumSize: maxWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

WindowOptions linuxOptions = const WindowOptions(
  center: true,
  size: windowSize,
  minimumSize: minWindowSize,
  maximumSize: maxWindowSize,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

WindowOptions getOptions() {
  if (Platform.isMacOS) return macosOptions;
  if (Platform.isLinux) return linuxOptions;

  return winOptions;
}
