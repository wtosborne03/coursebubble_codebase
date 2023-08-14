import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:coursebubble/main.dart';
import 'package:coursebubble/utils/canvas_dart.dart';
import 'package:coursebubble/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:matrix/matrix.dart';

List<dynamic> ClassData = [];

class UserData {
  String bURL = "api.coursebubble.online";
  static String accessToken = "";

  UserData() {}

  void start() async {
    final token = await getAccessToken(navigatorKey.currentContext!);
    final api = CanvasAPI('', token);
    ClassData = await api.getCourses();

    final String userId =
        Matrix.of(navigatorKey.currentContext!).client.userID!;
    var got = await getUserData(userId);

    print(got.data);
    if (got.data['major'] == null) {
      print("FETCHING NEW USER DATA");
      final token = await getAccessToken(navigatorKey.currentContext!);
      final api = CanvasAPI('', token);
      final name = await api.getName();
      List<dynamic> info = await directorySearch(name);
      print(info);

      final student = info.firstWhere((student) =>
          student['name']['first'] == name.split(' ')[0] &&
          student['name']['last'] == name.split(' ')[1]);

      final String major = student['major'];

      await setUserData({'major': major});

      final Uint8List im = await api.getProfile();
      final MatrixFile avatar = MatrixFile(bytes: im, name: 'avatar');
      Matrix.of(navigatorKey.currentContext!).client.setAvatar(avatar);
    }
  }

  dynamic setUserData(Map<String, dynamic> data) async {
    await dio!
        .postUri(
            Uri.https(bURL,
                "users/set/${Matrix.of(navigatorKey.currentContext!).client.userID!}"),
            data: data)
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
  }

  Future<dynamic> getUserData(String userID) async {
    var res = await dio!
        .getUri(
      Uri.https(bURL, "users/get/${userID}"),
    )
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return res;
  }

  dynamic getAccessToken(BuildContext context) async {
    if (accessToken == "") {
      Response res = await get(
          Uri.https(bURL, "users/get/${Matrix.of(context).client.userID!}"),
          headers: {
            "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json',
            'Accept': '*/*'
          }).catchError((Object e, StackTrace t) {
        throw (e);
      });
      var data = jsonDecode(res.body);
      accessToken = data['token'];
      return accessToken;
    } else {
      return accessToken;
    }
  }
}
