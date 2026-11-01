import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';

/// Icon and plain words: the card's content doesn't fit.
class OverflowBadge extends StatelessWidget {
  const OverflowBadge({super.key, this.long = false});

  /// With the advice to shorten it, for the entry screens.
  final bool long;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = CupertinoColors.systemOrange.resolveFrom(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.exclamationmark_triangle_fill,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            long ? l10n.overflowLong : l10n.overflowShort,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
