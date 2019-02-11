import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/// Creates grid layouts with a fixed number of tiles in the cross axis.
///
/// This delegate creates grids with un equal or equal sized tiles.

class XSliverGridDelegate extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// All of the arguments must not be null. The `mainAxisSpacing` and
  /// `crossAxisSpacing` arguments must not be negative. The `crossAxisCount`,
  /// `bigCellExtent` and `smallCellExtent` arguments must be greater than zero
  /// and `bigCellExtent` must be greater or equal to `smallCellExtent`.
  ///
  XSliverGridDelegate({
    @required this.crossAxisCount,
    @required this.bigCellExtent,
    @required this.smallCellExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.isFirstCellBig = true
  }): assert(crossAxisCount != null && crossAxisCount > 0),
        assert(bigCellExtent != null && bigCellExtent > 0),
        assert(smallCellExtent != null && smallCellExtent > 0),
        assert(bigCellExtent >= smallCellExtent),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(isFirstCellBig != null);

  /// Height of big cell.
  final double bigCellExtent;

  /// Height of small cell.
  final double smallCellExtent;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// If true first cell will be big otherwise small.
  final bool isFirstCellBig;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double tileWidth = usableCrossAxisExtent / crossAxisCount;
    final double tileHeight = smallCellExtent;

    if(bigCellExtent - smallCellExtent == 0){
      return SliverGridRegularTileLayout(
        crossAxisCount: crossAxisCount,
        mainAxisStride: tileHeight + mainAxisSpacing,
        crossAxisStride: tileWidth + crossAxisSpacing,
        childMainAxisExtent: tileHeight,
        childCrossAxisExtent: tileWidth,
        reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      );
    }else if(isFirstCellBig){
      return _XSliverGridLayout1(
        crossAxisCount: crossAxisCount,
        crossAxisExtent: tileWidth,
        crossAxisStride: tileWidth + crossAxisSpacing,
        smallChildMainAxisExtent: smallCellExtent,
        bigChildMainAxisExtent: bigCellExtent,
        smallChildMainAxisStride: smallCellExtent + mainAxisSpacing,
        bigChildMainAxisStride: bigCellExtent + mainAxisSpacing,
        isFirstCellBig: isFirstCellBig,
      );
    }else{
      return _XSliverGridLayout2(
        crossAxisCount: crossAxisCount,
        crossAxisExtent: tileWidth,
        crossAxisStride: tileWidth + crossAxisSpacing,
        smallChildMainAxisExtent: smallCellExtent,
        bigChildMainAxisExtent: bigCellExtent,
        smallChildMainAxisStride: smallCellExtent + mainAxisSpacing,
        bigChildMainAxisStride: bigCellExtent + mainAxisSpacing,
        isFirstCellBig: isFirstCellBig,
      );
    }
  }

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(bigCellExtent > 0);
    assert(smallCellExtent > 0);
    assert(bigCellExtent >= smallCellExtent);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  @override
  bool shouldRelayout(covariant XSliverGridDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount
        || oldDelegate.bigCellExtent != bigCellExtent
        || oldDelegate.smallCellExtent != smallCellExtent
        || oldDelegate.mainAxisSpacing != mainAxisSpacing
        || oldDelegate.crossAxisSpacing != crossAxisSpacing
        || oldDelegate.isFirstCellBig != isFirstCellBig;
  }
}

abstract class _XSliverGridLayout extends SliverGridLayout{
  _XSliverGridLayout({
    this.crossAxisCount,
    this.smallChildMainAxisExtent,
    this.bigChildMainAxisExtent,
    this.smallChildMainAxisStride,
    this.bigChildMainAxisStride,
    this.isFirstCellBig,
  });

  final int crossAxisCount;
  final double smallChildMainAxisExtent;
  final double bigChildMainAxisExtent;
  final double smallChildMainAxisStride;
  final double bigChildMainAxisStride;
  final bool isFirstCellBig;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    if(bigChildMainAxisStride > 0.0){
      final mainAxisCount = (scrollOffset ~/ (bigChildMainAxisStride + smallChildMainAxisStride)) * 2;
      return math.max(0, ((crossAxisCount) * mainAxisCount));
    }
    return 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    if (bigChildMainAxisStride > 0.0) {
      double extentDiff = (bigChildMainAxisExtent - smallChildMainAxisExtent).abs();
      final int mainAxisCount = ((scrollOffset / (smallChildMainAxisStride + (extentDiff / 2))).ceil());
      return math.max(0, crossAxisCount * mainAxisCount - 1);
    }
    return 0;
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount != null);
    final int mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1;
    final double mainAxisSpacing = smallChildMainAxisStride - (smallChildMainAxisExtent);

    int lastRowChildCount = crossAxisCount - ((mainAxisCount * crossAxisCount) - childCount);
    int smallChildMainAxisCount = (mainAxisCount ~/ 2);
    int bigChildMainAxisCount = (mainAxisCount ~/ 2);

    if(lastRowChildCount > 1){
      if(mainAxisCount %2 != 0)
        bigChildMainAxisCount = (mainAxisCount ~/ 2) + 1;
    }else{
      if(!isFirstCellBig){
        if(mainAxisCount %2 != 0)
          smallChildMainAxisCount = (mainAxisCount ~/ 2) + 1;
      }else{
        if(mainAxisCount %2 != 0)
          bigChildMainAxisCount = (mainAxisCount ~/ 2) + 1;
      }
    }
    double smallChildMaxScrollOffset = (smallChildMainAxisStride) * smallChildMainAxisCount - mainAxisSpacing;
    double bigChildMaxScrollOffset = (bigChildMainAxisStride) * bigChildMainAxisCount - mainAxisSpacing;
    return (bigChildMaxScrollOffset + smallChildMaxScrollOffset);
  }
}

class _XSliverGridLayout1 extends _XSliverGridLayout{
  _XSliverGridLayout1({
    this.crossAxisCount,
    this.crossAxisStride,
    this.crossAxisExtent,
    this.smallChildMainAxisExtent,
    this.bigChildMainAxisExtent,
    this.smallChildMainAxisStride,
    this.bigChildMainAxisStride,
    this.isFirstCellBig
  }): super(
      crossAxisCount : crossAxisCount,
      smallChildMainAxisExtent: smallChildMainAxisExtent,
      bigChildMainAxisExtent:bigChildMainAxisExtent,
      smallChildMainAxisStride: smallChildMainAxisStride,
      bigChildMainAxisStride: bigChildMainAxisStride,
      isFirstCellBig: isFirstCellBig,
  );

  final int crossAxisCount;
  final double crossAxisStride;
  final double crossAxisExtent;
  final double smallChildMainAxisExtent;
  final double bigChildMainAxisExtent;
  final double smallChildMainAxisStride;
  final double bigChildMainAxisStride;
  final bool isFirstCellBig;

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    double mainAxisStart = 0;
    double crossAxisStart = 0;
    double mainAxisExtent = smallChildMainAxisExtent;

    int row = index ~/ crossAxisCount;
    int col = (index % crossAxisCount);
    double extentDiff = (bigChildMainAxisExtent - smallChildMainAxisExtent).abs();

    double offset = 0;
    if(row % 2 == 0){
      if(col %2 == 0){
        mainAxisExtent = bigChildMainAxisExtent;
        offset = row * (extentDiff / 2);
      }else{
        offset = row * (extentDiff / 2);
      }
    }else{
      if(col %2 == 0){
        offset = (row + 1) * (extentDiff / 2);
      }else{
        mainAxisExtent = bigChildMainAxisExtent;
        offset = ((row - 1) * (extentDiff / 2));
      }
    }
    mainAxisStart = (row * smallChildMainAxisStride) + (offset);
    crossAxisStart = col * crossAxisStride;

    return SliverGridGeometry(
      scrollOffset: mainAxisStart,
      crossAxisOffset: crossAxisStart,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
    );
  }
}

class _XSliverGridLayout2 extends _XSliverGridLayout{
  _XSliverGridLayout2({
    this.crossAxisCount,
    this.crossAxisStride,
    this.crossAxisExtent,
    this.smallChildMainAxisExtent,
    this.bigChildMainAxisExtent,
    this.smallChildMainAxisStride,
    this.bigChildMainAxisStride,
    this.isFirstCellBig
  }): super(
      crossAxisCount : crossAxisCount,
      smallChildMainAxisExtent: smallChildMainAxisExtent,
      bigChildMainAxisExtent:bigChildMainAxisExtent,
      smallChildMainAxisStride: smallChildMainAxisStride,
      bigChildMainAxisStride: bigChildMainAxisStride,
      isFirstCellBig: isFirstCellBig,
  );

  final int crossAxisCount;
  final double crossAxisStride;
  final double crossAxisExtent;
  final double smallChildMainAxisExtent;
  final double bigChildMainAxisExtent;
  final double smallChildMainAxisStride;
  final double bigChildMainAxisStride;
  final bool isFirstCellBig;

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    double mainAxisStart = 0;
    double crossAxisStart = 0;
    double mainAxisExtent = smallChildMainAxisExtent;

    int row = index ~/ crossAxisCount;
    int col = (index % crossAxisCount);
    double extentDiff = (bigChildMainAxisExtent - smallChildMainAxisExtent).abs();

    double offset = 0;
    if(row % 2 == 0){
      if(col %2 == 0){
        offset = ((row + 1) * (extentDiff / 2) - (extentDiff / 2));
      }else{
        mainAxisExtent = bigChildMainAxisExtent;
        offset = row * (extentDiff / 2);
      }
    }else{
      if(col %2 == 0){
        mainAxisExtent = bigChildMainAxisExtent;
        offset = row * (extentDiff / 2) - (extentDiff / 2);
      }else{
        offset = row * (extentDiff / 2) + (extentDiff / 2);
      }
    }
    mainAxisStart = (row * smallChildMainAxisStride) + (offset);
    crossAxisStart = col * crossAxisStride;

    return SliverGridGeometry(
      scrollOffset: mainAxisStart,
      crossAxisOffset: crossAxisStart,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
    );
  }
}