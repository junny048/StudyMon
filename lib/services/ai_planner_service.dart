import 'dart:convert';

import 'package:http/http.dart' as http;

class AiPlannerService {
  AiPlannerService({String? apiKey, String? model, http.Client? client})
    : _apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY'),
      _model =
          model ??
          const String.fromEnvironment(
            'OPENAI_MODEL',
            defaultValue: 'gpt-4.1-mini',
          ),
      _client = client ?? http.Client();

  final String _apiKey;
  final String _model;
  final http.Client _client;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<List<String>> generateDailyPlan({
    required DateTime examDate,
    required String goal,
    required int availableHours,
  }) async {
    if (!isConfigured) {
      return _fallbackPlan(
        examDate: examDate,
        goal: goal,
        availableHours: availableHours,
      );
    }

    try {
      final List<String> plan = await _generateWithOpenAi(
        examDate: examDate,
        goal: goal,
        availableHours: availableHours,
      );

      if (plan.isNotEmpty) {
        return plan;
      }
    } catch (_) {}

    return _fallbackPlan(
      examDate: examDate,
      goal: goal,
      availableHours: availableHours,
    );
  }

  Future<List<String>> _generateWithOpenAi({
    required DateTime examDate,
    required String goal,
    required int availableHours,
  }) async {
    final DateTime now = DateTime.now();
    final int dDay = examDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    final Uri uri = Uri.parse('https://api.openai.com/v1/responses');

    final Map<String, Object> body = <String, Object>{
      'model': _model,
      'max_output_tokens': 250,
      'input': <Map<String, Object>>[
        <String, Object>{
          'role': 'system',
          'content': <Map<String, String>>[
            <String, String>{
              'type': 'input_text',
              'text':
                  'Create a one-day study plan. Return only 5 concise bullet lines in plain text. '
                  'Each line must start with "- ".',
            },
          ],
        },
        <String, Object>{
          'role': 'user',
          'content': <Map<String, String>>[
            <String, String>{
              'type': 'input_text',
              'text':
                  'Goal: $goal\nExam D-$dDay\nAvailable hours: $availableHours',
            },
          ],
        },
      ],
    };

    final http.Response response = await _client
        .post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OpenAI request failed: ${response.statusCode}');
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final String outputText = _extractOutputText(decoded);

    return outputText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^[-*]\s*'), ''))
        .take(5)
        .toList();
  }

  String _extractOutputText(Map<String, dynamic> decoded) {
    final String? direct = decoded['output_text'] as String?;
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final List<dynamic>? output = decoded['output'] as List<dynamic>?;
    if (output == null) {
      return '';
    }

    final StringBuffer buffer = StringBuffer();

    for (final dynamic item in output) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final List<dynamic>? content = item['content'] as List<dynamic>?;
      if (content == null) {
        continue;
      }

      for (final dynamic chunk in content) {
        if (chunk is! Map<String, dynamic>) {
          continue;
        }
        final String? text = chunk['text'] as String?;
        if (text != null && text.isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
          }
          buffer.write(text);
        }
      }
    }

    return buffer.toString();
  }

  List<String> _fallbackPlan({
    required DateTime examDate,
    required String goal,
    required int availableHours,
  }) {
    final int dDay = examDate.difference(DateTime.now()).inDays.abs();

    return <String>[
      '09:00 - Core study ($goal)',
      '14:00 - Practice problems',
      '19:00 - Review and summary',
      'Exam D-$dDay',
      'Available time: ${availableHours}h',
    ];
  }
}
