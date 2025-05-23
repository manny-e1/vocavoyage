import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:vocavoyage/services/parser.dart';
import 'package:vocavoyage/services/word_service.dart';
import 'package:vocavoyage/services/tts_service.dart';
import 'word_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Define a gradient for the AppBar
  final LinearGradient _appBarGradient = const LinearGradient(
    colors: [Color.fromARGB(255, 121, 78, 200), Color(0xFF8F94FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final WordService _wordService = WordService();
  final TtsService _ttsService = TtsService();
  List<IrregularVerb> _dailyWords = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchDailyWords();
  }

  Future<void> _fetchDailyWords() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final words = await _wordService.getDailyWords();
      setState(() {
        _dailyWords = words;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print("Error fetching daily words: $e");
      setState(() {
        _isLoading = false;
        // Optionally, show an error message to the user
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: _appBarGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        title: const Text(
          'Voca Voyage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _animationController.reset();
              _fetchDailyWords();
            },
            tooltip: 'Refresh Words',
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withBlue(
                Theme.of(context).colorScheme.surface.blue + 15,
              ),
            ],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dailyWords.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No words available',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _animationController.reset();
                          _fetchDailyWords();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.only(top: 100, bottom: 20),
                  itemCount: _dailyWords.length,
                  itemBuilder: (context, index) {
                    final wordData = _dailyWords[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              delay > 0.9 ? 0.9 : delay,
                              (delay > 0.9 ? 0.9 : delay) + 0.1,
                              curve: Curves.easeOutQuart,
                            ),
                          ),
                        );

                        return SlideTransition(
                          position: slideAnimation,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Card(
                          elevation: 8,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          WordDetailScreen(wordData: wordData),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        wordData.verb,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.volume_up,
                                            color:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                          ),
                                          onPressed: () {
                                            _ttsService.speak(wordData.verb);
                                          },
                                          tooltip: 'Pronounce Word',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (wordData.v1.isNotEmpty ||
                                      wordData.v2.isNotEmpty ||
                                      wordData.v3.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          if (wordData.v1.isNotEmpty)
                                            _buildVerbForm(
                                              'V1',
                                              wordData.v1,
                                              context,
                                            ),
                                          if (wordData.v2.isNotEmpty)
                                            _buildVerbForm(
                                              'V2',
                                              wordData.v2,
                                              context,
                                            ),
                                          if (wordData.v3.isNotEmpty)
                                            _buildVerbForm(
                                              'V3',
                                              wordData.v3,
                                              context,
                                            ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EXAMPLE',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ...wordData.examples.map(
                                          (e) => SentenceDisplay(
                                            sentence:
                                                '${wordData.examples.indexOf(e) + 1}. ${e.split(":")[1].trim()}',
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                      ),
                                      label: Text(
                                        'Details',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => WordDetailScreen(
                                                  wordData: wordData,
                                                ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildVerbForm(String label, String value, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SentenceDisplay extends StatelessWidget {
  final String sentence;
  final TextStyle textStyle;
  final double padding;
  const SentenceDisplay({
    super.key,
    required this.sentence,
    required this.textStyle,
    this.padding = 8,
  });

  List<TextSpan> _parseSentence(String text, BuildContext context) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (var match in exp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: textStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: textStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: RichText(
        text: TextSpan(children: _parseSentence(sentence, context)),
      ),
    );
  }
}
