import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/question_bank.dart';
import 'import_screen.dart';

class BankManageScreen extends StatefulWidget {
  const BankManageScreen({super.key});

  @override
  State<BankManageScreen> createState() => _BankManageScreenState();
}

class _BankManageScreenState extends State<BankManageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('题库管理'),
        elevation: 0,
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImportScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.banks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('还没有题库',
                      style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('导入题库'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ImportScreen()),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 刷题设置区域
              _buildQuizSettings(appState),
              const Divider(height: 1),

              // 题库列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.banks.length,
                  itemBuilder: (context, index) {
                    final bank = appState.banks[index];
                    final isSelected =
                        appState.selectedBankIds.contains(bank.id);
                    return _BankCard(
                      bank: bank,
                      isSelected: isSelected,
                      onTap: () => appState.toggleBankSelection(bank.id!),
                      onDelete: () => _confirmDelete(context, appState, bank),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuizSettings(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18, color: Color(0xFF4A90D9)),
              const SizedBox(width: 6),
              const Text('刷题设置',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Text(
                appState.selectedBankIds.isEmpty
                    ? '点击题目前方选择框'
                    : '已选 ${appState.selectedBankIds.length} 个题库',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 刷题模式
          Row(
            children: [
              const Text('刷题模式: ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: appState.selectedBankIds.length > 1
                      ? const Color(0xFFF0AD4E).withOpacity(0.1)
                      : const Color(0xFF4A90D9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  appState.selectedBankIds.length > 1 ? '混合刷题' : '单题库刷题',
                  style: TextStyle(
                    fontSize: 13,
                    color: appState.selectedBankIds.length > 1
                        ? const Color(0xFFF0AD4E)
                        : const Color(0xFF4A90D9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 题量选择（50题一档）
          const Text('每轮题量: ',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [50, 100, 150, 200, 250, 300].map((count) {
              final isSelected = appState.selectedQuestionCount == count;
              return GestureDetector(
                onTap: () => appState.setSelectedQuestionCount(count),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF4A90D9) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A90D9)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    '$count 题',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : const Color(0xFF666666),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppState appState, QuestionBank bank) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除题库"${bank.name}"吗？\n该题库下的所有题目也将被删除，此操作不可恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          TextButton(
            onPressed: () {
              appState.deleteBank(bank.id!);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final QuestionBank bank;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BankCard({
    required this.bank,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90D9)
                : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            // 选择框
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4A90D9)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4A90D9)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bank.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${bank.questionCount} 道题目',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF999999))),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.grey[400], size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
