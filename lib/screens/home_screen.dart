import 'package:flutter/material.dart';
import 'package:studymon/models/monster.dart';
import 'package:studymon/widgets/exp_bar.dart';
import 'package:studymon/widgets/monster_card.dart';
import 'package:studymon/widgets/study_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.monster,
    required this.todayStudyTime,
    required this.onStartStudy,
    required this.onOpenMonster,
    required this.onOpenPlanner,
  });

  final Monster monster;
  final Duration todayStudyTime;
  final VoidCallback onStartStudy;
  final VoidCallback onOpenMonster;
  final VoidCallback onOpenPlanner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMon'),
        actions: <Widget>[
          IconButton(
            onPressed: onOpenPlanner,
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Plan',
          ),
          IconButton(
            onPressed: onOpenMonster,
            icon: const Icon(Icons.pets_outlined),
            tooltip: 'Monster',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MonsterCard(monster: monster),
            const SizedBox(height: 12),
            ExpBar(
              progress: monster.progressToNextLevel,
              label: 'EXP Progress',
            ),
            const SizedBox(height: 20),
            Text(
              'Today Study Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              _formatDuration(todayStudyTime),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            StudyButton(onPressed: onStartStudy),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
