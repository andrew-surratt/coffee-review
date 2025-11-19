# Coffee Review

Multi-platform app to help you choose your next brew

## Stack

* Flutter/Dart
* Firebase

## Install

1. (One-time) [Install Flutter/Dart SDK](https://docs.flutter.dev/get-started/install)
2. (One-time) [Install Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli)
3. `flutter pub get`: Install Flutter project dependencies
4. `firebase login`: Login to firebase CLI
5. (One-time) `dart pub global activate flutterfire_cli`: Install flutterfire CLI
6. `flutterfire configure`: Setup Firebase config

[Reference for firebase configuration](https://firebase.google.com/docs/flutter/setup)

## Usage

`flutter run`

## Updating App Icons

See [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) documentation

## Build

`flutter build [package type]`

## Release

`firebase appdistribution:distribute [app location] --app [app id] --release-notes "[release notes]" --testers "[tester emails]"`
