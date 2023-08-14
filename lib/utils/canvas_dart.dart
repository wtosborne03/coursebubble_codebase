import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:coursebubble/main.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

String ClemsonBaseUrl = "https://clemson.instructure.com/api/v1/";

class CanvasAPI {
  String bURL = "https://clemson.instructure.com/api/v1/";
  String token = "";

  CanvasAPI(baseURL, accessToken) {
    this.bURL = 'api.coursebubble.online'; //override for passthrough
    this.token = accessToken;
  }

  dynamic getCourses() async {
    Response res = await dio!
        .getUri(Uri.https(bURL, "canvas/courses/" + token),
            options: Options(headers: {"content-type": "application/json"}))
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return res.data;
  }

  dynamic getDates() async {
    var res = await dio!
        .getUri(Uri.https(bURL, "canvas/dates/" + token),
            options: Options(headers: {"content-type": "application/json"}))
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return res.data;
  }

  dynamic getActivityStream() async {
    Response res = await dio!
        .getUri(Uri.https(bURL, "/canvas/activities/" + token),
            options: Options(headers: {"content-type": "application/json"}))
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return jsonDecode(res.data);
  }

  dynamic getStudents(String course, int page) async {
    Response res = await dio!
        .getUri(
            Uri.https(
                bURL,
                "/canvas/students/" +
                    token +
                    "/" +
                    course +
                    "/" +
                    page.toString()),
            options: Options(headers: {"content-type": "application/json"}))
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return res.data;
  }

  Future<String> getName() async {
    Response res = await dio!
        .getUri(Uri.https(bURL, "/canvas/name/" + token),
            options: Options(headers: {"content-type": "application/json"}))
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return res.data as String;
  }

  Future<Uint8List> getProfile() async {
    Response res = await dio!
        .getUri(
      Uri.https(bURL, "canvas/profile/$token"),
    )
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    String iurl = res.data;
    var img = await dio!.getUri(Uri.parse(iurl),
        options: Options(responseType: ResponseType.bytes));
    return img.data;
  }

  Future<dynamic> getAssignments(String courseId) async {
    var res = await dio!
        .getUri(Uri.parse(bURL + "/assignments/" + token + "/" + courseId),
            options: Options(headers: {"content-type": "application/json"}))
        .catchError((Object e, StackTrace t) {
      throw (e);
    });
    return res.data;
  }
}

Future<dynamic> directorySearch(String name) async {
  Uri req = Uri.https('api.coursebubble.online',
      '/canvas/dsearch/' + name.replaceAll(' ', '+'));
  Response res = (await dio!
      .getUri(
    req,
  )
      .catchError((Object e, StackTrace t) {
    throw (e);
  }));

  var names = res.data;
  return names;
}

Future<dynamic> directorySearchInfo(String cn) async {
  Uri req = Uri.https('api.coursebubble.online', '/canvas/dsearchinfo/' + cn);
  Response res = await dio!
      .getUri(
    req,
  )
      .catchError((Object e, StackTrace t) {
    throw (e);
  });
  var names = res.data;
  return names;
}

Future<void> OpenCanvasUrl(String url) async {
  if (await canLaunchUrl(Uri.parse('canvas-courses://'))) {
    print("LAUNCH");
    launchUrl(Uri.parse('canvas-courses://' + url.split('//')[1]));
  } else {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
