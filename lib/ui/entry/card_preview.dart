import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../domain/card_content.dart';
import '../../domain/flashcard.dart';
import '../../l10n/app_localizations.dart';
import '../../render/card_size.dart';
import '../../render/sheet.dart';
import '../common/card_summary.dart';
import '../providers.dart';
import 'entry_session.dart';

/// The preview of the session's current draft. It follows the typing after
/// a short pause and never takes focus.
class SessionPreview extends ConsumerStatefulWidget {
  const SessionPreview({super.key, required this.session});

  final EntrySession session;

  @override
  ConsumerState<SessionPreview> createState() => _SessionPreviewState();
}

class _SessionPreviewState extends ConsumerState<SessionPreview> {
  static const _pause = Duration(milliseconds: 400);
  Timer? _timer;
  CardContent? _content;
  int? _seq;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_changed);
    widget.session.edits.addListener(_changed);
    _update();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.session.removeListener(_changed);
    widget.session.edits.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    _timer?.cancel();
    _timer = Timer(_pause, () {
      if (mounted) setState(_update);
    });
  }

  void _update() {
    final draft = widget.session.current ?? widget.session.active;
    _content = draft.isBlank ? null : draft.toContent();
    _seq = draft.seq;
  }

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(deckProvider(widget.session.deckId));
    final content = _content;
    if (content == null || deck == null) {
      return const CardPreview.empty();
    }
    return CardPreview(content: content, deckTitle: deck.title, seq: _seq);
  }
}

/// Front and back of a card, rasterised from the same PDF that is printed.
/// The PDF preview stays white paper in dark mode.
class CardPreview extends ConsumerStatefulWidget {
  const CardPreview({
    super.key,
    required CardContent this.content,
    required this.deckTitle,
    this.seq,
  });

  const CardPreview.empty({super.key})
    : content = null,
      deckTitle = '',
      seq = null;

  final CardContent? content;
  final String deckTitle;

  /// null for a card that isn't saved yet.
  final int? seq;

  @override
  ConsumerState<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends ConsumerState<CardPreview> {
  List<ui.Image>? _pages;
  Object? _job;
  double? _dpi;

  @override
  void didUpdateWidget(CardPreview old) {
    super.didUpdateWidget(old);
    if (old.content != widget.content ||
        old.deckTitle != widget.deckTitle ||
        old.seq != widget.seq) {
      _render();
    }
  }

  @override
  void dispose() {
    _job = null;
    for (final image in _pages ?? const <ui.Image>[]) {
      image.dispose();
    }
    super.dispose();
  }

  Future<void> _render() async {
    final content = widget.content;
    final theme = ref.read(cardThemeProvider).value;
    final dpi = _dpi;
    if (content == null || theme == null || dpi == null) return;
    final job = Object();
    _job = job;
    final now = DateTime.now();
    final bytes = await buildCardPreview(
      PrintCard(
        Flashcard(
          uuid: '',
          seq: widget.seq ?? 0,
          content: content,
          createdAt: now,
          updatedAt: now,
        ),
        widget.deckTitle,
      ),
      theme: theme,
    );
    final images = await _raster(bytes, dpi);
    if (!mounted || !identical(_job, job)) {
      for (final image in images) {
        image.dispose();
      }
      return;
    }
    setState(() {
      for (final image in _pages ?? const <ui.Image>[]) {
        image.dispose();
      }
      _pages = images;
    });
  }

  static Future<List<ui.Image>> _raster(Uint8List bytes, double dpi) async {
    try {
      return [
        await for (final page in Printing.raster(bytes, dpi: dpi))
          await page.toImage(),
      ];
    } catch (_) {
      // Rasterising needs the platform (not available in widget tests).
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(cardThemeProvider, (_, _) => _render());
    final l10n = AppLocalizations.of(context);
    final content = widget.content;
    return ExcludeFocus(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(120.0, 480.0);
          final dpi =
              width *
              MediaQuery.devicePixelRatioOf(context) /
              (cardWidthMm / 25.4);
          if (_dpi == null || (dpi - _dpi!).abs() > 1) {
            _dpi = dpi;
            WidgetsBinding.instance.addPostFrameCallback((_) => _render());
          }
          final height = width * cardHeightMm / cardWidthMm;
          return Semantics(
            label: content == null
                ? l10n.previewEmpty
                : l10n.previewLabel(cardDescription(content)),
            image: true,
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var side = 0; side < 2; side++) ...[
                  _Paper(
                    width: width,
                    height: height,
                    image:
                        content == null ||
                            _pages == null ||
                            _pages!.length <= side
                        ? null
                        : _pages![side],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({required this.width, required this.height, this.image});

  final double width;
  final double height;
  final ui.Image? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: image == null
          ? null
          : RawImage(
              image: image,
              width: width,
              height: height,
              fit: BoxFit.fill,
            ),
    );
  }
}
