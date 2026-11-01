import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';
import 'illustrations.dart';

/// Three steps: cut off the edges, cut the columns, cut the rows.
Future<void> showCuttingGuide(BuildContext context) => showCupertinoSheet<void>(
  context: context,
  scrollableBuilder: (context, controller) {
    final l10n = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(l10n.howToCut),
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
            for (final (i, (step, text)) in [
              (CutStep.edges, l10n.cutEdges),
              (CutStep.columns, l10n.cutColumns),
              (CutStep.rows, l10n.cutRows),
            ].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    CutIllustration(step: step, width: 90),
                    const SizedBox(width: 16),
                    Expanded(child: Text('${i + 1}. $text')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  },
);
