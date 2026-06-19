import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PlatformGameView extends StatefulWidget {
  final String url;
  const PlatformGameView({super.key, required this.url});

  @override
  State<PlatformGameView> createState() => _PlatformGameViewState();
}

class _PlatformGameViewState extends State<PlatformGameView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'game-iframe-${identityHashCode(this)}';
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..width = '100%'
          ..height = '100%'
          ..allow = 'fullscreen';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
