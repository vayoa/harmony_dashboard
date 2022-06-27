
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmony_theory/tests/parsing_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmony Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const MyHomePage(title: 'Harmony Dashboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ParsingTestResult? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chord Parsing Test',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 8),
            TextField(
              maxLines: 1,
              decoration: const InputDecoration(
                isDense: true,
                constraints: BoxConstraints(maxWidth: 600),
                hintText: 'Type a chord here...',
                labelText: 'Try Parsing: ',
              ),
              onChanged: (input) => setState(() =>
                  result = input.isEmpty ? null : ParsingTest.test(input)),
            ),
            if (result != null) ...[
              const SizedBox(height: 20.0),
              SelectableText.rich(
                TextSpan(children: _buildSpan()),
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildSpan() {
    if (result!.error != null) {
      return [
        _boldSpan('Error!\n'),
        TextSpan(text: '${result!.error}.'),
      ];
    }
    ParsingTestResultSpec spec = result!.spec!;
    return [
      ..._group('Found Type', spec.type),
      ..._group('Root', spec.root),
      ..._group(
        'Bass',
        spec.bass + (spec.root == spec.bass ? ' (same as root)' : ''),
      ),
      ..._group('Pattern', spec.pattern),
      ..._group('\nDisplayed As', '', suffix: ''),
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

  TextSpan _boldSpan(String text) =>
      TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.bold));

  List<TextSpan> _group(String header, String text, {String suffix = '.\n'}) =>
      [
        _boldSpan('$header: '),
        TextSpan(text: text),
        TextSpan(text: suffix),
      ];
}
