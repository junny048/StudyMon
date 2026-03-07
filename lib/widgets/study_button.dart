import 'package:flutter/material.dart';

class StudyButton extends StatelessWidget {
  const StudyButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Start Study'),
      ),
    );
  }
}
