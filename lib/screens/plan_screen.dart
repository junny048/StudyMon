import 'package:flutter/material.dart';
import 'package:studymon/services/ai_planner_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.aiPlannerService});

  final AiPlannerService aiPlannerService;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController(
    text: '4',
  );
  DateTime _examDate = DateTime.now().add(const Duration(days: 30));
  List<String> _planItems = <String>[];
  bool _loading = false;

  @override
  void dispose() {
    _goalController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    final String goal = _goalController.text.trim();
    final int hours = int.tryParse(_hoursController.text.trim()) ?? 0;

    if (goal.isEmpty || hours <= 0) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final List<String> result = await widget.aiPlannerService.generateDailyPlan(
      examDate: _examDate,
      goal: goal,
      availableHours: hours,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _planItems = result;
      _loading = false;
    });
  }

  Future<void> _pickExamDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      initialDate: _examDate,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _examDate = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Daily Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Goal',
              hintText: 'e.g. Midterm math prep',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _hoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Available Hours'),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exam Date'),
            subtitle: Text(_examDate.toLocal().toString().split(' ').first),
            trailing: IconButton(
              onPressed: _pickExamDate,
              icon: const Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _generatePlan,
            child: Text(_loading ? 'Generating...' : 'Generate Plan'),
          ),
          const SizedBox(height: 16),
          for (final String item in _planItems)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(item),
            ),
        ],
      ),
    );
  }
}
