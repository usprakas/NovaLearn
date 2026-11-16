import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A subject's mark at a given size and color: the script's first letter for a language subject
/// ("अ" for Hindi, "అ" for Telugu), otherwise the subject's icon. One widget so every place that
/// shows a subject (lesson rows, early-learner tiles, filter chips) renders it the same way.
class SubjectMark extends StatelessWidget {
  const SubjectMark({super.key, required this.subject, required this.color, required this.size});
  final String subject;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String? glyph = AppTheme.subjectGlyph(subject);
    if (glyph == null) {
      return Icon(AppTheme.subjectIcon(subject), color: color, size: size);
    }
    return ExcludeSemantics(
        child: Text(glyph,
            textAlign: TextAlign.center,
            textHeightBehavior:
                const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
            style: TextStyle(
                fontFamily: 'Baloo2',
                fontFamilyFallback: AppTheme.scriptFallback,
                fontSize: size * 1.05,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: color)));
  }
}
