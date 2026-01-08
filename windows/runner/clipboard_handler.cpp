#include "clipboard_handler.h"
#include <windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <vector>
#include <memory>

namespace {

// Get clipboard image data
std::vector<uint8_t> GetClipboardImage() {
  std::vector<uint8_t> imageData;
  
  if (!OpenClipboard(nullptr)) {
    return imageData;
  }

  // Try to get DIB format bitmap data
  HANDLE hDib = GetClipboardData(CF_DIB);
  if (hDib != nullptr) {
    void* pDib = GlobalLock(hDib);
    if (pDib != nullptr) {
      BITMAPINFOHEADER* bmpInfoHeader = (BITMAPINFOHEADER*)pDib;
      
      // Calculate color table size (if any)
      int bitCount = bmpInfoHeader->biBitCount;
      int colorTableSize = 0;
      if (bitCount <= 8) {
        int colorCount = bmpInfoHeader->biClrUsed;
        if (colorCount == 0) {
          colorCount = 1 << bitCount;
        }
        colorTableSize = colorCount * sizeof(RGBQUAD);
      }
      
      // Get total size of DIB data
      SIZE_T dibSizeT = GlobalSize(hDib);
      DWORD dibSize = static_cast<DWORD>(dibSizeT);
      
      // Create BMP file
      int fileSize = sizeof(BITMAPFILEHEADER) + dibSize;
      imageData.resize(fileSize);
      
      // Create BMP file header
      BITMAPFILEHEADER bmpFileHeader = {0};
      bmpFileHeader.bfType = 0x4D42; // "BM"
      bmpFileHeader.bfSize = fileSize;
      bmpFileHeader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + colorTableSize;
      
      // Copy file header
      memcpy(imageData.data(), &bmpFileHeader, sizeof(BITMAPFILEHEADER));
      
      // Copy DIB data (including info header, color table and data)
      memcpy(imageData.data() + sizeof(BITMAPFILEHEADER), pDib, dibSize);
      
      GlobalUnlock(hDib);
    }
  }
  
  
  CloseClipboard();
  return imageData;
}

// Check if clipboard has image
bool HasClipboardImage() {
  if (!OpenClipboard(nullptr)) {
    return false;
  }
  // Check for DIB or Bitmap
  bool hasImage = IsClipboardFormatAvailable(CF_DIB) || IsClipboardFormatAvailable(CF_BITMAP);
  CloseClipboard();
  return hasImage;
}

} // namespace

void ClipboardHandler::Register(flutter::FlutterEngine* engine) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(), "com.todocat/clipboard",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getClipboardImage") {
          auto imageData = GetClipboardImage();
          if (imageData.empty()) {
            result->Success(flutter::EncodableValue(nullptr));
          } else {
            result->Success(flutter::EncodableValue(imageData));
          }
        } else if (call.method_name() == "hasImage") {
          result->Success(flutter::EncodableValue(HasClipboardImage()));
        } else {
          result->NotImplemented();
        }
      });
}

