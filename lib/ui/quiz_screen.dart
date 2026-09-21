import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../core/content_manager.dart';
import '../core/storage_service.dart';
import '../core/window_service.dart';

class QuizScreen extends StatefulWidget {
  final Question question;
  final bool fullScreenLock;

  const QuizScreen({
    super.key,
    required this.question,
    this.fullScreenLock = true,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final WindowService _windowService = WindowService();
  final FocusNode _focusNode = FocusNode();
  int? _selectedIndex;
  bool _answered = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.fullScreenLock) {
      _enterKioskMode();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.fullScreenLock) {
      _windowService.exitOverlayMode();
    }
    super.dispose();
  }

  Future<void> _enterKioskMode() async {
    await _windowService.enterOverlayMode();
  }

  Future<void> _exitKioskMode() async {
    if (widget.fullScreenLock) {
      await _windowService.exitOverlayMode();
    }
  }

  void _checkAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = (index == widget.question.correctIndex);
      _feedbackMessage = _isCorrect
          ? '¡Correcto! Excelente retención.'
          : 'Incorrecto. Revisa el concepto e inténtalo de nuevo.';
    });

    ContentManager().recordAnswer(widget.question.id, _isCorrect);
    StorageService().saveProgressMap(ContentManager().progressMap);

    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        _exitKioskMode();
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() {
            _answered = false;
            _selectedIndex = null;
            _feedbackMessage = '';
          });
        }
      });
    }
  }

  void _showHint() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161920),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262C38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: Color(0xFFFBBF24), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pista Conceptual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.question.hint,
                style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFD1D5DB)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF374151)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.keyH) {
      _showHint();
      return KeyEventResult.handled;
    }

    final key = event.logicalKey;
    if (!_answered) {
      if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
        if (widget.question.options.isNotEmpty) _checkAnswer(0);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
        if (widget.question.options.length > 1) _checkAnswer(1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
        if (widget.question.options.length > 2) _checkAnswer(2);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
        if (widget.question.options.length > 3) _checkAnswer(3);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final subtopicClean = widget.question.subtopic.replaceAll('_', ' ').toUpperCase();
    final diffClean = widget.question.difficulty.toUpperCase();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0D11),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  color: const Color(0xFF13161C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF222733), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Context Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1F29),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2A3140)),
                          ),
                          child: Text(
                            '$subtopicClean • $diffClean',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showHint,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2430),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2E3646)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFFFBBF24)),
                                SizedBox(width: 5),
                                Text(
                                  'Pista [H]',
                                  style: TextStyle(
                                    color: Color(0xFFE5E7EB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Question Text
                    Text(
                      widget.question.question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF3F4F6),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 28),

                    // Options List
                    ...List.generate(widget.question.options.length, (index) {
                      final bool isSelected = _selectedIndex == index;
                      Color cardBg = const Color(0xFF191D26);
                      Color borderColor = const Color(0xFF29303F);
                      Color textColor = const Color(0xFFE5E7EB);
                      Color badgeBg = const Color(0xFF222836);
                      Color badgeText = const Color(0xFF9CA3AF);

                      if (_answered) {
                        if (index == widget.question.correctIndex) {
                          cardBg = const Color(0xFF063F2D);
                          borderColor = const Color(0xFF10B981);
                          textColor = Colors.white;
                          badgeBg = const Color(0xFF10B981);
                          badgeText = Colors.black;
                        } else if (isSelected) {
                          cardBg = const Color(0xFF451A1A);
                          borderColor = const Color(0xFFEF4444);
                          textColor = Colors.white;
                          badgeBg = const Color(0xFFEF4444);
                          badgeText = Colors.white;
                        } else {
                          cardBg = const Color(0xFF11141A);
                          borderColor = const Color(0xFF1E222A);
                          textColor = const Color(0xFF6B7280);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: 1.2),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _answered ? null : () => _checkAnswer(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: badgeText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        widget.question.options[index],
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          height: 1.35,
                                          color: textColor,
                                          fontWeight: FontWeight.w400,
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
                    }),

                    if (_feedbackMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isCorrect ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _feedbackMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
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
            ),
          ),
        ),
      ),
    );
  }
}
