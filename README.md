# Todo Cat <img src="readme_assets/imgs/logo-light-rounded.png" alt="Image Description" width="25" height="25" />

## Download form Microsoft Store

<a href="https://apps.microsoft.com/detail/9N52RL6BKRFX?referrer=appbadge&mode=direct">
	<img src="https://get.microsoft.com/images/en-us%20dark.svg" width="200"/>
</a>

### Desktop

![Dark theme][home-dark-screenshot]
![Light theme][home-screenshot]

## Mobile
![screenshot-phone][screenshot-phone]

## Attention

- ### 1、Please run the command to generate the hive and freed template file before running it

```bash
flutter packages pub run build_runner build
```

- ### 2、Before running the project, please run the command to generate mobile and web flash pages

```bash
dart run flutter_native_splash:create
```

## Run app

```bash
flutter run -d windows
flutter run -d android
flutter run -d macos
flutter run -d linux
```

[home-screenshot]: readme_assets/imgs/home.png
[home-dark-screenshot]: readme_assets/imgs/home-dark.png
[screenshot-phone]: readme_assets/imgs/home-phone.png

## Build app

```bash
# Windows desktop (MSIX):
flutter pub run msix:create
# or
dart run msix:create

# Windows desktop (EXE):
dart pub global activate fastforge # install fastforge
fastforge package --platform windows --targets exe # start build

...more platforms will be supported later...
```
