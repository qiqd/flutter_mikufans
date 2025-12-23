import 'dart:core';

import 'package:desktop_holo/entity/detail.dart';
import 'package:desktop_holo/entity/work.dart';
import 'package:desktop_holo/entity/timetable.dart';
import 'package:desktop_holo/entity/view_info.dart';

/// HTML解析接口规范
abstract class Parser {
  /// 名称
  String get name;

  /// 网站logo地址
  String get logoUrl;

  /// 网站地址
  String get baseUrl;

  /// 解析搜索结果
  ///
  /// @param keyword 搜索关键词
  /// @param page 页码
  /// @param size 每页数量
  /// @param exceptionHandler 异常处理器
  /// @return List<Media>
  Future<List<Work>> fetchSearch(
    String keyword,
    int page,
    int size,
    Function(dynamic) exceptionHandler,
  );

  /// 解析详情信息
  ///
  /// @param mediaId 媒体ID
  /// @param exceptionHandler 异常处理器
  /// @return Detail
  Future<Detail?> fetchDetail(
    String mediaId,
    Function(dynamic) exceptionHandler,
  );

  /// 解析播放信息
  ///
  /// @param episodeId 剧集id
  /// @param exceptionHandler 异常处理器
  /// @return ViewInfo
  Future<ViewInfo?> fetchView(
    String episodeId,
    Function(dynamic) exceptionHandler,
  );

  /// 解析推荐列表
  ///
  /// @param html HTML内容
  /// @param exceptionHandler 异常处理器
  /// @return 推荐视频列表
  Future<String> fetchRecommend(
    String html,
    Function(dynamic) exceptionHandler,
  );

  /// 获取每周更新时间表
  ///
  /// @param exceptionHandler 异常处理器
  /// @return Schedule列表
  Future<List<Timetable>> fetchWeekly(Function(dynamic) exceptionHandler);
}
