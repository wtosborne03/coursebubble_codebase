import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:vrouter/vrouter.dart';

import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/config/setting_keys.dart';
import 'package:coursebubble/utils/platform_infos.dart';
import 'package:coursebubble/utils/voip/callkeep_manager.dart';
import 'package:coursebubble/widgets/layouts/max_width_body.dart';
import 'package:coursebubble/widgets/matrix.dart';
import 'package:coursebubble/widgets/settings_switch_list_tile.dart';
import 'settings_chat.dart';

class SettingsChatView extends StatelessWidget {
  final SettingsChatController controller;
  const SettingsChatView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context)!.chat)),
      body: ListTileTheme(
        iconColor: Theme.of(context).textTheme.bodyLarge!.color,
        child: MaxWidthBody(
          withScrolling: true,
          child: Column(
            children: [
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.hideRedactedEvents,
                onChanged: (b) => AppConfig.hideRedactedEvents = b,
                storeKey: SettingKeys.hideRedactedEvents,
                defaultValue: AppConfig.hideRedactedEvents,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.hideUnknownEvents,
                onChanged: (b) => AppConfig.hideUnknownEvents = b,
                storeKey: SettingKeys.hideUnknownEvents,
                defaultValue: AppConfig.hideUnknownEvents,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.hideUnimportantStateEvents,
                onChanged: (b) => AppConfig.hideUnimportantStateEvents = b,
                storeKey: SettingKeys.hideUnimportantStateEvents,
                defaultValue: AppConfig.hideUnimportantStateEvents,
              ),
              if (PlatformInfos.isMobile)
                SettingsSwitchListTile.adaptive(
                  title: L10n.of(context)!.autoplayImages,
                  onChanged: (b) => AppConfig.autoplayImages = b,
                  storeKey: SettingKeys.autoplayImages,
                  defaultValue: AppConfig.autoplayImages,
                ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.sendOnEnter,
                onChanged: (b) => AppConfig.sendOnEnter = b,
                storeKey: SettingKeys.sendOnEnter,
                defaultValue: AppConfig.sendOnEnter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
