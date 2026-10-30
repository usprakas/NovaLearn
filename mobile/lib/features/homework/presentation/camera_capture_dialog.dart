import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// In-app camera for desktop browsers. Phone browsers open their native camera from a file input,
/// but desktop browsers ignore that hint and show a file picker instead — so "Take a photo" there
/// uses the webcam directly (the browser asks the user for camera permission first).
/// Returns the captured image bytes, or null if cancelled.
Future<Uint8List?> showCameraCaptureDialog(BuildContext context) =>
    showDialog<Uint8List>(context: context, builder: (_) => const _CameraCaptureDialog());

class _CameraCaptureDialog extends StatefulWidget {
  const _CameraCaptureDialog();

  @override
  State<_CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<_CameraCaptureDialog> {
  CameraController? _controller;
  String? _error;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        _fail("We couldn't find a camera on this device. Try \"Choose a photo\" instead.");
        return;
      }
      final CameraDescription camera = cameras.firstWhere(
          (CameraDescription c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first);
      final CameraController controller =
          CameraController(camera, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      _fail(e.code.toLowerCase().contains('permission') || e.code.contains('NotAllowed')
          ? 'Camera access was blocked. Allow the camera in your browser settings, or choose a photo instead.'
          : "The camera couldn't start. Try \"Choose a photo\" instead.");
    } catch (_) {
      _fail("The camera couldn't start. Try \"Choose a photo\" instead.");
    }
  }

  void _fail(String message) {
    if (mounted) setState(() => _error = message);
  }

  Future<void> _capture() async {
    final CameraController? controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final XFile file = await controller.takePicture();
      final Uint8List bytes = await file.readAsBytes();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
      _fail("We couldn't take the photo. Please try again.");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? controller = _controller;
    return AlertDialog(
      title: const Text('Take a photo of the question'),
      content: SizedBox(
        width: 560,
        child: _error != null
            ? Text(_error!)
            : controller == null
                ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                : Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller)),
                    ),
                    const SizedBox(height: 8),
                    Text('Hold the worksheet steady so the question fills the frame.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        if (_error == null)
          FilledButton.icon(
            onPressed: controller == null || _capturing ? null : _capture,
            icon: const Icon(Icons.photo_camera),
            label: Text(_capturing ? 'Capturing…' : 'Capture'),
          ),
      ],
    );
  }
}
