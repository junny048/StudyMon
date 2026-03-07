import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studymon/models/study_session.dart';
import 'package:studymon/services/study_service.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({
    super.key,
    required this.userId,
    required this.studyService,
  });

  final String userId;
  final StudyService studyService;

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  static const List<int> _presetMinutes = <int>[25, 50];

  Timer? _ticker;
  Duration _selectedDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  bool _isRunning = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) {
      return;
    }

    widget.studyService.start();

    setState(() {
      _isRunning = true;
      _remaining = _selectedDuration;
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }

      if (_remaining.inSeconds <= 1) {
        _completeSession();
        return;
      }

      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
    });
  }

  void _completeSession() {
    _ticker?.cancel();

    final StudySession? session = widget.studyService.complete(
      userId: widget.userId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
    });

    Navigator.of(context).pop(session);
  }

  Future<void> _pickCustomMinutes() async {
    final TextEditingController controller = TextEditingController();
    final int? minutes = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Minutes'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter minutes'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final int? value = int.tryParse(controller.text.trim());
                Navigator.of(context).pop(value);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (minutes == null || minutes <= 0) {
      return;
    }

    setState(() {
      _selectedDuration = Duration(minutes: minutes);
      _remaining = _selectedDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final int minutes in _presetMinutes)
                  ChoiceChip(
                    label: Text('$minutes min'),
                    selected: _selectedDuration.inMinutes == minutes,
                    onSelected: _isRunning
                        ? null
                        : (_) {
                            setState(() {
                              _selectedDuration = Duration(minutes: minutes);
                              _remaining = _selectedDuration;
                            });
                          },
                  ),
                ActionChip(
                  label: const Text('Custom'),
                  onPressed: _isRunning ? null : _pickCustomMinutes,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                _formatClock(_remaining),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isRunning ? null : _startTimer,
                child: const Text('Start Study'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isRunning ? _completeSession : null,
                child: const Text('End Early'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatClock(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
