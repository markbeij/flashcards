import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MenuAnchor, MenuItemButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../data/store/library_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../render/sheet.dart';
import '../locations.dart';
import '../providers.dart';
import 'cutting_guide.dart';
import 'manual_duplex.dart';
import 'print_job.dart';

/// Print, step 2: sheet thumbnails, the checklist and the print actions.
class PrintPreviewScreen extends ConsumerStatefulWidget {
  const PrintPreviewScreen({super.key});

  @override
  ConsumerState<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

enum _Side { fronts, backs }

class _PrintPreviewScreenState extends ConsumerState<PrintPreviewScreen> {
  _Side _side = _Side.fronts;
  Future<Uint8List>? _pdf;
  final _shareKey = GlobalKey();

  Future<Uint8List> _build(SheetPages pages) async {
    final title = AppLocalizations.of(context).appTitle;
    final theme = await ref.read(cardThemeProvider.future);
    final job = ref.read(printJobProvider);
    final settings = ref.read(libraryProvider).settings;
    return buildSheets(
      ref.read(printPlanProvider).printed(job),
      theme: theme,
      title: title,
      grid: gridFor(settings),
      swap: job.swap,
      pages: pages,
    );
  }

  Future<void> _print() async {
    final name = AppLocalizations.of(context).pdfFileName;
    final bytes = await _pdf!;
    final printed = await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name,
      format: PdfPageFormat.a4,
    );
    if (!printed || !mounted) return;
    final settings = ref.read(libraryProvider).settings;
    if (!settings.cuttingGuideShown) {
      ref
          .read(libraryProvider.notifier)
          .updateSettings(settings.copyWith(cuttingGuideShown: true));
      await showCuttingGuide(context);
    }
  }

  Future<void> _share() async {
    final bytes = await _pdf!;
    if (!mounted) return;
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${AppLocalizations.of(context).pdfFileName}.pdf',
      bounds: shareBounds(_shareKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _pdf ??= _build(SheetPages.duplex);
    final settings = ref.watch(libraryProvider.select((l) => l.settings));

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.preview),
        previousPageTitle: l10n.print,
        trailing: MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () => showManualDuplex(
                context,
                fronts: () => _build(SheetPages.fronts),
                backs: () => _build(SheetPages.backs),
              ),
              child: Text(l10n.noDuplex),
            ),
            MenuItemButton(
              onPressed: () => showCuttingGuide(context),
              child: Text(l10n.howToCut),
            ),
          ],
          builder: (context, controller, _) => CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: Icon(
              CupertinoIcons.ellipsis_circle,
              semanticLabel: l10n.moreActions,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (settings.calibration == null)
              _Banner(
                text: l10n.notCalibrated,
                action: l10n.calibrate,
                onAction: () => context.push(settingsLocation),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSlidingSegmentedControl<_Side>(
                groupValue: _side,
                children: {
                  _Side.fronts: Text(l10n.fronts),
                  _Side.backs: Text(l10n.backs),
                },
                onValueChanged: (side) => setState(() => _side = side!),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Uint8List>(
              future: _pdf,
              builder: (context, snapshot) => snapshot.hasData
                  ? _Thumbnails(
                      pdf: snapshot.data!,
                      backs: _side == _Side.backs,
                    )
                  : const SizedBox(
                      height: 200,
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
            ),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.checklist),
              children: [
                _Check(icon: CupertinoIcons.book, text: l10n.checkDuplex),
                _Check(icon: CupertinoIcons.doc, text: l10n.checkA4),
                _Check(
                  icon: CupertinoIcons.arrow_up_left_arrow_down_right,
                  text: l10n.checkScale,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CupertinoButton.filled(
                    onPressed: _print,
                    child: Text(l10n.print),
                  ),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    key: _shareKey,
                    onPressed: _share,
                    child: Text(l10n.sharePdf),
                  ),
                  if (settings.cuttingGuideShown)
                    CupertinoButton(
                      onPressed: () => showCuttingGuide(context),
                      child: Text(l10n.howToCut),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the iPad share popover points.
Rect shareBounds(GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return Rect.zero;
  return box.localToGlobal(Offset.zero) & box.size;
}

class _Check extends StatelessWidget {
  const _Check({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) =>
      CupertinoListTile(leading: Icon(icon), title: Text(text, maxLines: 3));
}

/// A non-blocking notice with one action.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.action,
    required this.onAction,
  });

  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow
            .resolveFrom(context)
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.info_circle),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          CupertinoButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}

/// The sheets of one side, rasterised from the print PDF.
class _Thumbnails extends StatefulWidget {
  const _Thumbnails({required this.pdf, required this.backs});

  final Uint8List pdf;
  final bool backs;

  @override
  State<_Thumbnails> createState() => _ThumbnailsState();
}

class _ThumbnailsState extends State<_Thumbnails> {
  static const _width = 160.0;
  List<ui.Image>? _pages;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Needs the pixel ratio, so it can't start in initState.
    if (!_started) {
      _started = true;
      _raster();
    }
  }

  Future<void> _raster() async {
    final dpi = _width * MediaQuery.devicePixelRatioOf(context) / (210 / 25.4);
    final images = <ui.Image>[];
    try {
      await for (final page in Printing.raster(widget.pdf, dpi: dpi)) {
        images.add(await page.toImage());
      }
    } catch (_) {
      // Rasterising needs the platform.
    }
    if (!mounted) {
      for (final image in images) {
        image.dispose();
      }
      return;
    }
    setState(() => _pages = images);
  }

  @override
  void dispose() {
    for (final image in _pages ?? const <ui.Image>[]) {
      image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages ?? const [];
    final side = [
      for (var i = widget.backs ? 1 : 0; i < pages.length; i += 2) pages[i],
    ];
    return SizedBox(
      height: _width * 297 / 210 + 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: side.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
              ),
              child: Semantics(
                image: true,
                label: l10n.sheetThumbnail(i + 1),
                child: RawImage(
                  image: side[i],
                  width: _width,
                  height: _width * 297 / 210,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.sheetNumber(i + 1), style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
