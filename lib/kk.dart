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
    // Extract verb name
    final verbTitle = lines[0].replaceAll('**', '').trim();
    final verb = verbTitle;

    String v1 = '', v2 = '', v3 = '';
    List<String> examples = [];
    List<MultipleChoiceQuestion> questions = [];
    String explanation = '';
    String answerKeyLine = '';
    // Process lines
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      print(line);
      // Extract verb forms
      if (line.startsWith('* **V1:**')) v1 = line.split(':**')[1].trim();
      if (line.startsWith('* **V2:**')) v2 = line.split(':**')[1].trim();
      if (line.startsWith('* **V3:**')) v3 = line.split(':**')[1].trim();

      // Extract examples
      if (line.startsWith('* **Examples:**')) {
        i++;
        while (i < lines.length && lines[i].startsWith('* V')) {
          examples.add(lines[i].replaceAll(RegExp(r'^\*\s*'), '').trim());
          i++;
        }
        i--; // Backtrack after loop
      }

      // Extract questions
      if (line.contains('* **Multiple Choice Questions:**')) {
        i++;
        while (i < lines.length && RegExp(r'^\d+\.\s').hasMatch(lines[i])) {
          String questionLine = lines[i];
          List<String> questionLines = [questionLine];
          i++;
          // Collect options (a), b), c), d))
          while (i < lines.length && RegExp(r'^[a-d]\)').hasMatch(lines[i])) {
            questionLines.add(lines[i]);
            i++;
          } // Backtrack after loop

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
              correctAnswer: '', // Temporary, fill in later
            ),
          );
        }
        i--;
      }

      // Extract answer key
      if (line.startsWith('* **Answer key:**')) {
        answerKeyLine = line.replaceAll('* **Answer key:**', '').trim();
      }

      // Extract explanation (multi-line)
      if (line.startsWith('* **Explanation:**')) {
        explanation = line.replaceAll('* **Explanation:**', '').trim();
        print('Explanation: $explanation'); // Debug print
      }
    }

    // Apply answer key to questions
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

// Example usage
void main() {
  String input = '''
**Verb 1: Go**

* **V1:** go
* **V2:** went
* **V3:** gone

* **Examples:**
    * V1: I **go** to school every day.
    * V2:  She **went** to the park yesterday.
    * V3:  They have **gone** home.

* **Multiple Choice Questions:**

    1.  Which is the correct past tense of "go"?
        a) go   b) goes   c) went   d) goed
    2.  Complete the sentence:  He has _______ to the store.
        a) go   b) went   c) going   d) gone
    3.  I ______ to the beach last summer.
        a) went   b) gone   c) will go   d) go
    4.  They ______ for a walk every morning.
        a) went   b) go   c) gone   d) going
    5.  Have you ever ______ to Europe?
        a) go   b) went   c) going   d) gone

* **Explanation:** "Go" is an irregular verb.  The present tense (V1) is simply "go." The past tense (V2) is "went," and the past participle (V3) is "gone,"  used with auxiliary verbs like "have," "has," or "had" to form perfect tenses (e.g., "have gone," "had gone").

* **Answer key:** 1: c, 2: d, 3: a, 4: b, 5: d

''';

  List<IrregularVerb> verbs = parseIrregularVerbs(input);

  for (var verb in verbs) {
    print('Verb: ${verb.verb}');
    print('Forms: V1=${verb.v1}, V2=${verb.v2}, V3=${verb.v3}');
    print('Examples: ${verb.examples}');
    print('Questions:');
    for (var q in verb.questions) {
      print('  ${q.question}');
      print('  Choices: ${q.choices}');
      print('  Correct: ${q.correctAnswer}');
    }
    print('Explanation: ${verb.explanation}');
    print('');
  }
}

String parseOptions(String input) {
  final regex = RegExp(r'[a-d]\)\s*([^\s]+)\s*');
  final matches = regex.allMatches(input);
  return matches.map((m) => m.group(1)!).join(' ');
}
