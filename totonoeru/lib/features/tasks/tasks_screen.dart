import 'package:flutter/material.dart';
import '../../shared/widgets/app_fab.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: const Center(child: Text('Task list — Week 2', style: TextStyle(fontFamily: 'DMSans'))),
      floatingActionButton: AppFab(onAddTask: () {}, onAddTimeBlock: () {}),
    );
  }
}
