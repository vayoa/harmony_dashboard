import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmony_theory/tests/parsing_test.dart';

class ParserWidget extends StatelessWidget {
  const ParserWidget({Key? key}) : super(key: key);

  List<InlineSpan> children(BuildContext context) => [];

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        children: children(context),
      ),
      style: const TextStyle(fontSize: 16.0),
    );
  }

  static TextSpan boldSpan(String text) =>
      TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.bold));

  static List<TextSpan> group(String header, String text,
          {String suffix = '.\n'}) =>
      [
        boldSpan('$header: '),
        TextSpan(text: text),
        TextSpan(text: suffix),
      ];
}

class ParseError extends ParserWidget {
  const ParseError({
    Key? key,
    required this.exception,
  }) : super(key: key);

  final Exception exception;

  @override
  List<InlineSpan> children(BuildContext context) => [
        ParserWidget.boldSpan('Error!\n'),
        TextSpan(text: '$exception.'),
      ];
}

class ParseInfo extends ParserWidget {
  const ParseInfo({
    Key? key,
    required this.spec,
  }) : super(key: key);

  final ParsingTestResultSpec spec;

  @override
  List<InlineSpan> children(BuildContext context) => [
        ...ParserWidget.group('Found Type', spec.type),
        ...ParserWidget.group('Root', spec.root),
        ...ParserWidget.group(
          'Bass',
          spec.bass + (spec.root == spec.bass ? ' (same as root)' : ''),
        ),
        ...ParserWidget.group('Pattern', spec.pattern),
        ...ParserWidget.group('\nDisplayed As', '', suffix: ''),
        TextSpan(
          text: '${spec.object}.',
          style: GoogleFonts.roboto(
            color: Theme.of(context).primaryColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
}

class ProgressionParseInfo extends ParserWidget {
  const ProgressionParseInfo({
    Key? key,
    required this.result,
  }) : super(key: key);

  final String result;

  @override
  List<InlineSpan> children(BuildContext context) => [
        ParserWidget.boldSpan('Result: '),
        TextSpan(
          text: '$result.',
          style: GoogleFonts.roboto(
            color: Theme.of(context).primaryColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
}
