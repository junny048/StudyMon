import 'package:studymon/models/study_session.dart';
import 'package:studymon/services/exp_service.dart';

class StudyService {
  StudyService(this._expService);

  final ExpService _expService;

  DateTime? _startedAt;

  DateTime? get startedAt => _startedAt;

  void start() {
    _startedAt = DateTime.now();
  }

  StudySession? complete({required String userId}) {
    if (_startedAt == null) {
      return null;
    }

    final DateTime end = DateTime.now();
    final Duration duration = end.difference(_startedAt!);
    final int exp = _expService.calculateExp(duration);

    final session = StudySession(
      id: 'session-${end.microsecondsSinceEpoch}',
      userId: userId,
      startTime: _startedAt!,
      endTime: end,
      duration: duration,
      expGained: exp,
    );

    _startedAt = null;
    return session;
  }
}
