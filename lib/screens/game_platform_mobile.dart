import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

class PlatformGameView extends StatefulWidget {
  final String url;
  const PlatformGameView({super.key, required this.url});

  @override
  State<PlatformGameView> createState() => _PlatformGameViewState();
}

class _PlatformGameViewState extends State<PlatformGameView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _loadingProgress = 0;
              });
            }
            _startTimeout();
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          onPageFinished: (_) {
            _cancelTimeout();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            }
          },
          onWebResourceError: (error) {
            _cancelTimeout();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _startTimeout();
  }

  void _startTimeout() {
    _cancelTimeout();
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _reload() {
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    _cancelTimeout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) _buildLoading(),
        if (_hasError && !_isLoading) _buildError(),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/imagen_de_fondo.png',
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando juego...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'EcoRecicla',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
              backgroundColor: AppColors.green100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No se pudo cargar el juego',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifica que el servidor del juego\nesté ejecutándose en tu PC',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
