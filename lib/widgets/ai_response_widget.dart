import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// AI 回复渲染器：透传文本 → 零宽空格转义 → Markdown 解析 → 富文本
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
    return MarkdownBody(
      data: _sanitize(text),
      selectable: false,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: fontSize, color: color, height: 1.6),
        h1: TextStyle(fontSize: fontSize + 6, fontWeight: FontWeight.bold, color: color),
        h2: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold, color: color),
        h3: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: color),
        strong: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color),
        code: TextStyle(fontSize: fontSize - 1, color: color),
        listBullet: TextStyle(fontSize: fontSize, color: color),
        tableBody: TextStyle(fontSize: fontSize - 1, color: color),
        tableHead: TextStyle(fontSize: fontSize - 1, fontWeight: FontWeight.bold, color: color),
        tableBorder: TableBorder.all(color: color.withOpacity(0.2)),
      ),
    );
  }

  String _sanitize(String raw) {
    return raw
        .replaceAll('\u200B', '')
        .replaceAll('\u200C', '')
        .replaceAll('\u200D', '');
  }
}
