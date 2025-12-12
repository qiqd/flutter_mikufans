import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mikufans/component/media_card.dart';
import 'package:mikufans/entity/detail.dart';
import 'package:mikufans/entity/media.dart';
import 'package:mikufans/service/impl/aafun.dart';

class DetailScreen extends StatefulWidget {
  final String mediaId;
  const DetailScreen({super.key, required this.mediaId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _error = '';
  final AafunParser _parser = AafunParser();
  Detail? _detail;
  void _detailhandle() async {
    var res = await _parser.fetchDetail(
      widget.mediaId,
      (error) => setState(() => _error = error),
    );
    if (res == null) {
      setState(() => _error = '获取详情失败');
      return;
    }
    setState(() {
      _detail = res;
      _tabController = TabController(
        length: _detail!.sources.length,
        vsync: this,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _detailhandle();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('详情'),
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _error.isNotEmpty
          ? Center(child: Text(_error))
          : _detail == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ① 中部媒体卡片（固定高度）
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  height: 240,
                  child: MediaCard(media: _detail!.media, onTap: (_) {}),
                ),

                // ② 线路选择 TabBar
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      TabBar(
                        dividerHeight: 0,
                        controller: _tabController,
                        isScrollable: true,
                        tabs: _detail!.sources.asMap().entries.map((e) {
                          final index = e.key; // 0、1、2 …
                          return Tab(text: '线路${index + 1}');
                        }).toList(),
                      ),

                      IconButton(
                        // 右侧按钮
                        icon: const Icon(Icons.sort),
                        tooltip: '排序',
                        onPressed: () {
                          setState(() {
                            for (var item in _detail!.sources) {
                              item.episodes = item.episodes.reversed.toList();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: TabBarView(
                      controller: _tabController,
                      children: List.generate(
                        _detail!.sources.length,
                        (lineIdx) => SizedBox(
                          // 固定高度区域
                          height: 220,
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.start,
                              children: List.generate(
                                _detail!
                                    .sources[lineIdx]
                                    .episodes
                                    .length, // 该线路真实集数
                                (idx) => SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Card(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        var episode = _detail!
                                            .sources[lineIdx]
                                            .episodes[idx];
                                        print(episode.toJson());
                                      },

                                      child: Center(
                                        child: Text(
                                          '${idx + 1}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
