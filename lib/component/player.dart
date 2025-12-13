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
import 'package:mikufans/util/store.dart';

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
  late int currentEpisodeIndex = widget.episodeIndex;
  late int currentSourceIndex = 0;
  final FocusNode _focusNode = FocusNode();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  bool isFullscreen = false;

  bool _showAside = false;
  bool isBuffering = false;
  double _volume = 50;
  String mediaUrl = "";
  String errorMsg = "";

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "00:00";

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void initPlayerInfo() async {
    final info = await aafun.fetchView(
      widget.source.episodes[currentEpisodeIndex].id!,
      (err) {
        setState(() {
          errorMsg = err.toString();
        });
      },
    );
    if (info != null && info.urls.isNotEmpty) {
      mediaUrl = info.urls[0];
      player.open(Media(mediaUrl));
      player.seek(_currentPosition);
    } else {
      setState(() {
        errorMsg = "获取播放地址失败";
      });
    }
  }

  void episodeChangeHandle(int newSourceIndex, int newEpisodeIndex) {
    setState(() {
      currentEpisodeIndex = newEpisodeIndex;
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
        currentEpisodeIndex = history.episodeIndex;
        _currentPosition = Duration(milliseconds: history.lastViewPosition);
      });
    }
  }

  void _saveHistory() {
    final history = History(
      media: widget.detail.media,
      episodeIndex: currentEpisodeIndex,
      lastViewPosition: _currentPosition.inMilliseconds,
      lastViewAt: DateTime.now(),
    );
    final histories = Store.getLocalHistory();
    histories.add(history);
    Store.setLocalHistory(histories);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _loadHistory();
    initPlayerInfo();
    // 监听缓冲进度变化
    player.stream.buffer.listen((buffer) {
      if (mounted) {
        setState(() {
          _bufferedPosition = buffer;
        });
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
    // 监听进度变化
    player.stream.position.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // 监听总时长变化
    player.stream.duration.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    print("dispose");
    _saveHistory();
    player.dispose();
    tabController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (value) {
        if (value is! KeyUpEvent) return;
        if (value.logicalKey == LogicalKeyboardKey.escape) {
          _showAside = !_showAside;
          setState(() {});
        }
        if (value.logicalKey == LogicalKeyboardKey.space) {
          player.playOrPause();
          setState(() {});
        }
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (_currentPosition + Duration(seconds: 5) > _totalDuration) {
            return;
          }
          player.seek(player.state.position + Duration(seconds: 5));
          setState(() {
            _currentPosition = player.state.position;
          });
        }
        if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (_currentPosition - Duration(seconds: 5) < Duration.zero) {
            return;
          }
          player.seek(player.state.position - Duration(seconds: 5));
          setState(() {
            _currentPosition = player.state.position;
          });
        }
        if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (player.state.volume + 10 > 100) {
            return;
          }
          player.setVolume(player.state.volume + 10);
          setState(() {
            _volume = player.state.volume.toDouble();
          });
        }
        if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (player.state.volume - 10 < 0) {
            return;
          }
          player.setVolume(player.state.volume - 10);
          setState(() {
            _volume = player.state.volume.toDouble();
          });
        }
      },
      child: Material(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
          child: Video(
            controller: controller,
            controls: (state) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isFullscreen
                              ? Container()
                              : Row(
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showAside = false;
                                player.playOrPause();
                                setState(() {});
                              },
                              onDoubleTap: () {
                                isFullscreen
                                    ? state.exitFullscreen()
                                    : state.enterFullscreen();
                                setState(() {
                                  isFullscreen = !isFullscreen;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.transparent,
                                child: Center(
                                  child: errorMsg.isNotEmpty
                                      ? Text(
                                          errorMsg,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      : isBuffering
                                      ? SizedBox(
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(
                                                  strokeWidth: 4,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "缓冲中...",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : player.state.playing
                                      ? Container()
                                      : const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          // 进度条
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  secondaryTrackValue:
                                      _totalDuration.inMilliseconds > 0
                                      ? _bufferedPosition.inMilliseconds /
                                            _totalDuration.inMilliseconds
                                      : 0.0,
                                  value: _totalDuration.inMilliseconds > 0
                                      ? _currentPosition.inMilliseconds /
                                            _totalDuration.inMilliseconds
                                      : 0.0,
                                  onChanged: (value) {
                                    final newPosition = Duration(
                                      milliseconds:
                                          (value *
                                                  _totalDuration.inMilliseconds)
                                              .round(),
                                    );
                                    setState(() {
                                      isBuffering = true;
                                    });
                                    player.seek(newPosition);
                                    setState(() {
                                      isBuffering = false;
                                    });
                                  },
                                  onChangeStart: (value) {},
                                  onChangeEnd: (value) {},
                                ),
                              ),
                            ],
                          ),
                          // 播放控制按钮
                          Row(
                            children: [
                              IconButton(
                                tooltip: "上一个",
                                onPressed: () {},
                                icon: Icon(
                                  Icons.skip_previous_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                tooltip: "播放/暂停",
                                onPressed: () {
                                  player.playOrPause();
                                  setState(() {});
                                },
                                icon: Icon(
                                  player.state.playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                tooltip: "下一个",
                                onPressed: () {},
                                icon: Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  "${_formatDuration(_currentPosition)}/${_formatDuration(_totalDuration)}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
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

                              //音量调节
                              SizedBox(
                                width: 100,
                                child: Slider(
                                  value: _volume,
                                  max: 100,
                                  min: 0,
                                  onChanged: (value) {
                                    player.setVolume(value);
                                    setState(() {
                                      _volume = value;
                                    });
                                  },
                                ),
                              ),

                              Expanded(child: SizedBox(width: double.infinity)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Badge(
                                  backgroundColor: Colors.transparent,
                                  label: Text(player.state.rate.toString()),
                                  child: PopupMenuButton(
                                    tooltip: "倍速",
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.speed_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onSelected: (value) {
                                      player.setRate(value);
                                      setState(() {});
                                    },
                                    itemBuilder: (context) {
                                      return [
                                        const PopupMenuItem(
                                          value: 2.0,
                                          child: Text("2.0x"),
                                        ),
                                        const PopupMenuItem(
                                          value: 1.5,
                                          child: Text("1.5x"),
                                        ),
                                        const PopupMenuItem(
                                          value: 1.25,
                                          child: Text("1.25x"),
                                        ),
                                        const PopupMenuItem(
                                          value: 1.0,
                                          child: Text("1.0x"),
                                        ),
                                        const PopupMenuItem(
                                          value: 0.75,
                                          child: Text("0.75x"),
                                        ),
                                        const PopupMenuItem(
                                          value: 0.5,
                                          child: Text("0.5x"),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: "全屏",
                                onPressed: () {
                                  isFullscreen
                                      ? state.exitFullscreen()
                                      : state.enterFullscreen();
                                  setState(() {
                                    isFullscreen = !isFullscreen;
                                  });
                                },
                                icon: Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    top: 0,
                    width: 500,
                    bottom: 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    right: _showAside ? 0 : -500,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
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
                                padding: EdgeInsets.all(15),
                                child: TabBarView(
                                  controller: tabController,
                                  children: [
                                    ...List.generate(
                                      widget.detail.sources.length,
                                      (sourceIndex) {
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
                                            return currentEpisodeIndex ==
                                                    episodeIndex
                                                ? FilledButton(
                                                    onPressed: () {},
                                                    child: Text(
                                                      episodeIndex.toString(),
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
                                                      episodeIndex.toString(),
                                                    ),
                                                  );
                                          },
                                        );
                                      },
                                    ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
