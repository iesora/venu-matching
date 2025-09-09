import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../loginState.dart';
import 'package:provider/provider.dart';
import 'dart:async';
// import 'dart:math';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;
    // final counter = useState(0); // 状態の初期化
    // SpeechToTextインスタンスを管理
    final speechToText = useMemoized(() => stt.SpeechToText(), []);
    final isListening = useState(false);
    final text = useState('Press the button to start speaking');
    final answer = useState("");
    final available = useState(false);
    final markers = <Marker>{
      const Marker(
        markerId: MarkerId('tokyo-station'),
        position: LatLng(35.681236, 139.767125),
        infoWindow: InfoWindow(title: '東京駅'),
      ),
    };

    useEffect(() {
      // 音声認識の初期化
      Future.microtask(() async {
        available.value = await speechToText.initialize(
          onStatus: (status) => print('Status: $status'),
          onError: (error) => print('Error: $error'),
        );
      });
      return;
    }, []);

    void startListening() async {
      if (available.value && !isListening.value) {
        print('ログメッセージ: Hello, Flutter!');
        isListening.value = true;
        await speechToText.listen(
          onResult: (result) {
            text.value = result.recognizedWords;
          },
        );
      }
    }

    void stopListening() async {
      if (isListening.value) {
        await speechToText.stop();
        isListening.value = false;
      }
    }

    // FlutterTts インスタンスを作成
    final flutterTts = useMemoized(() => FlutterTts());
    // final textController = useTextEditingController();

    // TTSの初期設定
    useEffect(() {
      flutterTts.setLanguage("ja-JP"); // 日本語を設定
      flutterTts.setSpeechRate(1); // 読み上げ速度
      flutterTts.setPitch(1.0); // 音程
      return flutterTts.stop; // Widget破棄時にTTSを停止
    }, []);

    Future<void> sendData(String message) async {
      final url = Uri.parse("${dotenv.get('API_URL')}/");

      try {
        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'message': message}));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.body;

          answer.value = data;

          await flutterTts.speak(data);
          // await flutterTts.speak(response.body.message);
        } else {
          print('エラー: ${response.statusCode}');
        }
      } catch (e) {
        print('例外が発生しました: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              text.value,
              style: const TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isListening.value ? stopListening : startListening,
              child: Text(
                  isListening.value ? 'Stop Listening' : 'Start Listening'),
            ),
            const SizedBox(height: 20),
            Text(
              answer.value,
              style: const TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // await flutterTts.speak(text.value);
                await sendData(text.value);
                //await sendData();
                // await sendMessage("りんごについておしえてください");
              },
              child: Text("AIに質問する"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                //await flutterTts.speak(text.value);
                await flutterTts.stop();
                // await sendMessage("りんごについておしえてください");
              },
              child: Text("音声ストップ"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(35.681236, 139.767125),
                  zoom: 14.0,
                ),
                markers: markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            {Provider.of<LoginState>(context, listen: false).login()}, // 状態の更新
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
