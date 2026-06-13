import 'dart:math';
import '../models/question.dart';
import '../models/question_bank.dart';
import '../models/quiz_session.dart';
import '../models/answer_record.dart';
import 'database_service.dart';

class QuizService {
  final DatabaseService _db = DatabaseService.instance;

  // 当前会话状态
  QuizSession? _currentSession;
  List<Question> _questions = [];
  int _currentIndex = 0;

  QuizSession? get currentSession => _currentSession;
  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  Question? get currentQuestion =>
      _currentIndex < _questions.length && _currentIndex >= 0
          ? _questions[_currentIndex]
          : null;
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;
  bool get hasNext => _currentIndex < _questions.length - 1;

  /// 开始新的刷题会话
  Future<void> startQuiz({
    required List<int> bankIds,
    required String mode,
    required int questionCount,
    List<QuestionBank>? allBanks,
  }) async {
    // 从指定题库中随机抽取题目
    final allQuestions = await _db.getQuestionsByBanks(bankIds);

    if (allQuestions.isEmpty) {
      _questions = [];
    } else if (allQuestions.length <= questionCount) {
      _questions = allQuestions;
      _questions.shuffle();
    } else {
      _questions = allQuestions;
      _questions.shuffle(Random());
      _questions = _questions.take(questionCount).toList();
    }

    // 创建会话
    _currentSession = QuizSession(
      bankIds: bankIds.join(','),
      mode: mode,
      totalQuestions: _questions.length,
      startTime: DateTime.now().toIso8601String(),
    );

    _currentSession = QuizSession(
      id: await _db.insertSession(_currentSession!),
      bankIds: _currentSession!.bankIds,
      mode: _currentSession!.mode,
      totalQuestions: _currentSession!.totalQuestions,
      startTime: _currentSession!.startTime,
    );

    _currentIndex = 0;
  }

  /// 提交答案
  Future<AnswerRecord> submitAnswer(String userAnswer) async {
    final question = currentQuestion;
    if (question == null || _currentSession == null) {
      throw StateError('没有活跃的刷题会话');
    }

    final correctAnswer = question.correctAnswer.toUpperCase().trim();
    final normalizedUser = userAnswer.toUpperCase().trim();
    final isCorrect = normalizedUser == correctAnswer;

    final record = AnswerRecord(
      questionId: question.id!,
      sessionId: _currentSession!.id,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      answeredAt: DateTime.now().toIso8601String(),
    );

    final recordId = await _db.insertAnswerRecord(record);

    // 更新会话统计
    if (isCorrect) {
      _currentSession = QuizSession(
        id: _currentSession!.id,
        bankIds: _currentSession!.bankIds,
        mode: _currentSession!.mode,
        totalQuestions: _currentSession!.totalQuestions,
        correctCount: _currentSession!.correctCount + 1,
        wrongCount: _currentSession!.wrongCount,
        startTime: _currentSession!.startTime,
        endTime: _currentSession!.endTime,
        durationSeconds: _currentSession!.durationSeconds,
      );
    } else {
      _currentSession = QuizSession(
        id: _currentSession!.id,
        bankIds: _currentSession!.bankIds,
        mode: _currentSession!.mode,
        totalQuestions: _currentSession!.totalQuestions,
        correctCount: _currentSession!.correctCount,
        wrongCount: _currentSession!.wrongCount + 1,
        startTime: _currentSession!.startTime,
        endTime: _currentSession!.endTime,
        durationSeconds: _currentSession!.durationSeconds,
      );
    }

    return AnswerRecord(
      id: recordId,
      questionId: record.questionId,
      sessionId: record.sessionId,
      userAnswer: record.userAnswer,
      isCorrect: record.isCorrect,
      aiAnalysis: record.aiAnalysis,
      answeredAt: record.answeredAt,
    );
  }

  /// 移动到下一题
  bool nextQuestion() {
    if (hasNext) {
      _currentIndex++;
      return true;
    }
    return false;
  }

  /// 结束当前会话
  Future<QuizSession> endSession() async {
    if (_currentSession == null) {
      throw StateError('没有活跃的刷题会话');
    }

    final endTime = DateTime.now();
    final startTime = DateTime.parse(_currentSession!.startTime);
    final durationSeconds = endTime.difference(startTime).inSeconds;

    _currentSession = QuizSession(
      id: _currentSession!.id,
      bankIds: _currentSession!.bankIds,
      mode: _currentSession!.mode,
      totalQuestions: _currentSession!.totalQuestions,
      correctCount: _currentSession!.correctCount,
      wrongCount: _currentSession!.wrongCount,
      startTime: _currentSession!.startTime,
      endTime: endTime.toIso8601String(),
      durationSeconds: durationSeconds,
    );

    await _db.updateSession(_currentSession!);
    return _currentSession!;
  }

  /// 获取单题统计
  Future<Map<String, int>> getQuestionStats(int questionId) async {
    return await _db.getQuestionStats(questionId);
  }

  /// 重置会话
  void reset() {
    _currentSession = null;
    _questions = [];
    _currentIndex = 0;
  }
}
