import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mikufans/component/media_card.dart';
import 'package:mikufans/entity/history.dart';
import 'package:mikufans/util/store.dart';

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
    return Scaffold(
      body: ListView.builder(
        itemCount: histories.length,
        itemBuilder: (content, index) {
          return MediaCard(
            media: histories[index].media,
            isLove: true,
            onTap: (work) {
              content.push("/detail", extra: work.id);
            },
          );
        },
      ),
    );
  }
}
