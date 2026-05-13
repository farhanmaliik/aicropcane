// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

/// Shows a camera dialog using the browser's getUserMedia API.
/// Live preview rendered via periodic canvas→Image.memory frames
/// (avoids HtmlElementView which doesn't show inside Flutter dialogs).
Future<Uint8List?> showWebCameraDialog(BuildContext context) async {
  return await showDialog<Uint8List>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _WebCameraDialog(),
  );
}

class _WebCameraDialog extends StatefulWidget {
  const _WebCameraDialog();

  @override
  State<_WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<_WebCameraDialog> {
  html.VideoElement? _video;
  html.MediaStream? _stream;
  Timer? _frameTimer;
  Uint8List? _currentFrame;
  bool _cameraReady = false;
  bool _cameraError = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    _video = html.VideoElement()..autoplay = true..muted = true;
    // Attach to a hidden off-screen div so the browser actually streams video
    final div = html.DivElement()
      ..style.position = 'fixed'
      ..style.top = '-9999px'
      ..style.left = '-9999px'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.opacity = '0';
    div.append(_video!);
    html.document.body!.append(div);

    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'user', 'width': 640, 'height': 480},
        'audio': false,
      });
      _stream = stream;
      _video!.srcObject = stream;
      await _video!.play();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _cameraReady = true);
      // ~10fps preview
      _frameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _grabFrame());
    } catch (_) {
      if (mounted) setState(() => _cameraError = true);
    }
  }

  void _grabFrame() {
    final v = _video;
    if (v == null || !mounted || v.videoWidth == 0) return;
    try {
      final c = html.CanvasElement(width: v.videoWidth, height: v.videoHeight);
      c.context2D.drawImage(v, 0, 0);
      final bytes = base64Decode(c.toDataUrl('image/jpeg', 0.6).split(',').last);
      if (mounted) setState(() => _currentFrame = bytes);
    } catch (_) {}
  }

  Uint8List? _capture() {
    final v = _video;
    if (v == null || v.videoWidth == 0) return null;
    try {
      final c = html.CanvasElement(width: v.videoWidth, height: v.videoHeight);
      c.context2D.drawImage(v, 0, 0);
      return base64Decode(c.toDataUrl('image/jpeg', 0.92).split(',').last);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _stream?.getTracks().forEach((t) => t.stop());
    _video?.parent?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 460,
        height: 490,
        child: Column(
          children: [
            // ── Title bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
              child: Row(children: [
                const Text('Take Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context, null),
                  icon: const Icon(Icons.close),
                ),
              ]),
            ),

            // ── Camera preview ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.black,
                    child: _cameraError
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.no_photography,
                                    size: 52, color: Colors.white54),
                                SizedBox(height: 10),
                                Text(
                                  'Camera access denied or not available.\nAllow camera in browser settings.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          )
                        : !_cameraReady || _currentFrame == null
                            ? const Center(
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 12),
                                  Text('Starting camera...',
                                      style: TextStyle(color: Colors.white54)),
                                ]))
                            : Image.memory(
                                _currentFrame!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                gaplessPlayback: true,
                              ),
                  ),
                ),
              ),
            ),

            // ── Buttons ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_cameraReady && _currentFrame != null)
                        ? () {
                            final bytes = _capture();
                            Navigator.pop(context, bytes);
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Capture',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
