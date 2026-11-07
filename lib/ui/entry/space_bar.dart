import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../render/grid.dart' show Side;
import '../../render/overflow.dart';
import '../common/overflow_badge.dart';
import '../providers.dart';
import 'draft.dart';
import 'entry_session.dart';

/// From this fill the bar turns orange.
const spaceWarnFrom = 0.85;

/// "Space on the card": how full one side of the card is, while typing. It
/// uses the real height in the PDF (`overflow.dart`), not a character count.
/// At 100 % (or when a single word is too wide) a badge says so. Text is
/// never shrunk and entry is never blocked.
class SpaceBar extends ConsumerWidget {
  const SpaceBar({
    super.key,
    required this.session,
    required this.draft,
    required this.side,
  });

  final EntrySession session;
  final DraftCard draft;
  final Side side;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checker = ref.watch(overflowCheckerProvider);
    return ListenableBuilder(
      listenable: session.edits,
      builder: (context, _) {
        final measured = checker?.measure(draft.toContent());
        final fill = measured == null
            ? null
            : (side == Side.front ? measured.front : measured.back);
        return SpaceBarView(fill: fill);
      },
    );
  }
}

/// The bar for a measured [fill]; empty until the card font has loaded.
class SpaceBarView extends StatelessWidget {
  const SpaceBarView({super.key, required this.fill});

  final SideFill? fill;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final full = fill?.full ?? false;
    final used = full ? 1.0 : (fill?.fill ?? 0).clamp(0.0, 1.0);
    final color = used >= spaceWarnFrom
        ? CupertinoColors.systemOrange.resolveFrom(context)
        : CupertinoColors.systemBlue.resolveFrom(context);
    return Semantics(
      container: true,
      label: l10n.spaceOnCard,
      value: l10n.spaceUsed((used * 100).round()),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.spaceOnCard,
              style: TextStyle(color: secondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    color: CupertinoColors.systemFill.resolveFrom(context),
                  ),
                  FractionallySizedBox(
                    widthFactor: used,
                    child: Container(height: 4, color: color),
                  ),
                ],
              ),
            ),
            if (full) ...[const SizedBox(height: 6), const OverflowBadge()],
          ],
        ),
      ),
    );
  }
}
