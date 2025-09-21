import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile/src/screens/event/event_creators_screen.dart'; // EventCreatorsScreenのインポート

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal, // 変更: QRコードが映った瞬間に発火するように
    facing: CameraFacing.back,
  );

  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  String? _lastRawValue;

  void _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  void _switchCamera() async {
    await _controller.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードスキャン'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final value = barcodes.first.rawValue;
              if (value == null) return;

              if (_lastRawValue == value) return; // 同じ値の重複検出を防止
              _lastRawValue = value;

              // QRコードが読み取られたらEventCreatorsScreenに遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventCreatorsScreen(
                    eventId: 1, // QRコードの値をeventIdとして渡す
                    eventTitle: 'イベント', // 仮のタイトル
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'torch',
                    onPressed: _toggleTorch,
                    child: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton.small(
                    heroTag: 'switch',
                    onPressed: _switchCamera,
                    child: Icon(_isFrontCamera
                        ? Icons.camera_rear
                        : Icons.camera_front),
                  ),
                ],
              ),
            ),
          ),
          // 目安のスキャン枠（装飾）
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
