import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Простой экран для съёмки фото с камеры.
class CameraPickerScreen extends StatefulWidget {
  const CameraPickerScreen({super.key});

  @override
  State<CameraPickerScreen> createState() => _CameraPickerScreenState();
}

class _CameraPickerScreenState extends State<CameraPickerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'Камера не найдена';
        });
        return;
      }

      // Выбираем основную (заднюю) камеру
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } on Exception catch (e) {
      setState(() {
        _error = 'Ошибка инициализации камеры: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      // Копируем файл во временную директорию с уникальным именем
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/camera_$timestamp.jpg';
      await File(image.path).copy(path);

      final xFile = XFile(path);

      if (!mounted) return;

      Navigator.of(context).pop(xFile);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при съёмке: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Камера')),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    if (_controller == null || _initializeControllerFuture == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сделать снимок'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
