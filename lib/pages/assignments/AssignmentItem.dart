import 'package:coursebubble/pages/assignments/assignments.dart';
import 'package:flutter/material.dart';

class AssignmentItem extends StatelessWidget {
  const AssignmentItem({super.key, required this.assignment});
  final Assignment assignment;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(assignment.title),
      subtitle: Text(assignment.description),
      trailing: Text(
        '${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
      ),
    );
  }
}
