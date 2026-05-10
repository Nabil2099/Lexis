import 'package:flutter_test/flutter_test.dart';
import 'package:lexis/core/utils/markdown_utils.dart';

void main() {
  test('toPlainText strips common markdown markers', () {
    expect(
      MarkdownUtils.toPlainText(
          '# Title\nA **private** [vault](https://example.com).'),
      'Title A private vault.',
    );
  });

  test('wordCount counts plain text words', () {
    expect(MarkdownUtils.wordCount('## Hello **offline** vault'), 3);
  });
}
