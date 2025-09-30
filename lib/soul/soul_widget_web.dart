import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'soul_states.dart';

class SoulRenderer extends StatefulWidget {
  final SoulConfig config;

  const SoulRenderer({super.key, required this.config});

  @override
  State<SoulRenderer> createState() => _SoulRendererState();
}

class _SoulRendererState extends State<SoulRenderer> {
  late final String _viewType;
  late final html.IFrameElement _iframe;
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  bool _isReady = false;
  SoulConfig? _pendingConfig;
  SoulConfig? _lastPostedConfig;

  @override
  void initState() {
    super.initState();

    _viewType = 'soul-view-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';

    _iframe = html.IFrameElement()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'transparent'
      ..style.pointerEvents = widget.config.disableInteraction ? 'none' : 'auto'
      ..src = 'awa_soul/index.html';

    _messageSubscription = html.window.onMessage.listen(_handleMessage);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );

    _syncState(widget.config, force: widget.config.immediate);
  }

  @override
  void didUpdateWidget(covariant SoulRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.config.disableInteraction != widget.config.disableInteraction) {
      _iframe.style.pointerEvents = widget.config.disableInteraction ? 'none' : 'auto';
    }

    if (oldWidget.config.state != widget.config.state ||
        oldWidget.config.autoCycle != widget.config.autoCycle ||
        widget.config.immediate) {
      _syncState(widget.config, force: widget.config.immediate);
    }
  }

  void _handleMessage(html.MessageEvent event) {
    final data = event.data;
    if (data is! Map) {
      return;
    }

    final type = data['type'];
    if (type is! String) {
      return;
    }

    if (type == 'AWA_SOUL_READY') {
      _isReady = true;
      final config = _pendingConfig ?? widget.config;
      _pendingConfig = null;
      _syncState(config, force: true);
    } else if (type == 'AWA_SOUL_INIT') {
      // iframe booted but not ready yet
      _pendingConfig = widget.config;
    }
  }

  void _syncState(SoulConfig config, {bool force = false}) {
    if (!_isReady) {
      _pendingConfig = config;
      return;
    }

    final stateName = _mapState(config.state);
    final shouldSendState = force ||
        _lastPostedConfig == null ||
        _lastPostedConfig!.state != config.state ||
        config.immediate;
    final shouldSendAutoCycle = force ||
        _lastPostedConfig == null ||
        _lastPostedConfig!.autoCycle != config.autoCycle;

    if (shouldSendState) {
      _postMessage({
        'type': 'AWA_SOUL_SET_STATE',
        'state': stateName,
        'immediate': config.immediate,
      });
    }

    if (shouldSendAutoCycle) {
      _postMessage({
        'type': 'AWA_SOUL_SET_AUTOCYCLE',
        'enabled': config.autoCycle,
      });
    }

    _lastPostedConfig = config;
  }

  void _postMessage(Map<String, Object?> message) {
    try {
      _iframe.contentWindow?.postMessage(message, '*');
    } catch (error) {
      debugPrint('SoulRenderer: Failed to post message $message ($error)');
    }
  }

  String _mapState(SoulState state) {
    switch (state) {
      case SoulState.light:
        return 'light';
      case SoulState.human:
        return 'human';
      case SoulState.mask:
        return 'mask';
      case SoulState.globe:
        return 'globe';
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _isReady = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
