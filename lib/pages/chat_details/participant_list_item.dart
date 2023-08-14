import 'dart:convert';

import 'package:coursebubble/pages/chat_details/chat_details.dart';
import 'package:coursebubble/utils/canvas_dart.dart';
import 'package:coursebubble/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:latlong2/latlong.dart';
import 'package:matrix/matrix.dart';

import 'package:coursebubble/utils/adaptive_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/avatar.dart';
import '../user_bottom_sheet/user_bottom_sheet.dart';

class ParticipantListItem extends StatelessWidget {
  final User user;

  const ParticipantListItem(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final membershipBatch = <Membership, String>{
      Membership.join: '',
      Membership.ban: L10n.of(context)!.banned,
      Membership.invite: L10n.of(context)!.invited,
      Membership.leave: L10n.of(context)!.leftTheChat,
    };
    final permissionBatch = user.powerLevel == 100
        ? L10n.of(context)!.admin
        : user.powerLevel >= 50
            ? L10n.of(context)!.moderator
            : '';

    return Opacity(
      opacity: user.membership == Membership.join ? 1 : 0.5,
      child: ListTile(
        onTap: () => showAdaptiveBottomSheet(
          context: context,
          builder: (c) => UserBottomSheet(
            user: user,
            outerContext: context,
          ),
        ),
        title: Row(
          children: <Widget>[
            Text(user.calcDisplayname()),
            if (permissionBatch.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Text(
                  permissionBatch,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            membershipBatch[user.membership]!.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Center(child: Text(membershipBatch[user.membership]!)),
                  ),
          ],
        ),
        subtitle: Text('Sophomore'),
        leading:
            Avatar(mxContent: user.avatarUrl, name: user.calcDisplayname()),
      ),
    );
  }
}

class PotentialListItem extends StatelessWidget {
  final Student student;

  const PotentialListItem(this.student, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: ListTile(
          onTap: () => showAdaptiveBottomSheet(
              context: context, builder: (c) => InviteBar(student)),
          title: Row(
            children: <Widget>[
              Text(student.name),
            ],
          ),
          subtitle: Text(student.name),
          leading: CircleAvatar(
              backgroundImage: kIsWeb
                  ? null
                  : NetworkImage(
                      student.profile_url,
                    ))),
    );
  }
}

class InviteBar extends StatelessWidget {
  final Student student;

  const InviteBar(this.student, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        CircleAvatar(
            radius: 50,
            backgroundImage: kIsWeb
                ? null
                : NetworkImage(
                    student.profile_url,
                  )),
        SizedBox(
          height: 10,
        ),
        Text(
          "${student.name}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(
          height: 10,
        ),
        kIsWeb
            ? ListTile()
            : ListTile(
                title: const Text("Invite"),
                leading: const Icon(Icons.group_add_outlined),
                onTap: () async {
                  //look up email
                  try {
                    final res = await directorySearch(student.name);
                    print(res);
                    final info = await directorySearchInfo(res[0]['cn']);
                    print(info);
                    String? myname = await Matrix.of(context)
                        .client
                        .getDisplayName(Matrix.of(context).client.userID!);
                    String courseName = await Matrix.of(context)
                        .client
                        .getRoomById(Matrix.of(context).activeRoomId!)!
                        .getLocalizedDisplayname();
                    launchUrl(Uri.parse(
                        'mailto:${info['email']}?subject=$courseName Group Chat&body=Hey, I wanted to invite you to our group chat!\nDownload the CourseBubble app on IOS or Android, or go to https://coursebubble.online'));
                    Navigator.pop(context);
                  } catch (e, t) {
                    print(e);
                    print(t);
                    Navigator.pop(context);
                    await Future.delayed(Duration(milliseconds: 3));
                  }
                }),
      ],
    );
  }
}
