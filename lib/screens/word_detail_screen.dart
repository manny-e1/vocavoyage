import 'package:flutter/material.dart';
import 'package:vocavoyage/services/parser.dart';
import 'package:vocavoyage/services/tts_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class WordDetailScreen extends StatefulWidget {
  final IrregularVerb wordData;

  const WordDetailScreen({super.key, required this.wordData});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen>
    with TickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  bool _showDefinition = false;
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool> _answeredCorrectly = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();

    // Delayed animation for definition card
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showDefinition = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Widget _buildFormChip(String? form, String label) {
    if (form == null || form.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _ttsService.speak(form);
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.3),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        form,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                            Icons.volume_up_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          .animate(
                            onPlay:
                                (controller) =>
                                    controller.repeat(reverse: true),
                          )
                          .scaleXY(
                            begin: 1,
                            end: 1.2,
                            duration: 1.seconds,
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms, delay: 150.ms)
        .slideX(
          begin: 0.2,
          end: 0,
          duration: 250.ms,
          delay: 150.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildExercisesSection() {
    final exercises = widget.wordData.questions;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final question = exercise.question;
        final options = exercise.choices;
        final correctAnswer = exercise.correctAnswer;

        return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...options.map(
                      (option) =>
                          _buildOptionItem(option, index, correctAnswer),
                    ),

                    // Feedback when answered
                    if (_selectedAnswers.containsKey(index)) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _answeredCorrectly[index] == true
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _answeredCorrectly[index] == true
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _answeredCorrectly[index] == true
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color:
                                  _answeredCorrectly[index] == true
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _answeredCorrectly[index] == true
                                    ? 'Correct! Well done!'
                                    : 'Incorrect. The correct answer is: $correctAnswer',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color:
                                      _answeredCorrectly[index] == true
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms, delay: (300 + (index * 200)).ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 800.ms,
              delay: (300 + (index * 200)).ms,
              curve: Curves.easeOutQuad,
            );
      },
    );
  }

  Widget _buildOptionItem(
    String option,
    int exerciseIndex,
    String correctAnswer,
  ) {
    final isSelected = _selectedAnswers[exerciseIndex] == option;
    final hasAnswered = _selectedAnswers.containsKey(exerciseIndex);
    final isCorrectAnswer = option == correctAnswer;

    // Determine the background color based on selection state
    Color backgroundColor;
    Color borderColor;

    if (hasAnswered) {
      if (isSelected) {
        backgroundColor =
            isCorrectAnswer ? Colors.green.shade50 : Colors.red.shade50;
        borderColor =
            isCorrectAnswer ? Colors.green.shade300 : Colors.red.shade300;
      } else if (isCorrectAnswer) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
      } else {
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
      }
    } else {
      backgroundColor =
          isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey.shade50;
      borderColor =
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300;
    }

    return GestureDetector(
      onTap:
          hasAnswered
              ? null
              : () => _selectAnswer(exerciseIndex, option, correctAnswer),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                      isSelected || (hasAnswered && isCorrectAnswer)
                          ? FontWeight.w600
                          : FontWeight.normal,
                  color:
                      isSelected || (hasAnswered && isCorrectAnswer)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                ),
              ),
            ),
            if (hasAnswered && (isSelected || isCorrectAnswer))
              Icon(
                isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                color: isCorrectAnswer ? Colors.green : Colors.red,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(
    int exerciseIndex,
    String selectedOption,
    String correctAnswer,
  ) {
    setState(() {
      _selectedAnswers[exerciseIndex] = selectedOption;
      _answeredCorrectly[exerciseIndex] = selectedOption == correctAnswer;
    });
  }

  Widget _buildExampleItem(String example, int index) {
    return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          example,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        _ttsService.speak(example);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms, delay: (300 + (index * 200)).ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 800.ms,
          delay: (300 + (index * 200)).ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildWordHeader(String word) {
    return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Hero(
                tag: 'word_$word',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 32),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      _ttsService.speak(word);
                    },
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scaleXY(
                    begin: 1,
                    end: 1.2,
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 250.ms,
          curve: Curves.easeOutQuad,
        );
  }

  @override
  Widget build(BuildContext context) {
    final String word = widget.wordData.verb;
    final String v1 = widget.wordData.v1;
    final String v2 = widget.wordData.v2;
    final String v3 = widget.wordData.v3;

    // Handle examples data
    final examples = widget.wordData.examples;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: double.maxFinite,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildWordHeader(word),

                // Verb Forms Section
                if (v1.isNotEmpty || v2.isNotEmpty || v3.isNotEmpty) ...[
                  Text(
                        'Verb Forms',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 250.ms, delay: 150.ms)
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        duration: 250.ms,
                        delay: 150.ms,
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(height: 12),
                  Wrap(
                    children: <Widget>[
                      _buildFormChip(v1, 'V1'),
                      _buildFormChip(v2, 'V2'),
                      _buildFormChip(v3, 'V3'),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                // Examples Section
                Text(
                      'Examples',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 150.ms)
                    .slideX(
                      begin: 0.2,
                      end: 0,
                      duration: 250.ms,
                      delay: 150.ms,
                      curve: Curves.easeOutQuad,
                    ),
                const SizedBox(height: 12),

                // Examples List
                if (examples.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: examples.length,
                    itemBuilder: (context, index) {
                      return _buildExampleItem(examples[index], index);
                    },
                  )
                else
                  _buildExampleItem('No examples available.', 0),

                const SizedBox(height: 32),

                // Exercises Section
                if (widget.wordData.questions.isNotEmpty) ...[
                  Text(
                        'Exercises',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 250.ms, delay: 150.ms)
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        duration: 250.ms,
                        delay: 150.ms,
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(height: 12),
                  _buildExercisesSection(),
                ],

                const SizedBox(height: 32),

                // Additional Info Section
                if (_showDefinition)
                  Container(
                        margin: const EdgeInsets.only(top: 32),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.blue.shade100.withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pro Tip',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.wordData.explanation,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 250.ms, delay: 250.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 250.ms,
                        delay: 250.ms,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
