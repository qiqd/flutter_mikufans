import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:desktop_holo/component/title_bar.dart';
import 'package:desktop_holo/screen/player_screen.dart';
import 'package:desktop_holo/entity/detail.dart';
import 'package:desktop_holo/entity/source.dart';
import 'package:desktop_holo/screen/detail_screen.dart';
import 'package:desktop_holo/screen/history_screen.dart';
import 'package:desktop_holo/screen/search_screen.dart';
import 'package:desktop_holo/screen/settting_screen.dart';
import 'package:desktop_holo/screen/subscribe_screen.dart';
import 'package:desktop_holo/util/store_util.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  try {
    await Store.init();
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
    await windowManager.ensureInitialized();
    if (!(await FlutterSingleInstance().isFirstInstance())) {
      await windowManager.show();
      await windowManager.focus();
      exit(0);
    }
    trayManager.setIcon(
      Platform.isWindows
          ? 'lib/images/icon_windows.ico'
          : 'lib/images/icon_linux.png',
    );
    await windowManager.setPreventClose(Store.getBool('minimize_to_tray'));
    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(800, 600),
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
      title: 'desktop_holo',
    );
    Menu menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: '显示主窗口'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: '退出应用'),
      ],
    );
    await trayManager.setContextMenu(menu);
    await trayManager.setToolTip('desktop_holo');
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(const MyApp());
  } catch (e, s) {
    final logFile = File('${Directory.current.path}/crash.log');
    logFile.writeAsStringSync(
      '[${DateTime.now().toLocal()}] ${e.toString()}\n$s\n',
      mode: FileMode.append,
    );
    _showCrashTip(logFile.path);
    exit(1);
  }
}

class MyApp extends StatefulWidget {
  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener, WindowListener {
  late final GoRouter _router = GoRouter(
    // observers: [routeObserver],
    initialLocation: '/search',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subscribe',
                builder: (context, state) => SubscribeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/setting',
                builder: (context, state) => SetttingScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) =>
            DetailScreen(mediaId: state.extra.toString()),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) {
          final data = state.extra as Map<String, Object>;
          final detail = data['detail'] as Detail;
          final episodeIndex = data['episodeIndex'] as int;
          final source = data['source'] as Source;
          return PlayerScreen(
            detail: detail,
            episodeIndex: episodeIndex,
            source: source,
          );
        },
      ),
    ],
  );
  String get _effectiveFont {
    switch (Platform.operatingSystem) {
      case 'windows':
        return 'Microsoft YaHei UI'; // 最厚实
      case 'macos':
        return 'PingFang SC'; // 苹方，macOS 自带
      case 'linux':
        return 'Noto Sans CJK SC'; // 大多数发行版预装
      default:
        return 'Noto Sans'; // 兜底，理论上走不到
    }
  }

  @override
  void initState() {
    super.initState();
    MyApp.themeNotifier.value =
        ThemeMode.values[Store.getInt('theme_mode', defaultValue: 0)];
    windowManager.addListener(this);
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: MyApp.themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          title: 'desktop_holo',
          themeMode: themeMode,
          theme: ThemeData(
            fontFamily: _effectiveFont,
            colorSchemeSeed: const Color(0xfffb739a),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: _effectiveFont,
            colorSchemeSeed: const Color(0xfffb739a),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
        );
      },
    );
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
    super.onWindowClose();
  }

  @override
  void onTrayIconMouseUp() async {
    await windowManager.show();
    super.onTrayIconMouseUp();
  }

  @override
  void onTrayIconMouseDown() async {
    super.onTrayIconMouseDown();
    await windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() async {
    super.onTrayIconRightMouseUp();
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    super.onTrayMenuItemClick(menuItem);
    if (menuItem.key == 'exit_app') {
      _router.go('/search');
      await windowManager.hide();
      await Future.delayed(Duration(milliseconds: 100));
      windowManager.destroy();
    } else if (menuItem.key == 'show_window') {
      await windowManager.show();
    }
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    var currentPath = router.routerDelegate.currentConfiguration.uri.toString();
    return Scaffold(
      body: Column(
        children: [
          //自定义标题栏
          TitleBar(),
          Expanded(
            child: Row(
              children: [
                currentPath.contains("player")
                    ? Container()
                    : NavigationRail(
                        indicatorShape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.search),
                            label: Text('Search'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.subscriptions),
                            label: Text('Subscribe'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.history_rounded),
                            label: Text('History'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings),
                            label: Text('Setting'),
                          ),
                        ],
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: (index) =>
                            navigationShell.goBranch(index),
                      ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16, bottom: 16),
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showCrashTip(String logPath) async {
  final String msg = 'desktop_holo 启动失败，请查看 $logPath';

  if (Platform.isWindows) {
    // Windows 弹窗
    await Process.run('msg', ['*', msg]);
  } else if (Platform.isMacOS) {
    // macOS 弹窗（原生通知）
    await Process.run('osascript', [
      '-e',
      'display notification "$msg" with title "desktop_holo" sound name "Basso"',
    ]);
  } else if (Platform.isLinux) {
    // Linux 弹窗
    await Process.run('notify-send', ['-a', 'desktop_holo', '启动失败', msg]);
  }
}
