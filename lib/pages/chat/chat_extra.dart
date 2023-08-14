import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/pages/chat/chat.dart';
import 'package:coursebubble/utils/platform_infos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

Widget ExtraMenu(BuildContext context, ChatController controller) {
  return Padding(
    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
    child: GridView.count(
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      shrinkWrap: true,
      crossAxisCount: 3,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          onTap: () {
            controller.onAddPopupMenuButtonSelected("file");
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightBlue.withAlpha(70),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attachment_rounded),
                SizedBox(height: 8),
                Text(L10n.of(context)!.sendFile),
              ],
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          onTap: () {
            controller.onAddPopupMenuButtonSelected("image");
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.red.withAlpha(70),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_rounded),
                SizedBox(height: 8),
                Text('Gallery'),
              ],
            ),
          ),
        ),
        if (PlatformInfos.isMobile)
          InkWell(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            onTap: () {
              controller.onAddPopupMenuButtonSelected("camera");
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.deepOrange.withAlpha(70),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded),
                  SizedBox(height: 8),
                  Text('Photo'),
                ],
              ),
            ),
          ),
        if (PlatformInfos.isMobile)
          InkWell(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            onTap: () {
              controller.onAddPopupMenuButtonSelected("camera-video");
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.lightGreen.withAlpha(70),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_chat),
                  SizedBox(height: 8),
                  Text(
                    'Video',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        if (controller.room.getImagePacks(ImagePackUsage.sticker).isNotEmpty)
          InkWell(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            onTap: () {
              controller.onAddPopupMenuButtonSelected("sticker");
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(70),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sticky_note_2_rounded),
                  SizedBox(height: 8),
                  Text(L10n.of(context)!.sendSticker),
                ],
              ),
            ),
          ),
        if (PlatformInfos.isMobile)
          InkWell(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            onTap: () {
              controller.onAddPopupMenuButtonSelected("location");
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(70),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map),
                  SizedBox(height: 8),
                  Text(
                    'Location',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
