import 'package:flutter/material.dart';
import '../../shared/widgets/app_fab.dart';

enum ScheduleView { day, week, month }

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key, this.initialView = ScheduleView.day});
  final ScheduleView initialView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: const Center(child: Text('Schedule — Week 3', style: TextStyle(fontFamily: 'DMSans'))),
      floatingActionButton: AppFab(onAddTask: () {}, onAddTimeBlock: () {}),
    );
  }
}
