import 'dart:convert';

import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/pages/assignments/AssignmentItem.dart';
import 'package:coursebubble/utils/canvas_dart.dart';
import 'package:coursebubble/utils/string_color.dart';
import 'package:coursebubble/utils/userData.dart';
import 'package:coursebubble/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Assignment {
  final String title;
  final String description;
  final DateTime dueDate;

  Assignment(this.title, this.description, this.dueDate);
}

class ClassDate {
  ClassDate(this.eventName, this.from, this.to, this.background, this.isAllDay,
      this.notes, this.course);
  String course;
  String notes;
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class AssignmentsPage extends StatefulWidget {
  AssignmentsPageState createState() => AssignmentsPageState();
}

class AssignmentsPageState extends State<AssignmentsPage> {
  bool loaded = false;
  List<ClassDate> fdates = [];
  bool hastoke = true;
  bool none = false;

  Future loadDates() async {
    String bURL = "https://clemson.instructure.com/api/v1/";
    var token = await UserData().getAccessToken(context);
    if (token == null) {
      setState(() {
        hastoke = false;
      });
      return;
    }
    var api = CanvasAPI(bURL, token);
    var response = await api.getDates();
    print(response.runtimeType);

    dynamic ASJson = response;

    List<ClassDate> dates = [];
    ASJson.forEach((e) {
      ClassDate date = ClassDate(
          e['title'] ?? '',
          DateTime.parse(e['end_at']).toLocal(),
          DateTime.parse(e['end_at']).toLocal(),
          Colors.amber,
          e['all_day'] ?? false,
          e['html_url'] ?? '',
          e['context_name']);
      dates.add(date);
    });
    if (!mounted) return;
    setState(() {
      loaded = true;
      fdates = dates;
    });
  }

  @override
  void initState() {
    loadDates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int oldday = 0;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Upcoming Assignments",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: none
            ? const Center(
                child: Text(
                "No Assignments Upcoming",
                style: TextStyle(fontSize: 20),
              ))
            : loaded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.separated(
                      itemCount: fdates.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 6,
                        );
                      },
                      itemBuilder: (context, index) {
                        final assignment = fdates[index];
                        if (fdates[index].to.day != oldday) {
                          oldday = fdates[index].to.day;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text(DateFormat('MM-dd')
                                      .format(fdates[index].to)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Divider(),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              AssignmentWidget(context, assignment)
                            ],
                          );
                        } else {
                          return AssignmentWidget(context, assignment);
                        }
                      },
                    ))
                : const Center(child: CircularProgressIndicator()));
  }
}

Widget AssignmentWidget(BuildContext context, ClassDate date) {
  return InkWell(
      overlayColor: MaterialStatePropertyAll(
          Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.black.withAlpha(100)),
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      onTap: () {
        String url = date.notes;
        OpenCanvasUrl(url);
      },
      child: Material(
          type: MaterialType.canvas,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          color: date.course.lightColorAvatar.withAlpha(210),
          child: Padding(
            padding: EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                date.eventName,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color:
                        Theme.of(context).primaryTextTheme.bodyMedium!.color),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(
                    date.course,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .bodyMedium!
                            .color),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Due " + DateFormat(DateFormat.HOUR_MINUTE).format(date.to),
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.bodyMedium!.color),
                )
              ])
            ]),
          )));
}
