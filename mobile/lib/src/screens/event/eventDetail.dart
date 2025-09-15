import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'event_creators_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  EventDetailScreen({required this.eventId});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, dynamic>? eventDetail;
  bool isLoading = true;

  String _formatDateTime(dynamic value) {
    if (value == null) return '';
    try {
      final dt = DateTime.parse(value.toString()).toLocal();
      return DateFormat('yyyy/MM/dd HH:mm').format(dt);
    } catch (_) {
      return value.toString();
    }
  }

  Widget _buildHeroImage() {
    final imageUrl = eventDetail!['imageUrl'];
    final title = eventDetail!['title'] ?? 'イベント名なし';
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: imageUrl != null && imageUrl != ''
              ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image, size: 40)),
                ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfoCard() {
    final start = _formatDateTime(eventDetail!['startDate']);
    final end = _formatDateTime(eventDetail!['endDate']);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.schedule, color: Colors.deepOrangeAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    start != '' && end != '' ? '$start 〜 $end' : '日時未定',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard() {
    final venue = eventDetail!['venue'];
    if (venue == null) return const SizedBox.shrink();

    final String name = venue['name'] ?? '会場名未設定';
    final String? vImage = venue['imageUrl'];
    final String? address = venue['address'];
    final String? tel = venue['tel'];
    final int? capacity = venue['capacity'];
    final String? availableTime = venue['availableTime'];
    final String? vDescription = venue['description'];
    final String? facilities = venue['facilities'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '会場情報',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: vImage != null && vImage != ''
                        ? Image.network(
                            vImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.apartment),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.apartment),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (address != null && address != '')
                        Text(
                          address,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (tel != null && tel != '')
              _buildInfoRow(Icons.call, 'TEL: $tel'),
            if (capacity != null)
              _buildInfoRow(Icons.groups, '収容人数: $capacity'),
            if (availableTime != null && availableTime != '')
              _buildInfoRow(Icons.access_time, '利用時間: $availableTime'),
            if (facilities != null && facilities != '')
              _buildInfoRow(Icons.handyman, '設備: $facilities'),
            if (vDescription != null && vDescription != '')
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  vDescription,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final description = eventDetail!['description'] ?? '説明なし';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'イベント概要',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorsSection() {
    final List<dynamic>? creatorEvents =
        (eventDetail!['creatorEvents'] as List?)?.cast<dynamic>();
    if (creatorEvents == null || creatorEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = creatorEvents
        .map(
            (e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '参加クリエイター',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventCreatorsScreen(
                          eventId: widget.eventId,
                          eventTitle: eventDetail!['title'] ?? 'イベント',
                          initialCreatorEvents: creatorEvents,
                        ),
                      ),
                    );
                  },
                  child: const Text('すべて見る'),
                )
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                final creator = item['creator'];
                if (creator == null) return const SizedBox.shrink();
                final String name = creator['name'] ?? '未設定';
                final String? image = creator['imageUrl'];
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: image != null && image != ''
                        ? NetworkImage(image)
                        : null,
                    child: image == null || image == ''
                        ? const Icon(Icons.person,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                  label: Text(name),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchEventDetail();
  }

  Future<void> fetchEventDetail() async {
    final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/event/detail/${widget.eventId}'));

    if (response.statusCode == 200) {
      setState(() {
        eventDetail = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // エラーハンドリング
      setState(() {
        isLoading = false;
      });
      throw Exception('イベント詳細の取得に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント詳細'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventDetail != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroImage(),
                      _buildEventInfoCard(),
                      _buildVenueCard(),
                      _buildDescriptionCard(),
                      _buildCreatorsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                )
              : const Center(child: Text('イベント詳細が見つかりません')),
    );
  }
}
