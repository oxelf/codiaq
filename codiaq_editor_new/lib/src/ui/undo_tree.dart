//import 'dart:math';
//
//import 'package:codiaq_editor/codiaq_editor.dart';
//import 'package:flutter/material.dart';
//import '../buffer/undo.dart';
//
//class UndoTreeVisualizer extends StatefulWidget {
//  final Buffer buffer;
//  const UndoTreeVisualizer({super.key, required this.buffer});
//
//  @override
//  State<UndoTreeVisualizer> createState() => _UndoTreeVisualizerState();
//}
//
//class _UndoTreeVisualizerState extends State<UndoTreeVisualizer> {
//  Offset? _hoverPosition;
//
//  @override
//  void initState() {
//    super.initState();
//    widget.buffer.undoTree.addListener(_onUndoTreeChanged);
//  }
//
//  @override
//  void dispose() {
//    widget.buffer.undoTree.removeListener(_onUndoTreeChanged);
//    super.dispose();
//  }
//
//  void _onUndoTreeChanged() {
//    setState(() {});
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return MouseRegion(
//      onHover: (event) {
//        setState(() {
//          _hoverPosition = event.localPosition;
//        });
//      },
//      onExit: (_) {
//        setState(() {
//          _hoverPosition = null;
//        });
//      },
//      child: SingleChildScrollView(
//        scrollDirection: Axis.vertical,
//        child: SingleChildScrollView(
//          scrollDirection: Axis.horizontal,
//          child: CustomPaint(
//            size: _calculateTreeSize(widget.buffer.undoTree),
//            painter: UndoTreePainter(
//              undoTree: widget.buffer.undoTree,
//              hoverPosition: _hoverPosition,
//              onNodeTap: (UndoNode node) {
//                widget.buffer.undoTree.setCurrentNode(node);
//              },
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  Size _calculateTreeSize(UndoTree undoTree) {
//    if (undoTree.root == null) return const Size(200, 200);
//    const double nodeSize = 24;
//    const double xSpacing = 60;
//    const double ySpacing = 50;
//    double maxWidth = 0;
//    double maxHeight = 0;
//
//    void calculateBounds(
//      UndoNode? node,
//      double x,
//      double y,
//      Set<UndoNode> visited,
//      int branchLevel,
//    ) {
//      if (node == null || visited.contains(node)) return;
//      visited.add(node);
//
//      maxWidth = max(maxWidth, x + branchLevel * xSpacing + nodeSize + 80);
//      maxHeight = max(maxHeight, y + nodeSize);
//
//      for (var i = 0; i < node.children.length; i++) {
//        calculateBounds(
//          node.children[i],
//          x,
//          y - ySpacing,
//          visited,
//          branchLevel + i,
//        );
//      }
//    }
//
//    double initialY = _countMainBranch(undoTree.root!) * ySpacing + 40;
//    calculateBounds(undoTree.root!, 40, initialY, {}, 0);
//    return Size(maxWidth + 80, initialY + ySpacing);
//  }
//
//  int _countMainBranch(UndoNode node) {
//    int count = 1;
//    UndoNode? current = node;
//    while (current?.children.isNotEmpty ?? false) {
//      count++;
//      current = current!.children.first;
//    }
//    return count;
//  }
//}
//
//class UndoTreePainter extends CustomPainter {
//  final UndoTree undoTree;
//  final Offset? hoverPosition;
//  final void Function(UndoNode node) onNodeTap;
//
//  UndoTreePainter({
//    required this.undoTree,
//    required this.hoverPosition,
//    required this.onNodeTap,
//  });
//
//  @override
//  void paint(Canvas canvas, Size size) {
//    if (undoTree.root == null) {
//      _drawEmptyMessage(canvas, size);
//      return;
//    }
//
//    final layout = _layoutTree(undoTree.root!);
//    final positions = layout['positions'] as Map<UndoNode, Offset>;
//    final seqMap = layout['seqMap'] as Map<UndoNode, int>;
//
//    _drawConnections(canvas, positions);
//    positions.forEach((node, pos) {
//      final isHovered = _isNodeHovered(pos);
//      _drawNode(
//        canvas,
//        node,
//        pos,
//        seqMap[node]!,
//        node == undoTree.current,
//        isHovered,
//      );
//    });
//  }
//
//  void _drawEmptyMessage(Canvas canvas, Size size) {
//    const text = TextSpan(
//      text: 'No undo history',
//      style: TextStyle(
//        color: Colors.grey,
//        fontSize: 14,
//        fontFamily: 'RobotoMono',
//      ),
//    );
//    final painter = TextPainter(text: text, textDirection: TextDirection.ltr);
//    painter.layout();
//    painter.paint(
//      canvas,
//      Offset(size.width / 2 - painter.width / 2, size.height / 2),
//    );
//  }
//
//  void _drawConnections(Canvas canvas, Map<UndoNode, Offset> positions) {
//    final mainPaint =
//        Paint()
//          ..color = Colors.blue.shade700
//          ..strokeWidth = 2.5
//          ..style = PaintingStyle.stroke;
//    final altPaint =
//        Paint()
//          ..color = Colors.blue.shade400.withOpacity(0.7)
//          ..strokeWidth = 1.5
//          ..style = PaintingStyle.stroke;
//
//    positions.forEach((node, pos) {
//      final center = pos + const Offset(12, 12);
//      for (var i = 0; i < node.children.length; i++) {
//        final child = node.children[i];
//        if (positions.containsKey(child)) {
//          final childCenter = positions[child]! + const Offset(12, 12);
//          final paint = i == 0 ? mainPaint : altPaint;
//          canvas.drawLine(center, childCenter, paint);
//          _drawArrow(canvas, center, childCenter, paint);
//        }
//      }
//    });
//  }
//
//  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//    const dashWidth = 4.0;
//    const dashSpace = 4.0;
//    double distance = (end - start).distance;
//    final direction = (end - start) / distance;
//    double currentDistance = 0;
//
//    while (currentDistance < distance) {
//      final startPoint = start + direction * currentDistance;
//      final endPoint =
//          start + direction * min(currentDistance + dashWidth, distance);
//      canvas.drawLine(startPoint, endPoint, paint);
//      currentDistance += dashWidth + dashSpace;
//    }
//  }
//
//  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
//    const arrowSize = 6.0;
//    final direction = (end - start).direction;
//    final arrowPoint =
//        end - Offset(cos(direction) * arrowSize, sin(direction) * arrowSize);
//    final p1 =
//        arrowPoint +
//        Offset(
//          cos(direction + pi / 6) * arrowSize,
//          sin(direction + pi / 6) * arrowSize,
//        );
//    final p2 =
//        arrowPoint +
//        Offset(
//          cos(direction - pi / 6) * arrowSize,
//          sin(direction - pi / 6) * arrowSize,
//        );
//    final path =
//        Path()
//          ..moveTo(p1.dx, p1.dy)
//          ..lineTo(arrowPoint.dx, arrowPoint.dy)
//          ..lineTo(p2.dx, p2.dy);
//    canvas.drawPath(path, paint);
//  }
//
//  void _drawNode(
//    Canvas canvas,
//    UndoNode node,
//    Offset pos,
//    int seq,
//    bool isCurrent,
//    bool isHovered,
//  ) {
//    final circlePaint =
//        Paint()
//          ..color = isCurrent ? Colors.green.shade500 : Colors.grey.shade200
//          ..style = PaintingStyle.fill;
//    final borderPaint =
//        Paint()
//          ..color = isCurrent ? Colors.green.shade700 : Colors.grey.shade500
//          ..style = PaintingStyle.stroke
//          ..strokeWidth = 1.5;
//    final shadowPaint =
//        Paint()
//          ..color = Colors.black.withOpacity(isHovered ? 0.3 : 0.15)
//          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
//
//    final center = pos + const Offset(12, 12);
//    canvas.drawCircle(center, 12, shadowPaint);
//    canvas.drawCircle(center, 12, circlePaint);
//    canvas.drawCircle(center, 12, borderPaint);
//
//    final seqText = TextSpan(
//      text: isCurrent ? '[$seq]' : '$seq',
//      style: TextStyle(
//        color: isCurrent ? Colors.white : Colors.black87,
//        fontSize: 10,
//        fontWeight: FontWeight.bold,
//        fontFamily: 'RobotoMono',
//      ),
//    );
//    final seqPainter = TextPainter(
//      text: seqText,
//      textAlign: TextAlign.center,
//      textDirection: TextDirection.ltr,
//    );
//    seqPainter.layout();
//    seqPainter.paint(
//      canvas,
//      pos + Offset(12 - seqPainter.width / 2, 12 - seqPainter.height / 2),
//    );
//
//    final timeText = TextSpan(
//      text: seq == 0 ? 'Original' : _getRelativeTime(node.time),
//      style: TextStyle(
//        color: isCurrent ? Colors.green.shade800 : Colors.grey.shade600,
//        fontSize: 10,
//        fontFamily: 'RobotoMono',
//      ),
//    );
//    final timePainter = TextPainter(
//      text: timeText,
//      textDirection: TextDirection.ltr,
//    );
//    timePainter.layout();
//    timePainter.paint(canvas, pos + const Offset(30, 7));
//  }
//
//  String _getRelativeTime(DateTime time) {
//    final now = DateTime.now();
//    final diff = now.difference(time);
//    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
//    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//    if (diff.inHours < 24) return '${diff.inHours}h ago';
//    return '${diff.inDays}d ago';
//  }
//
//  bool _isNodeHovered(Offset pos) {
//    if (hoverPosition == null) return false;
//    final center = pos + const Offset(12, 12);
//    return (hoverPosition! - center).distance <= 12;
//  }
//
//  @override
//  bool shouldRepaint(covariant UndoTreePainter oldDelegate) => true;
//
//  @override
//  bool? hitTest(Offset position) {
//    final layout = _layoutTree(undoTree.root!);
//    final positions = layout['positions'] as Map<UndoNode, Offset>;
//    for (final entry in positions.entries) {
//      final center = entry.value + const Offset(12, 12);
//      final distance = (position - center).distance;
//      if (distance <= 12) {
//        onNodeTap(entry.key);
//        return true;
//      }
//    }
//    return false;
//  }
//
//  Map<String, dynamic> _layoutTree(UndoNode root) {
//    final Map<UndoNode, Offset> positions = {};
//    final Map<UndoNode, int> seqMap = {};
//    double maxWidth = 0;
//    double maxHeight = 0;
//    const double nodeSize = 24;
//    const double xSpacing = 60;
//    const double ySpacing = 50;
//    int seqCounter = 0;
//
//    void assignPositions(
//      UndoNode? node,
//      double x,
//      double y,
//      Set<UndoNode> visited,
//      int branchLevel,
//    ) {
//      if (node == null || visited.contains(node)) return;
//      visited.add(node);
//
//      seqMap[node] = seqCounter++;
//      positions[node] = Offset(x + branchLevel * xSpacing, y);
//      maxWidth = max(maxWidth, x + branchLevel * xSpacing + nodeSize + 80);
//      maxHeight = max(maxHeight, y + nodeSize);
//
//      for (var i = 0; i < node.children.length; i++) {
//        assignPositions(
//          node.children[i],
//          x,
//          y - ySpacing,
//          visited,
//          branchLevel + i,
//        );
//      }
//    }
//
//    double initialY = _countMainBranch(root) * ySpacing + 40;
//    assignPositions(root, 40, initialY, {}, 0);
//    return {
//      'positions': positions,
//      'seqMap': seqMap,
//      'width': maxWidth,
//      'height': initialY + ySpacing,
//    };
//  }
//
//  int _countMainBranch(UndoNode node) {
//    int count = 1;
//    UndoNode? current = node;
//    while (current?.children.isNotEmpty ?? false) {
//      count++;
//      current = current!.children.first;
//    }
//    return count;
//  }
//}
