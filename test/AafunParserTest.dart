import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:desktop_holo/service/impl/aafun.dart';

void main() {
  group("AafunParser", () {
    test("fetchSearch", () async {
      var aafun = AafunParser();
      var result = await aafun.fetchSearch("JOJO的奇妙冒险", 1, 10, (err) {
        print(jsonEncode(err));
      });
      print(jsonEncode(result));
    });
    test("fetchDetail", () async {
      var aafun = AafunParser();
      var result = await aafun.fetchDetail("/feng-n/hxCCCS.html", (err) {
        print(jsonEncode(err));
      });
      print(jsonEncode(result));
    });
    test("fetchView", () async {
      var aafun = AafunParser();
      var result = await aafun.fetchView("/f/hxCCCS-1-1.html", (err) {
        print(err);
      });
      print(jsonEncode(result));
    });
  });
}
