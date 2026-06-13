import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/ai_response_widget.dart';
import 'bank_manage_screen.dart';
import 'import_screen.dart';
import 'settings_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.refreshWeaknessAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('刷题宝',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await appState.init();
              await appState.refreshWeaknessAnalysis();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(appState),
                  const SizedBox(height: 24),
                  _buildWeaknessSection(appState),
                  const SizedBox(height: 24),
                  _buildQuickActions(appState),
                  const SizedBox(height: 24),
                  // 底部署名
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '本软件由b站：笨蛋鱼坏蛋猫 开发',
                      style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(AppState appState) {
    final stats = appState.homeStats;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: '累计刷题时长',
            value: stats?.formattedDuration ?? '0分钟',
            color: const Color(0xFF4A90D9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.quiz_outlined,
            label: '总刷题量',
            value: '${stats?.totalQuestions ?? 0} 题',
            color: const Color(0xFF5CB85C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            label: '平均正确率',
            value: stats?.formattedAccuracy ?? '0%',
            color: const Color(0xFFF0AD4E),
          ),
        ),
      ],
    );
  }

  Widget _buildWeaknessSection(AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('薄弱点分析',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('刷新', style: TextStyle(fontSize: 12)),
                onPressed: () => appState.refreshWeaknessAnalysis(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (appState.weaknessAnalysis == null)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ))
          else
            AiResponseWidget(
              text: appState.weaknessAnalysis!,
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('快速操作',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.play_arrow_rounded,
                label: '开始刷题',
                subtitle: appState.selectedBankIds.isEmpty
                    ? '请先选择题库'
                    : '已选${appState.selectedBankIds.length}个题库，${appState.selectedQuestionCount}题',
                color: const Color(0xFF4A90D9),
                onTap: appState.selectedBankIds.isEmpty
                    ? null
                    : () => _startQuiz(context, appState),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.library_add_outlined,
                label: '管理题库',
                subtitle: '${appState.banks.length} 个题库',
                color: const Color(0xFF5CB85C),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BankManageScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.replay_rounded,
          label: '错题重刷',
          subtitle: '错3次以上 + 收藏题目',
          color: const Color(0xFFD9534F),
          fullWidth: true,
          onTap: () => _startErrorReview(context, appState),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.upload_file,
          label: '导入题库',
          subtitle: '支持 DOC/DOCX 格式批量上传',
          color: const Color(0xFFF0AD4E),
          fullWidth: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ImportScreen()),
          ),
        ),
      ],
    );
  }

  Future<void> _startErrorReview(BuildContext context, AppState appState) async {
    if (!appState.settings.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中配置 API Key'), backgroundColor: Colors.orange),
      );
      return;
    }
    await appState.startErrorReview();
    if (appState.quizQuestions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无错题，继续刷题积累吧！')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
  }

  Future<void> _startQuiz(BuildContext context, AppState appState) async {
    if (!appState.settings.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('请先在设置中配置 DeepSeek API Key'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    await appState.startQuiz();

    if (appState.quizQuestions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所选题库中没有题目，请先导入题目')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool fullWidth;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF999999))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
