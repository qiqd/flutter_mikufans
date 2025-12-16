import 'dart:math';

import 'package:canvas_danmaku/canvas_danmaku.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    with SingleTickerProviderStateMixin, WindowListener {
  late final player = Player();
  final aafun = AafunParser();
  late final controller = VideoController(player);

  late final tabController = TabController(
    vsync: this,
    length: widget.detail.sources.length,
  );

  late int currentSourceIndex = 0;
  DanmakuController? _dammakuController;
  late ValueNotifier<int> currentEpisodeIndex = ValueNotifier<int>(
    widget.episodeIndex,
  );
  ValueNotifier<double> currentSpeed = ValueNotifier<double>(1.0);
  Duration _currentPosition = Duration.zero;
  Duration _historyPosition = Duration.zero;
  bool isFullscreen = false;
  bool _showAside = false;
  bool isBuffering = false;
  bool _autoPlay = false;
  String mediaUrl = "";
  String errorMsg = "";
  bool isLoading = false;

  void _loadDanmaku() async {
    //todo 弹幕功能实现，2025-12-16 18:31:08
    await Future.delayed(Duration(seconds: 2));
    if (_dammakuController == null) return;
    for (var i = 0; ; i++) {
      await Future.delayed(Duration(seconds: 5));
      _dammakuController?.addDanmaku(
        DanmakuContentItem(
          "测试弹幕$i",
          color: Color.fromARGB(
            255,
            Random().nextInt(256),
            Random().nextInt(256),
            Random().nextInt(256),
          ),
        ),
      );
    }
  }

  void initPlayerInfo({Duration initPosition = Duration.zero}) async {
    errorMsg = "";
    isLoading = true;
    final info = await aafun.fetchView(
      widget
          .detail
          .sources[currentSourceIndex]
          .episodes[widget.episodeIndex]
          .id!,
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
        errorMsg = "获取播放地址失败,试着切换其他源";
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
    _autoPlay = Store.getBool('auto_play');
    final histories = Store.getLocalHistory();
    final history = histories
        .where((h) => h.media.id == widget.detail.media.id)
        .firstOrNull;
    if (history != null) {
      setState(() {
        // currentEpisodeIndex.value = widget.episodeIndex;
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

  void _initPlayerListener() {
    player.stream.completed.listen((completed) {
      if (completed &&
          _autoPlay &&
          currentEpisodeIndex.value + 1 <
              widget.detail.sources[currentSourceIndex].episodes.length) {
        setState(() {
          currentEpisodeIndex.value++;
          initPlayerInfo(initPosition: Duration.zero);
        });
      }
    });
    player.stream.playing.listen((playing) {
      if (playing) {
        _dammakuController?.resume();
      } else {
        _dammakuController?.pause();
      }
    });
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
  void onWindowBlur() {
    _saveHistory();
    super.onWindowBlur();
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initPlayerListener();
    _loadHistory();
    initPlayerInfo(initPosition: _historyPosition);
    // _loadDanmaku();
  }

  @override
  void dispose() {
    _saveHistory();
    windowManager.removeListener(this);
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
            toggleFullscreenOnDoublePress: false,
            playAndPauseOnTap: true,
            seekBarContainerHeight: 50,
            seekBarThumbSize: 20,
            hideMouseOnControlsRemoval: true,
            keyboardShortcuts: {
              SingleActivator(LogicalKeyboardKey.escape): () {
                setState(() {
                  isFullscreen = false;
                });
                windowManager.setFullScreen(false);
              },
              SingleActivator(LogicalKeyboardKey.keyF): () {
                setState(() {
                  isFullscreen = !isFullscreen;
                });
                windowManager.setFullScreen(isFullscreen);
              },
              SingleActivator(LogicalKeyboardKey.space): () {
                player.playOrPause();
              },
              SingleActivator(LogicalKeyboardKey.arrowRight): () {
                player.seek(_currentPosition + Duration(seconds: 5));
              },
              SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                player.seek(_currentPosition - Duration(seconds: 5));
              },
              SingleActivator(LogicalKeyboardKey.arrowDown): () {
                player.setVolume(player.state.volume - 5);
              },
              SingleActivator(LogicalKeyboardKey.arrowUp): () {
                player.setVolume(player.state.volume + 5);
              },
            },
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: MaterialDesktopPositionIndicator(),
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

              //todo 实现倍速切换
              ValueListenableBuilder(
                valueListenable: currentSpeed,
                builder: (context, value, child) {
                  return PopupMenuButton(
                    tooltip: "播放速度",
                    initialValue: 1.0,
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 0.5,
                          child: Text('0.5x'),
                          onTap: () {
                            setState(() {
                              currentSpeed.value = 0.5;
                            });
                            player.setRate(0.5);
                          },
                        ),
                        PopupMenuItem(
                          value: 0.75,
                          child: Text('0.75x'),
                          onTap: () {
                            setState(() {
                              currentSpeed.value = 0.75;
                            });
                            player.setRate(0.75);
                          },
                        ),
                        PopupMenuItem(
                          value: 1.0,
                          child: Text('1.0x'),
                          onTap: () {
                            setState(() {
                              currentSpeed.value = 1.0;
                            });
                            player.setRate(1.0);
                          },
                        ),
                        PopupMenuItem(
                          value: 1.25,
                          child: Text('1.25x'),
                          onTap: () {
                            setState(() {
                              currentSpeed.value = 1.25;
                            });
                            player.setRate(1.25);
                          },
                        ),
                        PopupMenuItem(
                          value: 1.5,
                          child: Text('1.5x'),
                          onTap: () {
                            setState(() {
                              currentSpeed.value = 1.5;
                            });
                            player.setRate(1.5);
                          },
                        ),
                        PopupMenuItem(
                          value: 2.0,
                          child: Text('2.0x'),
                          onTap: () {
                            setState(() {
                              currentSpeed.value = 2.0;
                            });
                            player.setRate(2.0);
                          },
                        ),
                      ];
                    },
                    child: Badge(
                      backgroundColor: Colors.transparent,
                      label: Text(value.toString()),
                      child: IconButton(
                        icon: Icon(Icons.speed_rounded, color: Colors.white),
                        onPressed: null,
                      ),
                    ),
                  );
                },
              ),
              MaterialDesktopVolumeButton(),

              Spacer(),
              IconButton(
                tooltip: "全屏",
                onPressed: () {
                  setState(() {
                    isFullscreen = !isFullscreen;
                    windowManager.setFullScreen(isFullscreen);
                  });
                },
                icon: Icon(
                  isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          fullscreen: const MaterialDesktopVideoControlsThemeData(),
          child: Scaffold(
            body: Stack(
              children: [
                // 视频层
                Video(controller: controller),
                // 弹幕层
                DanmakuScreen(
                  createdController: (e) {
                    _dammakuController = e;
                  },
                  option: DanmakuOption(),
                ),
              ],
            ),
          ),
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
