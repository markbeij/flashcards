import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../l10n/app_localizations.dart';
import '../../render/fonts.dart';
import '../../render/test_sheet.dart';

/// Spike 0: shows the test sheet and prints it through AirPrint or shares it,
/// so print fidelity can be measured on the real printer.
class PrintTestScreen extends StatelessWidget {
  const PrintTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: CupertinoNavigationBar(middle: Text(l10n.printTest)),
      body: PdfPreview(
        // The sheet is always A4, whatever page format the print dialog offers.
        build: (_) async => buildTestSheet(
          await loadCardTheme(),
          frontTitle: l10n.testSheetFrontTitle,
          backTitle: l10n.testSheetBackTitle,
        ),
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'test-sheet.pdf',
      ),
    );
  }
}
