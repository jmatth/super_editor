import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/src/infrastructure/attributed_text_styles.dart';

void main() {
  group('Attributed Text', () {
    test('no styles', () {
      final text = AttributedText(
        text: 'abcdefghij',
      );
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, 'abcdefghij');
      expect(textSpan.children, null);
    });

    test('full-span style', () {
      final text = AttributedText(
        text: 'abcdefghij',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 0, end: 10),
          ],
        ),
      );
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, 'abcdefghij');
      expect(textSpan.style!.fontWeight, FontWeight.bold);
      expect(textSpan.children, null);
    });

    test('single character style', () {
      final text = AttributedText(
        text: 'abcdefghij',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 1, end: 2),
          ],
        ),
      );
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'a');
      expect(textSpan.children![1].toPlainText(), 'b');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'cdefghij');
      expect(textSpan.children![2].style!.fontWeight, null);
    });

    test('add single character style', () {
      final text = AttributedText(text: 'abcdefghij');
      text.addAttribution(ExpectedSpans.bold, const SpanRange(start: 1, end: 2));
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'a');
      expect(textSpan.children![1].toPlainText(), 'b');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'cdefghij');
      expect(textSpan.children![2].style!.fontWeight, null);
    });

    test('partial style', () {
      final text = AttributedText(
        text: 'abcdefghij',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 2, end: 8),
          ],
        ),
      );
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'ab');
      expect(textSpan.children![1].toPlainText(), 'cdefgh');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'ij');
    });

    test('add styled character to existing styled text', () {
      final initialText = AttributedText(
        text: 'abcdefghij',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 9, end: 10),
          ],
        ),
      );

      final newText = initialText.copyAndAppend(AttributedText(
        text: 'k',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 0, end: 1),
          ],
        ),
      ));

      final textSpan = newText.computeTextSpan(_styleBuilder);

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 2);
      expect(textSpan.children![0].toPlainText(), 'abcdefghi');

      // Ensures that typing a styled character at the end of text
      // results in a single expanded span, rather than 2 independent
      // spans with the same style.
      expect(textSpan.children![1].toPlainText(), 'jk');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![1].style!.fontStyle, null);
    });

    test('non-mingled varying styles', () {
      final text = AttributedText(
        text: 'abcdefghij',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 0, end: 5),
            const AttributionSpan(attribution: ExpectedSpans.italics, start: 5, end: 10),
          ],
        ),
      );
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 2);
      expect(textSpan.children![0].toPlainText(), 'abcde');
      expect(textSpan.children![0].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![0].style!.fontStyle, null);
      expect(textSpan.children![1].toPlainText(), 'fghij');
      expect(textSpan.children![1].style!.fontWeight, null);
      expect(textSpan.children![1].style!.fontStyle, FontStyle.italic);
    });

    test('intermingled varying styles', () {
      final text = AttributedText(
        text: 'abcdefghij',
        spans: AttributedSpans(
          attributions: [
            const AttributionSpan(attribution: ExpectedSpans.bold, start: 2, end: 6),
            const AttributionSpan(attribution: ExpectedSpans.italics, start: 4, end: 8),
          ],
        ),
      );
      final textSpan = text.computeTextSpan(_styleBuilder);

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 5);
      expect(textSpan.children![0].toPlainText(), 'ab');
      expect(textSpan.children![0].style!.fontWeight, null);
      expect(textSpan.children![0].style!.fontStyle, null);

      expect(textSpan.children![1].toPlainText(), 'cd');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![1].style!.fontStyle, null);

      expect(textSpan.children![2].toPlainText(), 'ef');
      expect(textSpan.children![2].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].style!.fontStyle, FontStyle.italic);

      expect(textSpan.children![3].toPlainText(), 'gh');
      expect(textSpan.children![3].style!.fontWeight, null);
      expect(textSpan.children![3].style!.fontStyle, FontStyle.italic);

      expect(textSpan.children![4].toPlainText(), 'ij');
      expect(textSpan.children![4].style!.fontWeight, null);
      expect(textSpan.children![4].style!.fontStyle, null);
    });
  });
}

/// Creates styles based on the given `attributions`.
TextStyle _styleBuilder(Set<Attribution> attributions) {
  TextStyle newStyle = const TextStyle();
  for (final attribution in attributions) {
    if (attribution == ExpectedSpans.bold) {
      newStyle = newStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
    } else if (attribution == ExpectedSpans.italics) {
      newStyle = newStyle.copyWith(
        fontStyle: FontStyle.italic,
      );
    } else if (attribution == ExpectedSpans.strikethrough) {
      newStyle = newStyle.copyWith(
        decoration: TextDecoration.lineThrough,
      );
    }
  }
  return newStyle;
}
