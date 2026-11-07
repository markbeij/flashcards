import 'package:flutter/cupertino.dart';

import '../library/library_pages.dart';

/// Two columns from this width (and [twoColumnMinHeight] tall).
const twoColumnMinWidth = 680.0;
const twoColumnMinHeight = 500.0;

/// The iPadOS split-view default, in both orientations.
const libraryColumnWidth = 320.0;

bool isTwoColumn(Size size) =>
    size.width >= twoColumnMinWidth && size.height >= twoColumnMinHeight;

/// Tells pages inside the shell whether the Library is shown beside them.
class ShellLayout extends InheritedWidget {
  const ShellLayout({
    super.key,
    required this.twoColumns,
    required super.child,
  });

  final bool twoColumns;

  static bool twoColumnsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellLayout>()?.twoColumns ??
      false;

  @override
  bool updateShouldNotify(ShellLayout old) => old.twoColumns != twoColumns;
}

/// Library on the left and the detail on the right in a wide window; a
/// single navigation stack otherwise. The layout follows the window size,
/// not the device. Selection and editing state live in Riverpod above this
/// switch, so nothing is lost when the window is resized.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key, required this.location, required this.child});

  /// The current router location.
  final Uri location;

  /// The navigator with the library pages.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final twoColumns = isTwoColumn(MediaQuery.sizeOf(context));
    // The child navigator has a global key, so it moves between the two
    // layouts with its pages and their state.
    final detail = ShellLayout(twoColumns: twoColumns, child: child);
    if (!twoColumns) return detail;
    return Row(
      children: [
        SizedBox(
          width: libraryColumnWidth,
          child: LibraryColumn(location: location),
        ),
        Container(
          width: 0.5,
          color: CupertinoColors.separator.resolveFrom(context),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            child: detail,
          ),
        ),
      ],
    );
  }
}
