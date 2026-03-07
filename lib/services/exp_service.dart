import 'package:studymon/models/study_session.dart';

class ExpService {
  int calculateExp(Duration duration) {
    final int minutes = duration.inMinutes;

    if (minutes < 10) {
      return 0;
    }
    if (minutes < 30) {
      return 5;
    }
    if (minutes < 60) {
      return 20;
    }
    return 50 + ((minutes - 60) ~/ 30) * 20;
  }

  int totalExp(List<StudySession> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.expGained);
  }
}
