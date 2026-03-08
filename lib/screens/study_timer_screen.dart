import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studymon/models/app_block_target.dart';
import 'package:studymon/models/study_session.dart';
import 'package:studymon/services/focus_mode_service.dart';
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

  final FocusModeService _focusModeService = FocusModeService.instance;

  Timer? _ticker;
  Duration _selectedDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  bool _isRunning = false;
  bool _focusModeEnabled = true;
  bool _focusModeActive = false;
  bool _loadingBlockList = true;
  Set<String> _blockedPackages = <String>{};

  @override
  void initState() {
    super.initState();
    _loadBlockedPackages();

    _focusModeService.setBlockedAppCallback((packageName) async {
      if (!mounted || !_focusModeActive) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blocked app detected: $packageName'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _focusModeService.stopFocusMode();
    _focusModeService.setBlockedAppCallback(null);
    super.dispose();
  }

  Future<void> _loadBlockedPackages() async {
    final List<String> saved = await _focusModeService.loadBlockedPackages();
    if (!mounted) {
      return;
    }

    setState(() {
      _blockedPackages = saved.toSet();
      _loadingBlockList = false;
    });
  }

  Future<void> _startTimer() async {
    if (_isRunning) {
      return;
    }

    if (_focusModeEnabled && _focusModeService.isSupported) {
      final bool granted = await _focusModeService.hasUsagePermission();
      if (!granted) {
        if (!mounted) {
          return;
        }

        final bool openSettings = await _showPermissionDialog();
        if (openSettings) {
          await _focusModeService.openUsageAccessSettings();
        }
        return;
      }

      await _focusModeService.startFocusMode(_blockedPackages.toList());
      _focusModeActive = true;
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
    _focusModeService.stopFocusMode();
    _focusModeActive = false;

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

  Future<bool> _showPermissionDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usage Access Required'),
          content: const Text(
            'Focus Mode app blocking on Android needs Usage Access permission. Open settings now?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );

    return result ?? false;
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
    final double progress =
        1 - (_remaining.inSeconds / _selectedDuration.inSeconds).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Focus Mode (App Blocking)'),
              subtitle: Text(
                _focusModeService.isSupported
                    ? 'Blocks selected apps during timer'
                    : 'Android only',
              ),
              value: _focusModeEnabled,
              onChanged: _isRunning
                  ? null
                  : (value) {
                      setState(() {
                        _focusModeEnabled = value;
                      });
                    },
            ),
            if (_focusModeEnabled) ...<Widget>[
              if (_loadingBlockList)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: LinearProgressIndicator(),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: FocusModeService.defaultTargets
                      .map((target) => _buildBlockChip(target))
                      .toList(),
                ),
              const SizedBox(height: 10),
            ],
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final int minutes in _presetMinutes)
                  ChoiceChip(
                    label: Text('$minutes min'),
                    selected: _selectedDuration.inMinutes == minutes,
                    showCheckmark: false,
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
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF0A7A5A), Color(0xFF1EA07A)],
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x330A7A5A),
                      blurRadius: 26,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        color: const Color(0xFFFFD88A),
                        backgroundColor: const Color(0x33FFFFFF),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _formatClock(_remaining),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Focus Mode',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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

  Widget _buildBlockChip(AppBlockTarget target) {
    return FilterChip(
      label: Text(target.label),
      selected: _blockedPackages.contains(target.packageName),
      onSelected: _isRunning
          ? null
          : (selected) async {
              setState(() {
                if (selected) {
                  _blockedPackages.add(target.packageName);
                } else {
                  _blockedPackages.remove(target.packageName);
                }
              });

              await _focusModeService.saveBlockedPackages(
                _blockedPackages.toList(),
              );
            },
    );
  }

  String _formatClock(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
