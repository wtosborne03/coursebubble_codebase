import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/utils/userData.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import '../../utils/matrix_sdk_extensions/presence_extension.dart';

import 'package:vrouter/vrouter.dart';

import 'package:coursebubble/widgets/avatar.dart';
import 'package:coursebubble/widgets/matrix.dart';

class ProfileBottomSheet extends StatefulWidget {
  final String userId;
  final BuildContext outerContext;
  const ProfileBottomSheet({
    required this.userId,
    required this.outerContext,
    Key? key,
  }) : super(key: key);

  ProfileBottomSheetState createState() => ProfileBottomSheetState();
}

class ProfileBottomSheetState extends State<ProfileBottomSheet> {
  String? major;
  void _startDirectChat(BuildContext context) async {
    final client = Matrix.of(context).client;
    final result = await showFutureLoadingDialog<String>(
      context: context,
      future: () => client.startDirectChat(widget.userId),
    );
    if (result.error == null) {
      VRouter.of(context).toSegments(['rooms', result.result!]);
      Navigator.of(context, rootNavigator: false).pop();
      return;
    }
  }

  @override
  void initState() {
    loadInfo();
    super.initState();
  }

  void loadInfo() async {
    major = (await UserData().getUserData(widget.userId)).data['major'];
    setState(() {
      major = major;
    });
    print("major");
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final presence = client.presences[widget.userId];
    Future<Map<String, Object?>> bio =
        client.getAccountData(widget.userId, 'bio');
    return SafeArea(
      child: FutureBuilder<Profile>(
        future: Matrix.of(context).client.getProfileFromUserId(widget.userId),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              leading: CloseButton(
                onPressed: Navigator.of(context, rootNavigator: false).pop,
              ),
              title: ListTile(
                contentPadding: const EdgeInsets.only(right: 16.0),
                title: Text(
                  profile?.displayName ??
                      widget.userId.localpart ??
                      widget.userId,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            body: ListView(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Avatar(
                        mxContent: profile?.avatarUrl,
                        name: profile?.displayName,
                        size: Avatar.defaultSize * 2,
                        fontSize: 24,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(right: 16.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: Row(children: [
                    major == null
                        ? const SizedBox()
                        : Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppConfig.borderRadius),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(major!),
                          ),
                  ]),
                ),
                presence == null
                    ? SizedBox()
                    : ListTile(
                        contentPadding: const EdgeInsets.only(left: 20.0),
                        title:
                            Text(presence.getLocalizedLastActiveAgo(context)),
                      ),

                /** 
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton.extended(
                    onPressed: () => _startDirectChat(context),
                    label: Text(L10n.of(context)!.newChat),
                    icon: const Icon(Icons.send_outlined),
                  ),
                ),**/

                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
