import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'event/eventDetail.dart'; // イベント詳細画面のインポート

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = useState<List<dynamic>>([]);
    final currentCameraPosition = useState<CameraPosition>(
      const CameraPosition(
        target: LatLng(35.681236, 139.767125),
        zoom: 14.0,
      ),
    );
    final mapController = useRef<GoogleMapController?>(null);

    useEffect(() {
      Future.microtask(() async {
        final response =
            await http.get(Uri.parse('${dotenv.get('API_URL')}/event/list'));
        if (response.statusCode == 200) {
          events.value = json.decode(response.body);
        } else {
          print('Failed to load events');
        }
      });
      return;
    }, []);
    // final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;
    // final counter = useState(0); // 状態の初期化
    // SpeechToTextインスタンスを管理
    final speechToText = useMemoized(() => stt.SpeechToText(), []);
    final isListening = useState(false);
    final text = useState('Press the button to start speaking');
    final answer = useState("");
    final available = useState(false);
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    // イベントの会場位置からマーカー集合を生成
    final Set<Marker> markers = () {
      final result = <Marker>{};
      for (final event in events.value) {
        final venue = event['venue'];
        if (venue == null) continue;
        final double? lat = toDouble(venue['latitude']);
        final double? lng = toDouble(venue['longitude']);
        if (lat == null || lng == null) continue;
        final String id = (event['id']?.toString() ?? UniqueKey().toString());
        result.add(
          Marker(
            markerId: MarkerId('event-$id'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: (event['title'] ?? '').toString(),
              snippet: (venue['name'] ?? '').toString(),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(eventId: event['id']),
                ),
              );
            },
          ),
        );
      }
      return result;
    }();

    useEffect(() {
      Future.microtask(() async {
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            // 位置情報サービスが無効の場合は何もしない（初期値を維持）
            return;
          }

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            // 権限が無い場合は初期値を維持
            return;
          }

          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          final target = LatLng(position.latitude, position.longitude);
          final newCamera = CameraPosition(target: target, zoom: 14.0);
          currentCameraPosition.value = newCamera;
          if (mapController.value != null) {
            await mapController.value!
                .animateCamera(CameraUpdate.newCameraPosition(newCamera));
          }
        } catch (_) {
          // noop: 現在地取得失敗時は初期値のまま
        }
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
      backgroundColor: Colors.white, // 画面自体の背景を白に設定
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              child: GoogleMap(
                initialCameraPosition: currentCameraPosition.value,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  mapController.value = controller;
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: events.value.length,
                itemBuilder: (context, index) {
                  final event = events.value[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailScreen(eventId: event['id']),
                        ),
                      );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '開催中',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    event['title'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    event['venue']['name'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4.0),
                                bottomRight: Radius.circular(4.0),
                              ),
                              child: Image.network(
                                event['imageUrl'],
                                fit: BoxFit.cover,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 120,
                                    alignment: Alignment.center,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      // color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
