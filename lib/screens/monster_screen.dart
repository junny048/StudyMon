import 'package:flutter/material.dart';
import 'package:studymon/models/monster.dart';
import 'package:studymon/models/study_session.dart';

class MonsterScreen extends StatelessWidget {
  const MonsterScreen({
    super.key,
    required this.monster,
    required this.sessions,
  });

  final Monster monster;
  final List<StudySession> sessions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monster Status')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(monster.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Level: ${monster.level}'),
          Text('Total EXP: ${monster.exp}'),
          Text('Next Required EXP: ${monster.requiredExp}'),
          const SizedBox(height: 20),
          Text(
            'Recent Sessions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final session in sessions.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer_outlined),
              title: Text('${session.duration.inMinutes} min'),
              subtitle: Text(session.startTime.toLocal().toString()),
              trailing: Text('+${session.expGained} EXP'),
            ),
        ],
      ),
    );
  }
}
