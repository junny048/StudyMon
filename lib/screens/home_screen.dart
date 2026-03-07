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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          const _HomeBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MonsterCard(monster: monster),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ExpBar(
                        progress: monster.progressToNextLevel,
                        label: 'EXP Progress',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0x140A7A5A),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.schedule_rounded),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Today Study Time',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              Text(
                                _formatDuration(todayStudyTime),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  StudyButton(onPressed: onStartStudy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFE8F6EF),
            Color(0xFFF6F3E9),
            Color(0xFFF1F5EF),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -60,
            right: -20,
            child: _blob(160, const Color(0x3320B486)),
          ),
          Positioned(
            bottom: 120,
            left: -45,
            child: _blob(130, const Color(0x26E8B44B)),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
