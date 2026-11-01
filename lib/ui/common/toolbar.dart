import 'package:flutter/cupertino.dart';

/// The bottom toolbar of a page: actions spread out, above the home
/// indicator.
class BottomToolbar extends StatelessWidget {
  const BottomToolbar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final background = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).barBackgroundColor,
      context,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Labels wrap rather than overflow, e.g. in German or with large
            // text.
            children: [for (final child in children) Flexible(child: child)],
          ),
        ),
      ),
    );
  }
}

/// A toolbar button with an icon and a label; at least 44 pt tall.
class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? CupertinoColors.destructiveRed.resolveFrom(context)
        : null;
    return CupertinoButton(
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
