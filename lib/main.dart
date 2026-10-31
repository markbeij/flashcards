import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/store/library_notifier.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_gentiumLicense);
  final (container, _) = await openLibrary();
  runApp(UncontrolledProviderScope(container: container, child: const FlashcardsApp()));
}

Stream<LicenseEntry> _gentiumLicense() async* {
  final text = await rootBundle.loadString('assets/fonts/gentium/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Gentium Book Plus'], text);
}
