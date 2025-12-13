import 'dart:convert';

import 'package:mikufans/entity/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const String key = "mikufans_local_history";
  static late SharedPreferences prefs;

  static void init() {
    SharedPreferences.getInstance().then((onValue) => prefs = onValue);
  }

  static List<History> getLocalHistory() {
    // prefs.remove(key);
    final history = prefs.getStringList(key);
    if (history == null) {
      return [];
    }
    return history.map((e) => History.fromJson(json.decode(e))).toList();
  }

  static void setLocalHistory(List<History> newHistory) {
    final Map<String, History> keep = {};
    for (final h in newHistory) {
      final id = h.media.id!;
      final old = keep[id];
      if (old == null || h.lastViewAt.isAfter(old.lastViewAt)) {
        keep[id] = h;
      }
    }
    final toSave = keep.values.toList()
      ..sort((a, b) => b.lastViewAt.compareTo(a.lastViewAt));
    prefs.setStringList(
      key,
      toSave.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
