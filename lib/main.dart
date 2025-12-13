import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mikufans/component/player.dart';
import 'package:mikufans/entity/detail.dart';
import 'package:mikufans/entity/source.dart';
import 'package:mikufans/screen/detail.dart';
import 'package:mikufans/screen/search.dart';
import 'package:mikufans/screen/settting.dart';
import 'package:mikufans/screen/subscribe.dart';
import 'package:mikufans/util/store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Store.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      routerConfig: _router,
      title: 'MikuFans',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
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
      body: Row(
        children: [
          currentPath.contains("player")
              ? Container()
              : NavigationRail(
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
    );
  }
}
