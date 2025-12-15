import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mikufans/component/media_card.dart';
import 'package:mikufans/entity/detail.dart';
import 'package:mikufans/entity/history.dart';
import 'package:mikufans/entity/source.dart';
import 'package:mikufans/service/impl/aafun.dart';
import 'package:mikufans/util/store_util.dart';
import 'package:window_manager/window_manager.dart';

class PlayerScreen extends StatefulWidget {
  final Detail detail;
  final int episodeIndex;
  final Source source;

  const PlayerScreen({
    super.key,
    required this.detail,
    required this.episodeIndex,
    required this.source,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late final player = Player();
  final aafun = AafunParser();
  late final controller = VideoController(player);
  late final tabController = TabController(
    vsync: this,
    length: widget.detail.sources.length,
  );
  //late int currentEpisodeIndex = widget.episodeIndex;
  late int currentSourceIndex = 0;

  ValueNotifier<int> currentEpisodeIndex = ValueNotifier<int>(0);
  Duration _currentPosition = Duration.zero;
  Duration _historyPosition = Duration.zero;
  bool isFullscreen = false;
  bool _showAside = false;
  bool isBuffering = false;

  String mediaUrl = "";
  String errorMsg = "";
  bool isLoading = false;

  void initPlayerInfo({Duration initPosition = Duration.zero}) async {
    errorMsg = "";
    isLoading = true;
    final info = await aafun.fetchView(
      widget.source.episodes[currentEpisodeIndex.value].id!,
      (err) {
        setState(() {
          errorMsg = err.toString();
        });
      },
    );
    if (info != null && info.urls.isNotEmpty) {
      mediaUrl = info.urls[0];
      player.open(Media(mediaUrl));
      player.stream.duration
          .firstWhere((duration) => duration > Duration.zero)
          .then((_) {
            if (_historyPosition > Duration.zero) {
              player.seek(initPosition);
            }
          });
    } else {
      setState(() {
        errorMsg = "获取播放地址失败";
      });
    }
    isLoading = false;
  }

  void episodeChangeHandle(int newSourceIndex, int newEpisodeIndex) {
    if (isLoading) return;
    setState(() {
      currentEpisodeIndex.value = newEpisodeIndex;
      currentSourceIndex = newSourceIndex;
      mediaUrl =
          widget.detail.sources[newSourceIndex].episodes[newEpisodeIndex].id!;
    });
    initPlayerInfo();
  }

  void _loadHistory() {
    final histories = Store.getLocalHistory();
    final history = histories
        .where((h) => h.media.id == widget.detail.media.id)
        .firstOrNull;
    if (history != null) {
      setState(() {
        currentEpisodeIndex.value = history.episodeIndex;
        _historyPosition = Duration(milliseconds: history.lastViewPosition);
      });
    }
  }

  void _saveHistory() {
    final history = History(
      media: widget.detail.media,
      episodeIndex: currentEpisodeIndex.value,
      lastViewPosition: _currentPosition.inMilliseconds,
      lastViewAt: DateTime.now(),
    );
    final histories = Store.getLocalHistory();
    histories.add(history);
    Store.setLocalHistory(histories);
  }

  void _listenPlayer() {
    player.stream.buffering.listen(
      (buffering) => setState(() {
        isBuffering = buffering;
      }),
    );
    player.stream.error.listen(
      (err) => setState(() {
        errorMsg = err.toString();
      }),
    );
    //监听进度变化
    player.stream.position.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _listenPlayer();
    _loadHistory();
    initPlayerInfo(initPosition: _historyPosition);
  }

  @override
  void dispose() {
    _saveHistory();
    tabController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MaterialDesktopVideoControlsTheme(
          normal: MaterialDesktopVideoControlsThemeData(
            automaticallyImplySkipNextButton: false,
            automaticallyImplySkipPreviousButton: false,
            seekBarThumbColor: Theme.of(context).primaryColor,
            seekBarPositionColor: Theme.of(context).primaryColor,
            toggleFullscreenOnDoublePress: true,
            playAndPauseOnTap: true,
            seekBarContainerHeight: 50,
            seekBarThumbSize: 20,
            topButtonBar: [
              Expanded(
                child: GestureDetector(
                  onPanStart: (_) => windowManager.startDragging(),
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: "返回",
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.detail.media.titleCn ??
                              widget.detail.media.title ??
                              "暂无标题",
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            primaryButtonBar: [],
            bottomButtonBar: [
              IconButton(
                tooltip: "上一个",
                onPressed: () {
                  if (currentEpisodeIndex.value > 0 && !isLoading) {
                    setState(() {
                      currentEpisodeIndex.value--;
                      initPlayerInfo();
                    });
                  }
                },
                icon: Icon(Icons.skip_previous_rounded, color: Colors.white),
              ),
              MaterialDesktopPlayOrPauseButton(),
              IconButton(
                tooltip: "下一个",
                onPressed: () {
                  if (currentEpisodeIndex.value <
                          widget.source.episodes.length - 1 &&
                      !isLoading) {
                    setState(() {
                      currentEpisodeIndex.value++;
                      initPlayerInfo();
                    });
                  }
                },
                icon: Icon(Icons.skip_next_rounded, color: Colors.white),
              ),
              ValueListenableBuilder(
                valueListenable: currentEpisodeIndex,
                builder: (context, value, child) {
                  return Badge(
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    label: Text((value + 1).toString()),
                    child: IconButton(
                      tooltip: "播放列表",
                      onPressed: () {
                        setState(() {
                          _showAside = !_showAside;
                        });
                      },
                      icon: Icon(
                        Icons.playlist_play_rounded,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              MaterialDesktopVolumeButton(),
              Spacer(),
              MaterialDesktopFullscreenButton(),
            ],
          ),
          fullscreen: MaterialDesktopVideoControlsThemeData(
            automaticallyImplySkipNextButton: false,
            automaticallyImplySkipPreviousButton: false,
            seekBarThumbColor: Theme.of(context).primaryColor,
            seekBarPositionColor: Theme.of(context).primaryColor,
            toggleFullscreenOnDoublePress: true,
            playAndPauseOnTap: true,
            seekBarContainerHeight: 50,
            seekBarThumbSize: 20,
            topButtonBar: [
              Expanded(
                child: GestureDetector(
                  onPanStart: (_) => windowManager.startDragging(),
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          widget.detail.media.titleCn ??
                              widget.detail.media.title ??
                              "暂无标题",
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            primaryButtonBar: [],
            bottomButtonBar: [
              IconButton(
                tooltip: "上一个",
                onPressed: () {
                  if (currentEpisodeIndex.value > 0 && !isLoading) {
                    setState(() {
                      currentEpisodeIndex.value--;
                      initPlayerInfo();
                    });
                  }
                },
                icon: Icon(Icons.skip_previous_rounded, color: Colors.white),
              ),
              MaterialDesktopPlayOrPauseButton(),
              IconButton(
                tooltip: "下一个",
                onPressed: () {
                  if (currentEpisodeIndex.value <
                          widget.source.episodes.length - 1 &&
                      !isLoading) {
                    setState(() {
                      currentEpisodeIndex.value++;
                      initPlayerInfo();
                    });
                  }
                },
                icon: Icon(Icons.skip_next_rounded, color: Colors.white),
              ),

              MaterialDesktopVolumeButton(),
              Spacer(),
              MaterialDesktopFullscreenButton(),
            ],
          ),
          child: Scaffold(body: Video(controller: controller)),
        ),
        AnimatedPositioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          bottom: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: _showAside ? 0 : -MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showAside = false),
                  child: Container(color: Colors.transparent),
                ),
              ),
              SizedBox(
                width: 500,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MediaCard(
                          showSummary: false,
                          height: 280,
                          media: widget.detail.media,
                          onTap: (e) {},
                        ),
                        Text(
                          "路线列表",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TabBar(
                          controller: tabController,
                          tabs: [
                            ...List.generate(widget.detail.sources.length, (
                              index,
                            ) {
                              return Tab(text: index.toString());
                            }),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                ...List.generate(widget.detail.sources.length, (
                                  sourceIndex,
                                ) {
                                  final episodes = widget
                                      .detail
                                      .sources[sourceIndex]
                                      .episodes;
                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 6, // 每行6个
                                          crossAxisSpacing: 5, // 水平间距
                                          mainAxisSpacing: 5, // 垂直间距
                                          childAspectRatio: 2.0, // 子项宽高比
                                        ),
                                    itemCount: episodes.length,
                                    itemBuilder: (context, episodeIndex) {
                                      return currentEpisodeIndex.value ==
                                                  episodeIndex &&
                                              currentSourceIndex == sourceIndex
                                          ? FilledButton(
                                              onPressed: () {},
                                              child: Text(
                                                (episodeIndex + 1).toString(),
                                              ),
                                            )
                                          : OutlinedButton(
                                              onPressed: () {
                                                episodeChangeHandle(
                                                  sourceIndex,
                                                  episodeIndex,
                                                );
                                              },
                                              child: Text(
                                                (episodeIndex + 1).toString(),
                                              ),
                                            );
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
