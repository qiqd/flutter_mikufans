import 'package:flutter/material.dart';
import 'package:mikufans/main.dart';
import 'package:mikufans/util/store_util.dart';

class SetttingScreen extends StatefulWidget {
  final Function(int index)? onThemeModeChange;
  const SetttingScreen({super.key, this.onThemeModeChange});

  @override
  State<SetttingScreen> createState() => _SetttingScreenState();
}

class _SetttingScreenState extends State<SetttingScreen> {
  bool _autoPlay = false;
  final bool _skipIntro = true;
  final double _playbackSpeed = 1.0;
  bool _showTrayIcon = true;
  bool _minimizeToTray = true;
  final String _videoQuality = '自动';
  bool _hardwareAcceleration = true;
  final double _cacheSize = 500; // MB
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // 从本地存储加载设置
    setState(() {
      _autoPlay = Store.getBool('auto_play');
      // _skipIntro = Store.getBool('skip_intro');
      // _playbackSpeed = Store.getDouble('playback_speed');
      _showTrayIcon = Store.getBool('show_tray_icon');
      _minimizeToTray = Store.getBool('minimize_to_tray');
      // _videoQuality = Store.getString('video_quality');
      _hardwareAcceleration = Store.getBool('hardware_acceleration');
      // _cacheSize = Store.getDouble('cache_size');
      _themeMode =
          ThemeMode.values[Store.getInt(
            'theme_mode',
          ).clamp(0, ThemeMode.values.length - 1)];
    });
  }

  void _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      Store.setBool(key, value);
    } else if (value is double) {
      Store.setDouble(key, value);
    } else if (value is int) {
      Store.setInt(key, value);
    } else {
      Store.setString(key, value.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('播放设置'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ), // 12 dp 圆角
                  ),
                  title: const Text('自动播放下一集'),
                  subtitle: const Text('当前剧集结束后自动播放下一集'),
                  value: _autoPlay,
                  onChanged: (value) {
                    setState(() {
                      _autoPlay = value;
                      _saveSetting('auto_play', value);
                    });
                  },
                ),
                // SwitchListTile(
                //   title: const Text('跳过片头片尾'),
                //   subtitle: const Text('自动跳过片头片尾（如果有标记）'),
                //   value: _skipIntro,
                //   onChanged: (value) {
                //     setState(() {
                //       _skipIntro = value;
                //       _saveSetting('skip_intro', value);
                //     });
                //   },
                // ),
                // ListTile(
                //   title: const Text('默认播放速度'),
                //   subtitle: Text('${_playbackSpeed}x'),
                //   trailing: DropdownButton<double>(
                //     focusColor: Colors.transparent,
                //     iconEnabledColor: Colors.transparent,
                //     iconDisabledColor: Colors.transparent,
                //     value: _playbackSpeed,
                //     items: const [
                //       DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                //       DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                //       DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                //       DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                //       DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                //       DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                //     ],
                //     onChanged: (value) {
                //       if (value != null) {
                //         setState(() {
                //           _playbackSpeed = value;
                //           _saveSetting('playback_speed', value);
                //         });
                //       }
                //     },
                //   ),
                // ),
                // ListTile(
                //   title: const Text('视频质量'),
                //   subtitle: Text(_videoQuality),
                //   trailing: DropdownButton<String>(
                //     value: _videoQuality,
                //     items: const [
                //       DropdownMenuItem(value: '自动', child: Text('自动')),
                //       DropdownMenuItem(value: '1080P', child: Text('1080P')),
                //       DropdownMenuItem(value: '720P', child: Text('720P')),
                //       DropdownMenuItem(value: '480P', child: Text('480P')),
                //       DropdownMenuItem(value: '360P', child: Text('360P')),
                //     ],
                //     onChanged: (value) {
                //       if (value != null) {
                //         setState(() {
                //           _videoQuality = value;
                //           _saveSetting('video_quality', value);
                //         });
                //       }
                //     },
                //   ),
                // ),
                SwitchListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  title: const Text('硬件加速'),
                  subtitle: const Text('使用硬件加速解码视频（推荐）'),
                  value: _hardwareAcceleration,
                  onChanged: (value) {
                    setState(() {
                      _hardwareAcceleration = value;
                      _saveSetting('hardware_acceleration', value);
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('系统设置'),
          Card(
            child: Column(
              children: [
                // SwitchListTile(
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //       topLeft: Radius.circular(12),
                //       topRight: Radius.circular(12),
                //     ), // 12 dp 圆角
                //   ),
                //   title: const Text('显示系统托盘图标'),
                //   subtitle: const Text('在系统托盘显示应用图标'),
                //   value: _showTrayIcon,
                //   onChanged: (value) {
                //     setState(() {
                //       _showTrayIcon = value;
                //       _saveSetting('show_tray_icon', value);
                //       // 这里可以添加实际的托盘图标显示/隐藏逻辑
                //     });
                //   },
                // ),
                SwitchListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ), // 12 dp 圆角
                  ),
                  title: const Text('最小化到托盘'),
                  subtitle: const Text('点击最小化按钮时隐藏到系统托盘(该选项需要重新启动应用才能生效)'),
                  value: _minimizeToTray,
                  onChanged: (value) {
                    setState(() {
                      _minimizeToTray = value;
                      _saveSetting('minimize_to_tray', value);
                    });
                  },
                ),
                // ListTile(
                //   title: const Text('缓存大小'),
                //   subtitle: Text('${_cacheSize.toInt()} MB'),
                //   trailing: SizedBox(
                //     width: 100,
                //     child: Slider(
                //       value: _cacheSize,
                //       min: 100,
                //       max: 2000,
                //       divisions: 19,
                //       onChanged: (value) {
                //         setState(() {
                //           _cacheSize = value;
                //           _saveSetting('cache_size', value);
                //         });
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('界面设置'),
          Card(
            child: Column(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  title: const Text('主题模式'),

                  trailing: DropdownMenu(
                    enableFilter: false,
                    enableSearch: false,
                    inputDecorationTheme: InputDecorationTheme(
                      border: InputBorder.none,
                    ),
                    requestFocusOnTap: false,
                    initialSelection: ThemeMode.light,
                    onSelected: (value) {
                      setState(() {
                        _themeMode = value!;
                        MyApp.themeNotifier.value = value;
                        _saveSetting('theme_mode', value.index);
                      });
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry(label: '跟随系统', value: ThemeMode.system),
                      DropdownMenuEntry(label: '浅色', value: ThemeMode.light),
                      DropdownMenuEntry(label: '深色', value: ThemeMode.dark),
                    ],
                  ),
                ),
                // ListTile(
                //   title: const Text('语言设置'),
                //   subtitle: const Text('简体中文'),
                //   trailing: const Icon(Icons.language),
                //   onTap: () {
                //     // 可以添加语言选择对话框
                //     _showLanguageDialog();
                //   },
                // ),
                // ListTile(
                //   title: const Text('字体大小'),
                //   subtitle: const Text('标准'),
                //   trailing: const Icon(Icons.text_fields),
                //   onTap: () {
                //     // 可以添加字体大小选择
                //     _showFontSizeDialog();
                //   },
                // ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('其他'),
          Card(
            child: Column(
              children: [
                // ListTile(
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //       topLeft: Radius.circular(12),
                //       topRight: Radius.circular(12),
                //     ), // 12 dp 圆角
                //   ),
                //   title: const Text('清除缓存'),
                //   subtitle: const Text('清除视频缓存和临时文件'),
                //   trailing: const Icon(Icons.delete_outline),
                //   onTap: () {
                //     _showClearCacheDialog();
                //   },
                // ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  title: const Text('关于'),
                  subtitle: const Text('应用信息和版本'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ), // 12 dp 圆角
                  ),
                  title: const Text('检查更新'),
                  subtitle: const Text('检查是否有新版本可用'),
                  trailing: const Icon(Icons.update),
                  onTap: () {
                    _checkForUpdates();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          // fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext ct) {
    showDialog(
      context: ct,
      builder: (ct) => AlertDialog(
        title: const Text('选择主题'),
        content: SizedBox(
          height: 80,
          child: Column(
            children: [
              RadioMenuButton(
                value: ThemeMode.light,
                groupValue: _themeMode,
                onChanged: (_) => setState(() => _themeMode = ThemeMode.light),
                child: const Text('浅色'),
              ),
              RadioMenuButton<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: _themeMode,
                onChanged: (_) => setState(() => _themeMode = ThemeMode.dark),
                child: const Text('深色'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('简体中文'),
              value: 'zh_CN',
              groupValue: 'zh_CN',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('繁體中文'),
              value: 'zh_TW',
              groupValue: 'zh_CN',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en_US',
              groupValue: 'zh_CN',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字体大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('小'),
              value: 'small',
              groupValue: 'normal',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('标准'),
              value: 'normal',
              groupValue: 'normal',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('大'),
              value: 'large',
              groupValue: 'normal',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('特大'),
              value: 'huge',
              groupValue: 'normal',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 执行清除缓存操作
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('缓存已清除')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 MikuFans'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MikuFans 动漫播放器',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('版本: 1.0.0'),
              const SizedBox(height: 8),
              const Text('基于 Flutter 开发'),
              const SizedBox(height: 16),

              const Text(
                '开源库声明',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '本应用使用了以下开源库：\n'
                '• go_router: ^17.0.1 - Flutter 路由管理 (BSD 协议)\n'
                '• dio: ^5.9.0 - 网络请求库 (MIT 协议)\n'
                '• media_kit: ^1.2.6 - 媒体播放框架 (MIT 协议)\n'
                '• shared_preferences: ^2.5.4 - 本地存储 (BSD 协议)\n'
                '• window_manager: ^0.5.1 - 窗口管理 (MIT 协议)\n'
                '• tray_manager: ^0.5.2 - 系统托盘 (MIT 协议)\n'
                '• html: ^0.15.6 - HTML 解析 (BSD 协议)\n'
                '• encrypt: ^5.0.3 - 加密解密 (MIT 协议)\n'
                '• cupertino_icons: ^1.0.8 - 图标库 (MIT 协议)\n'
                '• visibility_detector: ^0.4.0+2 - 可见性检测 (Apache 2.0 协议)',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),

              const Text('开源协议', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                '本应用开源协议：\n'
                'AGPL-3.0',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),

              const Text('使用条款', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                '1. 本应用所有资源均来源于互联网，仅供学习交流使用\n'
                '2. 本应用不存储任何个人信息，尊重用户隐私\n'
                '3. 本应用禁止用于任何商业用途\n'
                '4. 用户使用本应用即视为同意本声明的所有条款\n'
                '5. 如对本应用内容存在异议，请立即停止使用',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),

              const Text('© 2025 MikuFans', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('当前已是最新版本')));
  }
}
