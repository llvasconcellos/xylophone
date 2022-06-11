import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(XylophoneApp(key: GlobalKey()));

final List<AudioCache> _players = List<AudioCache>.filled(7, AudioCache());

class XKeyProxy extends RenderProxyBox {
  late int index;
}

class XKeyRO extends SingleChildRenderObjectWidget {
  final int index;

  @override
  final Widget child;

  const XKeyRO({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key, child: child);

  @override
  XKeyProxy createRenderObject(BuildContext context) {
    return XKeyProxy()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, XKeyProxy renderObject) {
    renderObject.index = index;
  }
}

class XKey extends StatelessWidget {
  final double height;
  final MaterialColor backgroundColor;
  final int noteNumber;
  final int index;

  const XKey({
    Key? key,
    required this.height,
    required this.backgroundColor,
    required this.noteNumber,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return XKeyRO(
      index: index,
      child: Container(height: height, color: backgroundColor),
    );
  }
}

class XylophoneApp extends StatelessWidget {
  final List<MaterialColor> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.purple,
  ];
  final Set<XKeyProxy> _trackTaped = <XKeyProxy>{};

  XylophoneApp({GlobalKey? key}) : super(key: key);

  _detectTapedItem(PointerEvent event) {
    final RenderBox box =
        (key as GlobalKey).currentContext?.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(event.position);
    final result = BoxHitTestResult();
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        if (target is XKeyProxy && !_trackTaped.contains(target)) {
          _trackTaped.add(target);
          _players[target.index].play('note${target.index + 1}.wav');
        }
      }
    }
  }

  void _clearSelection(PointerUpEvent event) {
    _trackTaped.clear();
    //selectedIndexes.clear();
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < _colors.length; i++){
      _players[i].load('note${i + 1}.wav');
    }

    MediaQueryData? mediaQuery;
    var itemHeight = 0.0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Listener(
            onPointerDown: _detectTapedItem,
            onPointerMove: _detectTapedItem,
            onPointerUp: _clearSelection,
            child: ListView.custom(
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (mediaQuery == null) {
                    mediaQuery = MediaQuery.of(context);
                    itemHeight = (mediaQuery!.size.height -
                            mediaQuery!.displayFeatures[0].bounds.bottom) /
                        _colors.length;
                  }
                  return XKey(
                    height: itemHeight,
                    backgroundColor: _colors[index],
                    noteNumber: (index + 1),
                    index: index,
                  );
                },
                childCount: _colors.length,
              ),
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
    );
  }
}
