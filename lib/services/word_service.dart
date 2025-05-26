import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocavoyage/services/parser.dart';
import 'dart:convert';
import 'ai_service.dart';

class WordService {
  static const String _dailyWordsKey = 'daily_words_cache';
  static const String _lastFetchDateKey = 'last_fetch_date';
  static const String _seenWordsKey = 'seen_words_cache';

  Future<List<IrregularVerb>> getDailyWords() async {
    // await clearCache();
    final cachedWords = await _getCachedWords();
    if (cachedWords.isNotEmpty) {
      return cachedWords;
    }

    final seenWords = await _getSeenWords();
    final aiService = AIService();
    final wordsData = await aiService.getDailyWords(seenWords: seenWords);

    await _cacheWords(wordsData);

    await _addWordsToSeenCache(wordsData.map((w) => w.verb).toList());

    return wordsData;
  }

  Future<List<IrregularVerb>> _getCachedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final lastFetchDate = prefs.getString(_lastFetchDateKey);
    final cachedWordsJson = prefs.getString(_dailyWordsKey);

    if (lastFetchDate == today && cachedWordsJson != null) {
      final List<dynamic> cachedList = jsonDecode(cachedWordsJson);
      List<IrregularVerb> ll = [];
      try {
        for (var i = 0; i < cachedList.length; i++) {
          ll.add(IrregularVerb.fromMap(jsonDecode(cachedList[i])));
        }
        return ll;
      } catch (e) {
        throw Exception("i dont know what's happening: $e");
      }
    }
    return [];
  }

  Future<void> _cacheWords(List<IrregularVerb> words) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await prefs.setString(_dailyWordsKey, jsonEncode(words));
    await prefs.setString(_lastFetchDateKey, today);
  }

  Future<void> _addWordsToSeenCache(List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> seenWords = await _getSeenWords();
    seenWords.addAll(words);
    if (seenWords.length > 1000) {
      seenWords = seenWords.sublist(seenWords.length - 1000);
    }
    await prefs.setStringList(_seenWordsKey, seenWords.toSet().toList());
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<List<String>> _getSeenWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_seenWordsKey) ?? [];
  }
}
