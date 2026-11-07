import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';

/// Icon and plain words: the card's content doesn't fit.
class OverflowBadge extends StatelessWidget {
  const OverflowBadge({super.key});

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
            l10n.overflowLong,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
