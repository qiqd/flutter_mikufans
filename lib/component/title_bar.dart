import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatelessWidget {
  final Color backgroundColor;
  const TitleBar({super.key, this.backgroundColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25, top: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('lib/images/icon_linux.png', height: 30),
                ),
              ),
              Spacer(),
              IconButton(
                tooltip: "最小化",
                onPressed: () => windowManager.minimize(),
                icon: Icon(Icons.minimize_rounded),
              ),
              IconButton(
                tooltip: "最大化",
                onPressed: () => windowManager.maximize(),
                icon: Icon(Icons.crop_square_rounded),
              ),
              IconButton(
                tooltip: "关闭",
                hoverColor: Colors.red,
                onPressed: () => windowManager.close(),
                icon: Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
