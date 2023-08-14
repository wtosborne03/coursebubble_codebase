import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';

import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/config/themes.dart';

class LoginScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;

  const LoginScaffold({
    Key? key,
    required this.body,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobileMode = !FluffyThemes.isColumnMode(context);
    final scaffold = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: isMobileMode ? null : Colors.transparent,
          appBar: appBar == null
              ? null
              : AppBar(
                  titleSpacing: appBar?.titleSpacing,
                  automaticallyImplyLeading:
                      appBar?.automaticallyImplyLeading ?? true,
                  centerTitle: appBar?.centerTitle,
                  title: appBar?.title,
                  leading: appBar?.leading,
                  actions: appBar?.actions,
                  backgroundColor: isMobileMode ? null : Colors.transparent,
                ),
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: body,
        ));
    if (isMobileMode) return scaffold;
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(155)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                color: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withOpacity(0.925),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                clipBehavior: Clip.hardEdge,
                elevation: 10,
                shadowColor: Colors.black,
                child: ConstrainedBox(
                  constraints: isMobileMode
                      ? const BoxConstraints()
                      : const BoxConstraints(maxWidth: 480, maxHeight: 640),
                  child: scaffold,
                ),
              ),
            ),
          ),
        ));
  }
}