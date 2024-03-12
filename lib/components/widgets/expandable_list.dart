import 'package:flutter/material.dart';
import 'package:unisync/utils/extensions/list.ext.dart';

import 'clickable.dart';

class ExpandableList extends StatefulWidget {
  /// A list that can expand and collapse its children. Every child must have a global key.
  ExpandableList({
    super.key,
    required this.children,
    this.initialChildrenCount = 0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.ease,
    this.initialExpand = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.expandWidget,
    this.collapseWidget,
    this.onExpansionChanged,
  }) : assert(children.every((element) => element.key is GlobalKey), 'Every child must have a GlobalKey!');

  final List<Widget> children;

  /// The number of children to show when it's collapsed.
  final int initialChildrenCount;

  /// The collapse/expand animation duration.
  final Duration duration;

  /// The collapse/expand animation curve.
  final Curve curve;

  /// Set the list to be initially expanded or not.
  final bool initialExpand;
  final CrossAxisAlignment crossAxisAlignment;

  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onExpansionChanged;
  final Widget? expandWidget;
  final Widget? collapseWidget;

  @override
  State<ExpandableList> createState() => _ExpandableListState();
}

class _ExpandableListState extends State<ExpandableList> {
  bool isExpanded = false;

  /// The initial height or the height of all children that are shown when collapsed.
  double initialHeight = 0;

  /// The height of all children when expanded.
  double fullHeight = 0;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initialExpand;
    // Calculate children's size after rendering.
    _calculateSizes();
  }

  void _calculateSizes() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final childrenSize = widget.children.map((child) {
        final key = child.key as GlobalKey;
        final renderBox = key.currentContext!.findRenderObject() as RenderBox;
        return renderBox.size;
      }).toList();
      initialHeight = childrenSize.take(widget.initialChildrenCount).fold(0, (previousValue, element) {
        return previousValue + element.height;
      });
      fullHeight = childrenSize.fold(0, (previousValue, element) => previousValue + element.height);
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant ExpandableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.differ(widget.children)) {
      _calculateSizes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          height: isExpanded ? fullHeight : initialHeight,
          // Provide a gradient to further indicate when the list of collapsed.
          foregroundDecoration: isExpanded
              ? null
              : const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.white,
                    ],
                    stops: [0.8, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  backgroundBlendMode: BlendMode.lighten,
                ),
          child: UnconstrainedBox(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.antiAlias,
            constrainedAxis: Axis.horizontal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: widget.children,
            ),
          ),
        ),
        if (widget.children.length > 1)
          Clickable(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
              widget.onExpansionChanged?.call(isExpanded);
            },
            child: () {
              if (isExpanded) {
                return widget.collapseWidget ?? expansionButton(expanded: isExpanded);
              } else {
                return widget.expandWidget ?? expansionButton(expanded: isExpanded);
              }
            }.call(),
          ),
      ],
    );
  }

  Widget expansionButton({required bool expanded}) {
    Widget icon(IconData data) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 8,
        ),
        child: Icon(
          data,
          weight: 300,
          size: 12,
          color: Colors.grey,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: AnimatedSwitcher(
        duration: widget.duration,
        switchInCurve: widget.curve,
        switchOutCurve: widget.curve,
        child: expanded ? icon(Icons.keyboard_arrow_up_rounded) : icon(Icons.keyboard_arrow_down_rounded),
      ),
    );
  }
}
