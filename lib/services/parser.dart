import 'dart:convert';

class IrregularVerb {
  final String verb;
  final String v1;
  final String v2;
  final String v3;
  final List<String> examples;
  final List<MultipleChoiceQuestion> questions;
  final String explanation;

  IrregularVerb({
    required this.verb,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.examples,
    required this.questions,
    required this.explanation,
  });

  @override
  String toString() {
    return 'IrregularVerb(verb: $verb, v1: $v1, v2: $v2, v3: $v3, examples: $examples, questions: $questions, explanation: $explanation)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'verb': verb,
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'examples': examples,
      'questions': questions.map((x) => x.toMap()).toList(),
      'explanation': explanation,
    };
  }

  factory IrregularVerb.fromMap(Map<String, dynamic> map) {
    return IrregularVerb(
      verb: map['verb'] as String,
      v1: map['v1'] as String,
      v2: map['v2'] as String,
      v3: map['v3'] as String,
      examples:
          (map['examples'] as List).map((item) => item as String).toList(),
      questions:
          (map['questions'] as List)
              .map(
                (x) =>
                    MultipleChoiceQuestion.fromMap(x as Map<String, dynamic>),
              )
              .toList(),

      explanation: map['explanation'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory IrregularVerb.fromJson(String source) =>
      IrregularVerb.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MultipleChoiceQuestion {
  final String question;
  final List<String> choices;
  final String correctAnswer;

  MultipleChoiceQuestion({
    required this.question,
    required this.choices,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'question': question,
      'choices': choices,
      'correctAnswer': correctAnswer,
    };
  }

  factory MultipleChoiceQuestion.fromMap(Map<String, dynamic> map) {
    return MultipleChoiceQuestion(
      question: map['question'] as String,
      choices: List<String>.from(map['choices']),
      correctAnswer: map['correctAnswer'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MultipleChoiceQuestion.fromJson(String source) =>
      MultipleChoiceQuestion.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}

List<IrregularVerb> parseIrregularVerbs(String input) {
  final verbBlocks = input.split(RegExp(r'\*\*Verb \d+:')).skip(1);
  final List<IrregularVerb> verbs = [];

  for (final block in verbBlocks) {
    final lines =
        block
            .trim()
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
    final verbTitle = lines[0].replaceAll('**', '').trim();
    final verb = verbTitle;

    String v1 = '', v2 = '', v3 = '';
    List<String> examples = [];
    List<MultipleChoiceQuestion> questions = [];
    String explanation = '';
    String answerKeyLine = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('* **V1:**')) v1 = line.split(':**')[1].trim();
      if (line.startsWith('* **V2:**')) v2 = line.split(':**')[1].trim();
      if (line.startsWith('* **V3:**')) v3 = line.split(':**')[1].trim();

      if (line.startsWith('* **Examples:**')) {
        i++;
        while (i < lines.length && lines[i].startsWith('* V')) {
          examples.add(lines[i].replaceAll(RegExp(r'^\*\s*'), '').trim());
          i++;
        }
        i--;
      }

      if (line.contains('* **Multiple Choice Questions:**')) {
        i++;
        while (i < lines.length && RegExp(r'^\d+\.\s').hasMatch(lines[i])) {
          String questionLine = lines[i];
          List<String> questionLines = [questionLine];
          i++;
          while (i < lines.length && RegExp(r'^[a-d]\)').hasMatch(lines[i])) {
            questionLines.add(lines[i]);
            i++;
          }

          final questionText =
              questionLine.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
          final choices =
              questionLines
                  .skip(1)
                  .map((c) {
                    final withoutLabel = parseOptions(c);
                    return withoutLabel.split(' ');
                  })
                  .expand((x) => x)
                  .where((s) => s.isNotEmpty)
                  .toList();

          questions.add(
            MultipleChoiceQuestion(
              question: questionText,
              choices: choices,
              correctAnswer: '',
            ),
          );
        }
        i--;
      }

      if (line.startsWith('* **Answer key:**')) {
        answerKeyLine = line.replaceAll('* **Answer key:**', '').trim();
      }
      if (line.startsWith('* **Explanation:**')) {
        explanation = line.replaceAll('* **Explanation:**', '').trim();
      }
    }

    final correctAnswers =
        answerKeyLine
            .split(',')
            .asMap()
            .map((k, v) => MapEntry(k, v.trim().split(':').last.trim()))
            .values
            .toList();

    for (int i = 0; i < correctAnswers.length && i < questions.length; i++) {
      final optionIndex = ['a', 'b', 'c', 'd'].indexOf(correctAnswers[i]);
      if (optionIndex >= 0 && optionIndex < questions[i].choices.length) {
        questions[i] = MultipleChoiceQuestion(
          question: questions[i].question,
          choices: questions[i].choices,
          correctAnswer: questions[i].choices[optionIndex],
        );
      }
    }

    verbs.add(
      IrregularVerb(
        verb: verb,
        v1: v1,
        v2: v2,
        v3: v3,
        examples: examples,
        questions: questions,
        explanation: explanation.trim(),
      ),
    );
  }
  return verbs;
}

String parseOptions(String input) {
  final regex = RegExp(r'[a-d]\)\s*([^\s]+)\s*');
  final matches = regex.allMatches(input);
  return matches.map((m) => m.group(1)!).join(' ');
}
