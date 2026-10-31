import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_gentiumLicense);
  runApp(const ProviderScope(child: FlashcardsApp()));
}

Stream<LicenseEntry> _gentiumLicense() async* {
  final text = await rootBundle.loadString('assets/fonts/gentium/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Gentium Book Plus'], text);
}
