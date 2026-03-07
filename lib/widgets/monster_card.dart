import 'package:flutter/material.dart';
import 'package:studymon/models/monster.dart';

class MonsterCard extends StatelessWidget {
  const MonsterCard({super.key, required this.monster});

  final Monster monster;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(monster.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Lv ${monster.level}'),
            Text('EXP ${monster.exp}/${monster.requiredExp}'),
          ],
        ),
      ),
    );
  }
}
