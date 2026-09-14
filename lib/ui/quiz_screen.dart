import 'package:flutter/material.dart';
import '../models/question.dart';
import '../core/content_manager.dart';
import '../core/storage_service.dart';
import '../core/window_service.dart';

class QuizScreen extends StatefulWidget {
  final Question question;
  final bool fullScreenLock;
  const QuizScreen({super.key, required this.question, this.fullScreenLock = true});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final WindowService _windowService = WindowService();
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
      _feedbackMessage = _isCorrect ? '¡Correcto! Excelente trabajo.' : 'Incorrecto. Sigue intentando.';
    });

    ContentManager().recordAnswer(widget.question.id, _isCorrect);
    StorageService().saveProgressMap(ContentManager().progressMap);

    if (_isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        _exitKioskMode();
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      // If incorrect, allow trying again after a short delay
      Future.delayed(const Duration(seconds: 2), () {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💡 Pista: ${widget.question.hint}', style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF374151)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.question.question,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ...List.generate(widget.question.options.length, (index) {
                bool isSelected = _selectedIndex == index;
                Color btnColor = const Color(0xFF374151);
                Color borderColor = const Color(0xFF4B5563);
                
                if (_answered && isSelected) {
                  btnColor = _isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                  borderColor = _isCorrect ? const Color(0xFF059669) : const Color(0xFFDC2626);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _answered ? null : () => _checkAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        elevation: isSelected ? 0 : 4,
                      ),
                      child: Text(
                        widget.question.options[index],
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _showHint,
                icon: const Icon(Icons.lightbulb, color: Colors.amber),
                label: const Text('Necesito una pista', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
              if (_feedbackMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
