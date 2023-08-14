import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/pages/chat_details/chat_details.dart';
import 'package:coursebubble/pages/chat_details/participant_list_item.dart';
import 'package:coursebubble/utils/fluffy_share.dart';
import 'package:coursebubble/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:coursebubble/widgets/avatar.dart';
import 'package:coursebubble/widgets/chat_settings_popup_menu.dart';
import 'package:coursebubble/widgets/content_banner.dart';
import 'package:coursebubble/widgets/layouts/max_width_body.dart';
import 'package:coursebubble/widgets/matrix.dart';
import '../../utils/url_launcher.dart';

class ChatDetailsView extends StatelessWidget {
  final ChatDetailsController controller;

  const ChatDetailsView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = Matrix.of(context).client.getRoomById(controller.roomId!);
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context)!.oopsSomethingWentWrong),
        ),
        body: Center(
          child: Text(L10n.of(context)!.youAreNoLongerParticipatingInThisChat),
        ),
      );
    }

    final actualMembersCount = (room.summary.mInvitedMemberCount ?? 0) +
        (room.summary.mJoinedMemberCount ?? 0);
    final canRequestMoreMembers =
        controller.members!.length < actualMembersCount;
    final iconColor = Theme.of(context).textTheme.bodyLarge!.color;
    final roomData = jsonDecode(room.topic.split('/*/*/')[1]);
    return StreamBuilder(
      stream: room.onUpdate.stream,
      builder: (context, snapshot) {
        return Scaffold(
          body: CustomScrollView(
              controller: controller.sc,
              shrinkWrap: true,
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close_outlined),
                    onPressed: () =>
                        VRouter.of(context).path.startsWith('/spaces/')
                            ? VRouter.of(context).pop()
                            : VRouter.of(context)
                                .toSegments(['rooms', controller.roomId!]),
                  ),
                  elevation: Theme.of(context).appBarTheme.elevation,
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  actions: <Widget>[ChatSettingsPopupMenu(room, false)],
                  title: Text(
                    room.getLocalizedDisplayname(
                      MatrixLocals(L10n.of(context)!),
                    ),
                  ),
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: controller.cData['image_download_url'] == null
                        ? Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                            stops: const [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )))
                        : Image.network(
                            controller.cData['image_download_url'],
                            color: Theme.of(context)
                                .colorScheme
                                .background
                                .withAlpha(110),
                            colorBlendMode: BlendMode.darken,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SliverList.list(children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.members!.length + 1,
                      itemBuilder: (BuildContext context, int i) => i == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (roomData['type'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                        left: 10,
                                        right: 10),
                                    child: Text(
                                      roomData['type'] == 0
                                          ? "University Class"
                                          : "University Club",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ),
                                if (room.topic.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0,
                                        bottom: 15,
                                        left: 10,
                                        right: 10),
                                    child: Linkify(
                                      text: room.topic.isEmpty
                                          ? L10n.of(context)!
                                              .addGroupDescription
                                          : room.topic.split('/*/*/')[0],
                                      options:
                                          const LinkifyOptions(humanize: false),
                                      linkStyle: const TextStyle(
                                          color: Colors.blueAccent),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        decorationColor: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                      onOpen: (url) =>
                                          UrlLauncher(context, url.url)
                                              .launchUrl(),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                ListTile(
                                  title: Text(
                                    actualMembersCount > 1
                                        ? L10n.of(context)!.countParticipants(
                                            (actualMembersCount - 1).toString(),
                                          )
                                        : L10n.of(context)!.emptyChat,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : controller.members![i - 1].displayName != 'admin'
                              ? ParticipantListItem(controller.members![i - 1])
                              : SizedBox()),
                  Column(
                      children: controller.students.map((e) {
                    if (e != null) {
                      return PotentialListItem(e!);
                    } else {
                      return SizedBox();
                    }
                  }).toList()),
                ]),
                SliverList.list(
                  children: [
                    controller.loading
                        ? Center(child: CircularProgressIndicator.adaptive())
                        : SizedBox(),
                    SizedBox(
                      height: 40,
                    )
                  ],
                )
              ]),
        );
      },
    );
  }
}
