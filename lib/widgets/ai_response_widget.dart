import 'package:flutter/material.dart';

/// 将 AI 回复渲染为富文本（支持标题、粗体、列表、表格）
class AiResponseWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const AiResponseWidget({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.color = const Color(0xFF555555),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _parseBlocks(text),
    );
  }

  List<Widget> _parseBlocks(String text) {
    final widgets = <Widget>[];
    final allLines = text.split('\n');
    int i = 0;

    while (i < allLines.length) {
      final line = allLines[i].trim();

      if (line.isEmpty) {
        i++;
        continue;
      }

      // 标题
      if (line.startsWith('##')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            line.replaceFirst(RegExp(r'^#+\s*'), ''),
            style: TextStyle(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ));
        i++;
        continue;
      }

      // 粗体标题或序号
      if (line.startsWith('**') || RegExp(r'^\d+[\.、]').hasMatch(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: _buildRichLine(line),
        ));
        i++;
        continue;
      }

      // 短横列表
      if (line.startsWith('-') || line.startsWith('•')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 1, bottom: 1),
          child: _buildRichLine(line),
        ));
        i++;
        continue;
      }

      // 普通行
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: _buildRichLine(line),
      ));
      i++;
    }

    return widgets;
  }

  Widget _buildRichLine(String line) {
    final spans = <InlineSpan>[];
    final text = line.trim();

    final parts = text.split(RegExp(r'(\*\*[^*]+\*\*)'));
    for (final part in parts) {
      if (part.startsWith('**') && part.endsWith('**')) {
        spans.add(TextSpan(
          text: part.substring(2, part.length - 2),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ));
      } else {
        spans.add(TextSpan(text: part));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, color: color, height: 1.6),
        children: spans,
      ),
    );
  }
}
