// This service will be responsible for interacting with Gemini AI
// to generate daily words, their forms, examples, and exercises.

import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'package:vocavoyage/services/parser.dart';

class AIService {
  Future<List<IrregularVerb>> getDailyWords({List<String>? seenWords}) async {
    try {
      // Create the prompt with seen words to avoid repetition
      String seenWordsText =
          seenWords != null && seenWords.isNotEmpty
              ? "These are the words you gave me previously so avoid repetition: ${seenWords.join(', ')}."
              : "";

      String prompt =
          '''Give me five verbs in the form of V1, V2, and V3 with examples for each form and five multiple choice exercises(no more than one answer slot) for each verbs and add brief explanation on how to use each verbs(with their forms) at the under each verb like this:
                  **Verb 1:  Go**
                  * **V1:** Go
                  * **V2:** Went
                  * **V3:** Gone

                  * **Examples:**
                    * V1: I **go** to school every day.
                    * V2:  She **went** to the park yesterday.
                    * V3:  They have **gone** home.
                  * **Multiple Choice Questions:** (the choices must be single words preferably the verbs and follow the following structure)
                    1. Question 1?
                        a) choice 1 b) choice 2 c) choice 3 d) choice 4
                  * **Explanation:** the explanation
                  * **Answer key:** the answers like 1: c, 2: d, 3: a, 4: b, 5: d
              $seenWordsText
              ''';

      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);

      if (response?.output != null) {
        final parsed = parseIrregularVerbs(response!.output!);
        return parsed;
      } else {
        throw Exception('No response from Gemini');
      }
    } catch (e) {
      debugPrint('Error fetching words from Gemini: $e');
      // Return fallback data if Gemini fails
      return [];
    }
  }

  // List<Map<String, dynamic>> _parseGeminiResponse(String response) {
  //   List<Map<String, dynamic>> words = [];

  //   try {
  //     // Split response by verb sections
  //     List<String> verbSections = response.split(RegExp(r'\*\*Verb \d+:'));

  //     for (int i = 1; i < verbSections.length; i++) {
  //       String section = verbSections[i];

  //       // Extract verb name
  //       RegExp verbNameRegex = RegExp(r'\s*([A-Za-z]+)\s*\*\*');
  //       Match? verbMatch = verbNameRegex.firstMatch(section);
  //       if (verbMatch == null) continue;

  //       String verbName = verbMatch.group(1)!.toLowerCase();

  //       // Extract V1, V2, V3
  //       RegExp v1Regex = RegExp(r'\*\s*\*\*V1:\*\*\s*([^\n]+)');
  //       RegExp v2Regex = RegExp(r'\*\s*\*\*V2:\*\*\s*([^\n]+)');
  //       RegExp v3Regex = RegExp(r'\*\s*\*\*V3:\*\*\s*([^\n]+)');

  //       String? v1 = v1Regex.firstMatch(section)?.group(1)?.trim();
  //       String? v2 = v2Regex.firstMatch(section)?.group(1)?.trim();
  //       String? v3 = v3Regex.firstMatch(section)?.group(1)?.trim();

  //       // Extract examples
  //       List<String> examples = [];
  //       RegExp exampleRegex = RegExp(r'V[123]:\s*([^\n]+)');
  //       Iterable<Match> exampleMatches = exampleRegex.allMatches(section);

  //       for (Match match in exampleMatches) {
  //         String example = match.group(1)!.trim();
  //         if (example.isNotEmpty) {
  //           examples.add(example);
  //         }
  //       }

  //       // Extract multiple choice questions
  //       List<Map<String, dynamic>> exercises = [];
  //       RegExp questionRegex = RegExp(
  //         r'(\d+\.\s*[^\n]+\n\s*[a-d]\)[^\n]+(?:\n\s*[a-d]\)[^\n]+)*)',
  //         multiLine: true,
  //       );
  //       Iterable<Match> questionMatches = questionRegex.allMatches(section);

  //       for (Match match in questionMatches) {
  //         String questionBlock = match.group(1)!;

  //         // Extract question text
  //         RegExp qTextRegex = RegExp(r'\d+\.\s*([^\n]+)');
  //         String? questionText =
  //             qTextRegex.firstMatch(questionBlock)?.group(1)?.trim();

  //         // Extract options
  //         RegExp optionsRegex = RegExp(
  //           r'([a-d])\)\s*([^\n]+)',
  //           multiLine: true,
  //         );
  //         List<String> options = [];
  //         String? correctAnswer;

  //         Iterable<Match> optionMatches = optionsRegex.allMatches(
  //           questionBlock,
  //         );
  //         for (Match optionMatch in optionMatches) {
  //           String option = optionMatch.group(2)!.trim();
  //           options.add(option);

  //           // Simple heuristic to find correct answer (this could be improved)
  //           if (correctAnswer == null) {
  //             if (option.contains(v2!) ||
  //                 option.contains(v3!) ||
  //                 option.contains(v1!)) {
  //               correctAnswer = option;
  //             }
  //           }
  //         }

  //         if (questionText != null && options.length >= 4) {
  //           exercises.add({
  //             'question': questionText,
  //             'options': options,
  //             'correctAnswer':
  //                 correctAnswer ?? options[1], // fallback to second option
  //             'type': 'multiple_choice',
  //           });
  //         }
  //       }

  //       if (v1 != null && v2 != null && v3 != null) {
  //         words.add({
  //           'word': verbName,
  //           'v1': v1,
  //           'v2': v2,
  //           'v3': v3,
  //           'examples':
  //               examples.isNotEmpty ? examples : ['No examples available.'],
  //           'exercises': exercises,
  //         });
  //       }
  //     }

  //     return words.isNotEmpty ? words : _getFallbackWords();
  //   } catch (e) {
  //     print('Error parsing Gemini response: $e');
  //     return _getFallbackWords();
  //   }
  // }

  // List<Map<String, dynamic>> _getFallbackWords() {
  //   return [];
  // }

  // Future<List<Map<String, dynamic>>> generateExercises(
  //   List<Map<String, dynamic>> words,
  // ) async {
  //   // This is a placeholder. Replace with actual AI call.
  //   // Example structure for an exercise:
  //   // {
  //   //   "question": "What is the past participle (v3) of 'go'?",
  //   //   "answer": "gone",
  //   //   "exerciseType": "fill_in_the_blank" // or multiple_choice, etc.
  //   // }
  //   await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  //   List<Map<String, dynamic>> exercises = [];
  //   for (var wordData in words) {
  //     exercises.add({
  //       "question": "What is the past tense (v2) of '${wordData['word']}'?",
  //       "answer": wordData['v2'],
  //       "exerciseType": "fill_in_the_blank",
  //     });
  //     exercises.add({
  //       "question":
  //           "Provide an example sentence using the word '${wordData['word']}'.",
  //       "answer":
  //           wordData['example'], // This might need a more sophisticated check
  //       "exerciseType": "sentence_construction",
  //     });
  //   }
  //   return exercises;
  // }
}
