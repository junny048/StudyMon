class AiPlannerService {
  Future<List<String>> generateDailyPlan({
    required DateTime examDate,
    required String goal,
    required int availableHours,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return <String>[
      '09:00 - Core study (${goal.trim()})',
      '14:00 - Practice problems',
      '19:00 - Review and summary',
      'Exam D-${examDate.difference(DateTime.now()).inDays.abs()}',
      'Available time: ${availableHours}h',
    ];
  }
}
