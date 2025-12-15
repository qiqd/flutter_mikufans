import 'package:flutter/material.dart';

import 'package:mikufans/entity/work.dart';
import 'package:mikufans/util/datetime_util.dart';

class MediaCard extends StatelessWidget {
  final Work media;
  final Function(Work) onTap;
  final double height;
  final bool isLove;
  final bool showLoveIcon;
  final DateTime? lastViewAt;
  final int? episodeIndex;
  final bool showSummary;
  final bool showEpisodeIndexOnRight;
  final bool hoverState;
  final Function()? onLoveTap;
  final Function(int episodeIndex)? onContinueTap;
  const MediaCard({
    super.key,
    required this.media,
    required this.onTap,
    this.isLove = false,
    this.showLoveIcon = false,
    this.lastViewAt,
    this.episodeIndex,
    this.height = 320,
    this.showSummary = true,
    this.showEpisodeIndexOnRight = false,
    this.hoverState = true,
    this.onLoveTap,
    this.onContinueTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          hoverColor: hoverState ? null : Colors.transparent,
          onTap: () => onTap(media),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图片
              AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                  child: Image.network(
                    media.cover!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
              // 右侧内容
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 标题 - 必填字段，总是显示
                        Text(
                          media.titleCn!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),

                        // 副标题 - 如果有就显示
                        if (media.title != null && media.title!.isNotEmpty) ...[
                          Text(
                            media.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],

                        // 观看信息区域
                        if (lastViewAt != null && episodeIndex != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (lastViewAt != null) ...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "最后观看: ${formatTimeAgo(lastViewAt!.toLocal())}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (episodeIndex != null &&
                                    !showEpisodeIndexOnRight) ...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "观看至第$episodeIndex集",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        // 类型标签 - 如果有就显示
                        if (media.type != null && media.type!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              media.type!,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        // 状态信息 - 如果有就显示
                        if (media.status != null &&
                            media.status!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  media.status!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // 播出日期 - 如果有就显示
                        if (media.airdate != null &&
                            media.airdate!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                media.airdate!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],

                        // 简介 - 如果有就显示
                        if (showSummary &&
                            media.summary != null &&
                            media.summary!.isNotEmpty) ...[
                          Tooltip(
                            message: media.summary!,
                            constraints: BoxConstraints(maxWidth: 700),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withAlpha(
                                    32,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                media.summary!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                        // 播放按钮 - 如果显示
                        Row(
                          spacing: 10,
                          children: [
                            if (episodeIndex != null &&
                                showEpisodeIndexOnRight) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: () {
                                    onContinueTap?.call(episodeIndex!);
                                  },
                                  child: Text(
                                    episodeIndex == 0
                                        ? '播放'
                                        : '继续观看第${episodeIndex! + 1}集',
                                  ),
                                ),
                              ),
                            ],
                            // 收藏按钮 - 如果显示
                            if (showLoveIcon) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  tooltip: "订阅",
                                  onPressed: () {
                                    onLoveTap?.call();
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: isLove
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surface,
                                    foregroundColor: isLove
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: isLove ? 0 : 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(36, 36),
                                  ),
                                  icon: Icon(
                                    isLove
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
