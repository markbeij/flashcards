import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show showLicensePage;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../data/store/library_notifier.dart';
import '../../data/store/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../render/test_sheet.dart';
import '../providers.dart';
import 'calibration_illustration.dart';

/// Calibration, licences and keyboard shortcuts.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _printTestSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final theme = await ref.read(cardThemeProvider.future);
    final bytes = await buildTestSheet(
      theme,
      frontTitle: l10n.testSheetFrontTitle,
      backTitle: l10n.testSheetBackTitle,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: l10n.testSheetFileName,
      format: PdfPageFormat.a4,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final calibration =
        ref.watch(libraryProvider.select((l) => l.settings.calibration)) ??
        const Calibration();

    void setCalibration(Calibration value) {
      final settings = ref.read(libraryProvider).settings;
      ref
          .read(libraryProvider.notifier)
          .updateSettings(settings.copyWith(calibration: value));
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.settings),
        previousPageTitle: l10n.library,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text(l10n.calibration),
              footer: Text(l10n.calibrationHint),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.printer),
                  title: Text(l10n.printTestSheet),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _printTestSheet(context, ref),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CalibrationIllustration()),
                ),
                _OffsetField(
                  label: l10n.backOffsetX,
                  hint: l10n.backOffsetXHint,
                  value: calibration.backDxMm,
                  onChanged: (v) => setCalibration(
                    Calibration(backDxMm: v, backDyMm: calibration.backDyMm),
                  ),
                ),
                _OffsetField(
                  label: l10n.backOffsetY,
                  hint: l10n.backOffsetYHint,
                  value: calibration.backDyMm,
                  onChanged: (v) => setCalibration(
                    Calibration(backDxMm: calibration.backDxMm, backDyMm: v),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.keyboardShortcuts),
              children: [
                for (final (keys, action) in [
                  ('⌘N', l10n.addCards),
                  ('⇧⌘N', l10n.newDeck),
                  ('⌘P', l10n.printEllipsis),
                  ('⌘B / ⌘I', l10n.shortcutBoldItalic),
                  ('⌘↩', l10n.shortcutNextCard),
                  ('⌘⌫', l10n.delete),
                  ('Esc', l10n.done),
                ])
                  CupertinoListTile(
                    title: Text(action),
                    additionalInfo: Text(keys),
                  ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.about),
              children: [
                CupertinoListTile(
                  title: Text(l10n.licences),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A back offset in mm: − and + in 0.5 mm steps, or typed in.
class _OffsetField extends StatefulWidget {
  const _OffsetField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_OffsetField> createState() => _OffsetFieldState();
}

class _OffsetFieldState extends State<_OffsetField> {
  static const _step = 0.5;
  static const _limit = 10.0;
  late final _controller = TextEditingController(text: _format(widget.value));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _submit(_controller.text);
    });
  }

  @override
  void didUpdateWidget(_OffsetField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus) _controller.text = _format(widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  void _set(double v) {
    final clamped = v.clamp(-_limit, _limit).toDouble();
    _controller.text = _format(clamped);
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  void _submit(String text) {
    final parsed = double.tryParse(
      text.trim().replaceAll(',', '.').replaceAll('−', '-'),
    );
    if (parsed == null) {
      _controller.text = _format(widget.value);
    } else {
      _set(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CupertinoListTile(
      title: Text(widget.label),
      subtitle: Text(widget.hint, maxLines: 3),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: () => _set(widget.value - _step),
            child: Icon(
              CupertinoIcons.minus_circle,
              semanticLabel: l10n.decrease,
            ),
          ),
          SizedBox(
            width: 64,
            child: CupertinoTextField(
              controller: _controller,
              focusNode: _focus,
              textAlign: TextAlign.center,
              suffix: const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Text('mm'),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[-−0-9.,]')),
              ],
              onSubmitted: _submit,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: () => _set(widget.value + _step),
            child: Icon(
              CupertinoIcons.plus_circle,
              semanticLabel: l10n.increase,
            ),
          ),
        ],
      ),
    );
  }
}
