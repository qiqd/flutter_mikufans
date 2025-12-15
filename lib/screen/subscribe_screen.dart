import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mikufans/component/media_card.dart';
import 'package:mikufans/entity/history.dart';
import 'package:mikufans/util/store_util.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  List<History> histories = [];
  @override
  void initState() {
    super.initState();
    histories = Store.getLocalHistory();
    setState(() {
      histories = histories.where((item) => item.isLove).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('subscribe_screen'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0) {
          setState(() {
            histories = Store.getLocalHistory();
            histories = histories.where((item) => item.isLove).toList();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          title: const Text('追番'),
        ),
        body: ListView.builder(
          itemCount: histories.length,
          itemBuilder: (content, index) {
            return MediaCard(
              height: 260,
              media: histories[index].media,
              isLove: true,
              onTap: (work) {
                content.push("/detail", extra: work.id);
              },
            );
          },
        ),
      ),
    );
  }
}
