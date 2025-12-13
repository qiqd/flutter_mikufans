import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:mikufans/entity/detail.dart';
import 'package:mikufans/entity/episode.dart';
import 'package:mikufans/entity/work.dart';
import 'package:mikufans/entity/source.dart';
import 'package:mikufans/entity/timetable.dart';
import 'package:mikufans/entity/view_info.dart';
import 'package:mikufans/util/http_util.dart';
import 'package:mikufans/service/parser.dart';

class AafunParser extends Parser {
  @override
  String get logoUrl => "https://p.upyun.com/demo/tmp/Hds66ovM.png";

  @override
  String get name => "风铃动漫";

  @override
  String get baseUrl => "https://www.aafun.cc";

  @override
  Future<Detail?> fetchDetail(
    String mediaId,
    Function(dynamic) exceptionHandler,
  ) async {
    try {
      var fullUrl = baseUrl + mediaId;
      var response = HttpUtil.createDio();
      var v = await response.get(fullUrl);

      var doc = parse(v.data);
      var box = doc.querySelectorAll("div.hl-tabs-box");
      var sources = box.map((item) {
        final a = item.querySelectorAll("li.hl-col-xs-4 a");
        var episodes = a.map((epi) {
          return Episode(id: epi.attributes['href'], title: epi.text);
        }).toList();
        return Source(index: null, name: null, episodes: episodes);
      }).toList();

      final picE = doc.querySelector(".hl-dc-pic .hl-item-thumb");
      final url = picE?.attributes['data-original'];
      final titme = doc.querySelector("span.hl-crumb-item")?.text;
      final status = doc
          .querySelector(".hl-vod-data .hl-col-xs-12 span.hl-text-conch")
          ?.text;
      final info = doc.querySelectorAll(".hl-vod-data .hl-col-xs-12");
      final actors = info[2].text;
      final directors = info[3].text;
      final info2 = doc.querySelectorAll(
        ".hl-vod-data .hl-col-xs-12.hl-col-sm-4",
      );
      final year = info2.isNotEmpty ? info2[0].text.replaceAll(" ", "") : null;
      final genre = info[2].text;
      final airdate = info[3].text;
      final description = doc
          .querySelector(".hl-vod-data .hl-col-xs-12.blurb")
          ?.text;
      final title = doc.querySelector("div.hl-dc-sub")?.text.trim();
      final rating = doc.querySelector(".hl-score-nums span")?.text;
      final ratingCount = doc
          .querySelector("span.hl-score-data.hl-text-muted.hl-pull-right")
          ?.text
          .trim();
      final media = Work(
        id: mediaId,
        titleCn: titme,
        cover: url,
        status: status,
        actors: actors,
        directors: directors,
        airdate: year ?? airdate,
        type: genre,
        summary: description,
        rating: rating,
        ratingCount: ratingCount,
        title: title,
      );

      return Detail(media: media, series: List.empty(), sources: sources);
    } catch (e) {
      exceptionHandler(e);
      return null;
    }
  }

  @override
  Future<List<Work>> fetchSearch(
    String keyword,
    int page,
    int size,
    Function(dynamic) exceptionHandler,
  ) async {
    try {
      var searchUrl = "/feng-s.html?wd=${keyword.replaceAll(" ", "")}";
      var response = HttpUtil.createDio();
      var value = await response.get(baseUrl + searchUrl);
      final doc = parse(value.data).body;
      final items =
          doc?.querySelectorAll("div.hl-list-wrap li.hl-list-item") ?? [];

      return items.map((item) {
        String? genre = item.querySelector("p.hl-item-sub.hl-lc-1")?.text;
        String? actor = item
            .querySelector("p.hl-item-sub.hl-text-muted.hl-lc-1.hl-hidden-xs")
            ?.text;
        String? introduction = item
            .querySelector("p.hl-item-sub.hl-text-muted.hl-lc-2")
            ?.text;
        Element? a = item.querySelector("div.hl-item-div a");
        String? status = item.querySelector("span.hl-lc-1.remarks")?.text;

        return Work(
          id: a!.attributes["href"],
          titleCn: a.attributes["title"],
          cover: a.attributes["data-original"],
          status: status,
          summary: introduction,
          type: genre,
          actors: actor,
        );
      }).toList();
    } catch (e) {
      exceptionHandler(e);
      return [];
    }
  }

  @override
  Future<ViewInfo?> fetchView(
    String episodeId,
    Function(dynamic) exceptionHandler,
  ) async {
    try {
      var dio = HttpUtil.createDio();
      var value = await dio.get(baseUrl + episodeId);

      final doc = parse(value.data).body;
      final script = doc?.querySelectorAll("script[type='text/javascript']");
      if (script == null || script.isEmpty) {
        exceptionHandler(Exception("未找到视频"));
        return null;
      }

      for (var element in script) {
        if (element.text.contains("var player_aaaa")) {
          var temp = element.text.substring(element.text.indexOf("{"));
          final objectString = json.decode(temp) as Map<String, dynamic>;
          final encodeUrl = objectString["url"];
          final decodeUrl = Uri.decodeComponent(
            encodeUrl,
          ); // 这里应该是playerData.url的值

          // 构建完整URL
          final fullFullUrl = "$baseUrl/player/?url=$decodeUrl";

          // 设置请求头
          final headers = {
            'Host': baseUrl.substring(baseUrl.lastIndexOf("/") + 1),
            'Referer': baseUrl + episodeId,
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36',
          };

          // 获取player页面
          var body = await HttpUtil.createDio().get(
            fullFullUrl,
            options: Options(headers: headers),
          );
          final playerDocument = parse(body.data);

          // 查找包含const encryptedUrl的script标签
          String? scriptContent;
          final playerScripts = playerDocument.querySelectorAll('script');

          for (final script in playerScripts) {
            if (script.text.contains('const encryptedUrl')) {
              scriptContent = script.text;
              break;
            }
          }
          scriptContent ??= '';
          // 提取encryptedUrl
          String? encryptedUrl;
          final encryptedUrlRegExp = RegExp(
            r'const\s+encryptedUrl\s*=\s*"([^"]+)"',
          );
          final encryptedUrlMatch = encryptedUrlRegExp.firstMatch(
            scriptContent,
          );
          if (encryptedUrlMatch != null) {
            encryptedUrl = encryptedUrlMatch.group(1);
          }

          // 提取sessionKey
          String? sessionKey;
          final sessionKeyRegExp = RegExp(
            r'const\s+sessionKey\s*=\s*"([^"]+)"',
          );
          final sessionKeyMatch = sessionKeyRegExp.firstMatch(scriptContent);
          if (sessionKeyMatch != null) {
            sessionKey = sessionKeyMatch.group(1);
          }

          // 解密获取视频URL
          final videoUrl = decryptAES(encryptedUrl!, sessionKey!);
          final currentUrl = videoUrl.replaceFirst('http://', 'https://');
          return ViewInfo(urls: [currentUrl], episodeId: episodeId);
        }
      }
      return null;
    } catch (e) {
      exceptionHandler(e);
      return null;
    }
  }

  @override
  Future<List<Timetable>> fetchWeekly(
    Function(dynamic) exceptionHandler,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchRecommend(
    String html,
    Function(dynamic) exceptionHandler,
  ) async {
    throw UnimplementedError();
  }

  /// 使用 encrypt 库简化 AES/CBC/PKCS5Padding 解密
  String decryptAES(String ciphertext, String key) {
    try {
      // Base64 解码密文
      final encryptedBytes = base64Decode(ciphertext);

      // 提取 IV（前16字节）和加密数据（剩余部分）
      final iv = encryptedBytes.sublist(0, 16);
      final encrypted = encryptedBytes.sublist(16);

      // 创建 Key 和 IV 对象
      final keyObj = Key.fromUtf8(key);
      final ivObj = IV(Uint8List.fromList(iv));

      // 创建 AES 加密器（CBC 模式，PKCS7 填充）
      final encrypter = Encrypter(AES(keyObj, mode: AESMode.cbc));

      // 解密数据
      final decrypted = encrypter.decryptBytes(
        Encrypted(Uint8List.fromList(encrypted)),
        iv: ivObj,
      );

      // 返回 UTF-8 解码后的明文
      return utf8.decode(decrypted);
    } catch (e) {
      print('URL解密失败: $e');
      rethrow;
    }
  }
}
