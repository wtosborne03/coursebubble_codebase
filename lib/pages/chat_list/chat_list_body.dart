import 'package:coursebubble/config/app_config.dart';
import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:coursebubble/pages/chat_list/chat_list.dart';
import 'package:coursebubble/pages/chat_list/chat_list_item.dart';
import 'package:coursebubble/pages/chat_list/search_title.dart';
import 'package:coursebubble/pages/chat_list/space_view.dart';
import 'package:coursebubble/pages/chat_list/stories_header.dart';
import 'package:coursebubble/utils/adaptive_bottom_sheet.dart';
import 'package:coursebubble/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:coursebubble/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:coursebubble/utils/stream_extension.dart';
import 'package:coursebubble/widgets/avatar.dart';
import 'package:coursebubble/widgets/profile_bottom_sheet.dart';
import 'package:coursebubble/widgets/public_room_bottom_sheet.dart';
import '../../config/themes.dart';
import '../../widgets/connection_status_header.dart';
import '../../widgets/matrix.dart';
import 'chat_list_header.dart';

class ChatListViewBody extends StatelessWidget {
  final ChatListController controller;

  const ChatListViewBody(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomSearchResult = controller.roomSearchResult;
    final userSearchResult = controller.userSearchResult;
    final client = Matrix.of(context).client;

    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
      child: StreamBuilder(
        key: ValueKey(
          client.userID.toString() +
              controller.activeFilter.toString() +
              controller.activeSpaceId.toString(),
        ),
        stream: client.onSync.stream
            .where((s) => s.hasRoomUpdate)
            .rateLimit(const Duration(seconds: 1)),
        builder: (context, _) {
          if (controller.activeFilter == ActiveFilter.spaces &&
              !controller.isSearchMode) {
            return SpaceView(
              controller,
              scrollController: controller.scrollController,
              key: Key(controller.activeSpaceId ?? 'Spaces'),
            );
          }
          if (controller.waitForFirstSync) {
            final rooms = controller.filteredRooms;
            final displayStoriesHeader = {
                  ActiveFilter.allChats,
                  ActiveFilter.messages,
                }.contains(controller.activeFilter) &&
                client.storiesRooms.isNotEmpty;
            return SafeArea(
              child: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  ChatListHeader(controller: controller),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(
                          height: 5,
                        ),
                        if (controller.isSearchMode) ...[
                          AnimatedContainer(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            height: roomSearchResult == null ||
                                    roomSearchResult.chunk.isEmpty
                                ? 0
                                : 106,
                            duration: FluffyThemes.animationDuration,
                            curve: FluffyThemes.animationCurve,
                            child: roomSearchResult == null
                                ? null
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: roomSearchResult.chunk.length,
                                    itemBuilder: (context, i) => _SearchItem(
                                      title: roomSearchResult.chunk[i].name ??
                                          roomSearchResult.chunk[i]
                                              .canonicalAlias?.localpart ??
                                          L10n.of(context)!.group,
                                      avatar:
                                          roomSearchResult.chunk[i].avatarUrl,
                                      onPressed: () => showAdaptiveBottomSheet(
                                        context: context,
                                        builder: (c) => PublicRoomBottomSheet(
                                          roomAlias: roomSearchResult
                                                  .chunk[i].canonicalAlias ??
                                              roomSearchResult.chunk[i].roomId,
                                          outerContext: context,
                                          chunk: roomSearchResult.chunk[i],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          SearchTitle(
                            title: L10n.of(context)!.users,
                            icon: const Icon(Icons.group_outlined),
                          ),
                          AnimatedContainer(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            height: userSearchResult == null ||
                                    userSearchResult.results.isEmpty
                                ? 0
                                : 106,
                            duration: FluffyThemes.animationDuration,
                            curve: FluffyThemes.animationCurve,
                            child: userSearchResult == null
                                ? null
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: userSearchResult.results.length,
                                    itemBuilder: (context, i) => _SearchItem(
                                      title: userSearchResult
                                              .results[i].displayName ??
                                          userSearchResult
                                              .results[i].userId.localpart ??
                                          L10n.of(context)!.unknownDevice,
                                      avatar:
                                          userSearchResult.results[i].avatarUrl,
                                      onPressed: () => showAdaptiveBottomSheet(
                                        context: context,
                                        builder: (c) => ProfileBottomSheet(
                                          userId: userSearchResult
                                              .results[i].userId,
                                          outerContext: context,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                        if (displayStoriesHeader)
                          StoriesHeader(
                            key: const Key('stories_header'),
                            filter: controller.searchController.text,
                          ),
                        const ConnectionStatusHeader(),
                        AnimatedContainer(
                          height: controller.isTorBrowser ? 64 : 0,
                          duration: FluffyThemes.animationDuration,
                          curve: FluffyThemes.animationCurve,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: Material(
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              leading: const Icon(Icons.vpn_key),
                              title: Text(L10n.of(context)!.dehydrateTor),
                              subtitle:
                                  Text(L10n.of(context)!.dehydrateTorLong),
                              trailing:
                                  const Icon(Icons.chevron_right_outlined),
                              onTap: controller.dehydrate,
                            ),
                          ),
                        ),
                        if (controller.isSearchMode)
                          SearchTitle(
                            title: 'Courses',
                            icon: const Icon(Icons.forum_outlined),
                          ),
                        if (rooms.isEmpty && !controller.isSearchMode) ...[
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/start_chat.png',
                                  height: 256,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int i) {
                        if (i == 0) {
                          if (controller.selectMode == SelectMode.share ||
                              controller.isSearchMode) {
                            return SizedBox();
                          } else {}
                          return ChatListSpecial(
                            selected: true,
                            onTap: () => controller.viewAssignments(),
                          );
                        } else {
                          i = i - 1;
                        }
                        if (!rooms[i]
                            .getLocalizedDisplayname(
                              MatrixLocals(L10n.of(context)!),
                            )
                            .toLowerCase()
                            .contains(
                              controller.searchController.text.toLowerCase(),
                            )) {
                          return const SizedBox.shrink();
                        }
                        return ChatListItem(
                          rooms[i],
                          key: Key('chat_list_item_${rooms[i].id}'),
                          selected:
                              controller.selectedRoomIds.contains(rooms[i].id),
                          onTap: controller.selectMode == SelectMode.select
                              ? () => controller.toggleSelection(rooms[i].id)
                              : null,
                          onLongPress: () =>
                              controller.toggleSelection(rooms[i].id),
                          activeChat: controller.activeChat == rooms[i].id,
                        );
                      },
                      childCount: rooms.length + 1,
                    ),
                  ),
                  (controller.selectMode == SelectMode.share ||
                          controller.isSearchMode)
                      ? SliverList.list(children: [])
                      : SliverList.list(children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.all(20),
                              child: InkWell(
                                  onTap: () {
                                    print('tap');
                                  },
                                  splashColor: Colors.white,
                                  child: Container(
                                      width: 100,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              AppConfig.borderRadius),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                              .withAlpha(100)),
                                      child: Image.asset(
                                        'assets/colleges/clemson_big.png',
                                        width: 60,
                                        height: 60,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withAlpha(100),
                                      ))))
                        ])
                ],
              ),
            );
          }
          const dummyChatCount = 5;
          final titleColor =
              Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(100);
          final subtitleColor =
              Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(50);
          return ListView.builder(
            key: const Key('dummychats'),
            itemCount: dummyChatCount,
            itemBuilder: (context, i) => Opacity(
              opacity: (dummyChatCount - i) / dummyChatCount,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: titleColor,
                  child: const CircularProgressIndicator(),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: titleColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                    Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        color: subtitleColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        color: subtitleColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  decoration: BoxDecoration(
                    color: subtitleColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  height: 12,
                  margin: const EdgeInsets.only(right: 22),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchItem extends StatelessWidget {
  final String title;
  final Uri? avatar;
  final void Function() onPressed;

  const _SearchItem({
    required this.title,
    this.avatar,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Avatar(
                mxContent: avatar,
                name: title,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
