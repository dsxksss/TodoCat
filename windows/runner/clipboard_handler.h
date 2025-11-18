#ifndef RUNNER_CLIPBOARD_HANDLER_H_
#define RUNNER_CLIPBOARD_HANDLER_H_

#include <flutter/flutter_engine.h>

class ClipboardHandler {
 public:
  static void Register(flutter::FlutterEngine* engine);
};

#endif  // RUNNER_CLIPBOARD_HANDLER_H_

