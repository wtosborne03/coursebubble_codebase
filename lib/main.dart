import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:matrix/matrix.dart';
import 'package:universal_html/html.dart' as html;

import 'package:coursebubble/utils/client_manager.dart';
import 'package:coursebubble/utils/platform_infos.dart';
import 'utils/background_push.dart';
import 'widgets/fluffy_chat_app.dart';
import 'widgets/lock_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Dio? dio;
Client? global_matrix;
void main() async {
  // Our background push shared isolate accesses flutter-internal things very early in the startup proccess
  // To make sure that the parts of flutter needed are started up already, we need to ensure that the
  // widget bindings are initialized already.
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
            channelShowBadge: true,
            playSound: true,
            soundSource: 'resource://raw/pop',
            defaultColor: Colors.white,
            channelGroupKey: 'channel_group',
            channelKey: 'channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'channel_group', channelGroupName: 'Basic group')
      ],
      debug: true);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logs().nativeColors = !PlatformInfos.isIOS;
  final clients = await ClientManager.getClients();

  final options = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

  // Preload first client
  final firstClient = clients.firstOrNull;
  await firstClient?.roomsLoading;
  await firstClient?.accountDataLoading;

  if (PlatformInfos.isMobile) {
    BackgroundPush.clientOnly(clients.first);
  }

  final queryParameters = <String, String>{};
  if (kIsWeb) {
    queryParameters
        .addAll(Uri.parse(html.window.location.href).queryParameters);
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    PlatformInfos.isMobile
        ? AppLock(
            builder: (args) => FluffyChatApp(
              clients: clients,
              queryParameters: queryParameters,
            ),
            lockScreen: const LockScreen(),
            enabled: false,
          )
        : FluffyChatApp(
            clients: clients,
            queryParameters: queryParameters,
          ),
  );
}
