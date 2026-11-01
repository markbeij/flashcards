import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../l10n/app_localizations.dart';
import 'illustrations.dart';
import 'print_preview_screen.dart';

/// For a printer without duplex: print the fronts, turn the stack over,
/// then print the backs.
Future<void> showManualDuplex(
  BuildContext context, {
  required Future<Uint8List> Function() fronts,
  required Future<Uint8List> Function() backs,
}) => showCupertinoSheet<void>(
  context: context,
  scrollableBuilder: (context, controller) =>
      _ManualDuplex(fronts: fronts, backs: backs, controller: controller),
);

class _ManualDuplex extends StatelessWidget {
  _ManualDuplex({
    required this.fronts,
    required this.backs,
    required this.controller,
  });

  final Future<Uint8List> Function() fronts;
  final Future<Uint8List> Function() backs;
  final ScrollController controller;
  final _shareFronts = GlobalKey();
  final _shareBacks = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Future<void> print(Future<Uint8List> Function() build, String name) async {
      final bytes = await build();
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: name,
        format: PdfPageFormat.a4,
      );
    }

    Future<void> share(
      Future<Uint8List> Function() build,
      String name,
      GlobalKey key,
    ) async {
      final bytes = await build();
      await Printing.sharePdf(
        bytes: bytes,
        filename: '$name.pdf',
        bounds: shareBounds(key),
      );
    }

    Widget step(
      String title,
      Future<Uint8List> Function() build,
      String name,
      GlobalKey key,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        CupertinoButton.filled(
          onPressed: () => print(build, name),
          child: Text(l10n.print),
        ),
        CupertinoButton(
          key: key,
          onPressed: () => share(build, name, key),
          child: Text(l10n.shareFile('$name.pdf')),
        ),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(l10n.noDuplex),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.done),
        ),
      ),
      child: SafeArea(
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            step(
              l10n.manualStepFronts,
              fronts,
              l10n.frontsFileName,
              _shareFronts,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.manualStepTurn,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Center(child: FlipIllustration()),
            const SizedBox(height: 8),
            Text(l10n.manualStepTurnHint),
            const SizedBox(height: 24),
            step(l10n.manualStepBacks, backs, l10n.backsFileName, _shareBacks),
          ],
        ),
      ),
    );
  }
}
