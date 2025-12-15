import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mikufans/component/media_card.dart';
import 'package:mikufans/entity/history.dart';
import 'package:mikufans/util/store_util.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<History> histories = Store.getLocalHistory();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('history_screen'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0) {
          setState(() {
            histories = Store.getLocalHistory();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          title: const Text('播放历史'),
          actions: [
            IconButton(
              tooltip: '清除所有播放历史',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('确认清除播放历史吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            Store.clearLocalHistory();
                            histories.clear();
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text('确认'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final h = histories[index];
            return MediaCard(
              height: 260,
              media: h.media,
              lastViewAt: h.lastViewAt,
              episodeIndex: h.episodeIndex + 1,
              onTap: (m) {
                context.push("/detail", extra: m.id);
              },
            );
          },
        ),
      ),
    );
  }
}
