import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmony_dashboard/widgets/parser_widgets.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/tests/parsing_test.dart';
import 'package:tonic/tonic.dart';

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
  String parsingInput = '';
  PitchScale? scale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Flexible(
              flex: 7,
              child: Section(
                title: 'Chord Parsing Test',
                hintText: 'Type a chord here...',
                labelText: 'Try Parsing: ',
                suffixIcon: const Icon(Icons.forward_rounded),
                onChanged: (input) => setState(() => _handleInput(input)),
                children: result == null
                    ? const []
                    : [
                        const SizedBox(height: 20.0),
                        (result!.error != null
                            ? ParseError(exception: result!.error!)
                            : ParseInfo(spec: result!.originalSpec!)),
                      ],
              ),
            ),
            const Spacer(),
            Flexible(
              flex: 7,
              child: Section(
                title: 'Conversion Test',
                hintText: (result == null || result!.convertedScale == null)
                    ? 'Type a scale here...'
                    : result!.convertedScale!,
                labelText: 'Try Scale: ',
                suffixIcon:
                    scale == null ? null : const Icon(Icons.check_rounded),
                onChanged: (input) => setState(() {
                  scale = _parse(input);
                  _handleInput(parsingInput);
                }),
                children: result == null
                    ? const []
                    : [
                        const SizedBox(height: 20.0),
                        if (result!.error == null)
                          ParseInfo(spec: result!.convertedSpec!),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleInput(String input) {
    parsingInput = input;
    result = parsingInput.isEmpty
        ? null
        : ParsingTest.test(parsingInput, scale: scale);
  }

  static final RegExp _scaleRegex =
      RegExp(r"([a-gA-G],*'*[#b♯♭𝄪𝄫]*)[\W]*(minor|major|m)", caseSensitive: false);

  PitchScale? _parse(String input) {
    final match = _scaleRegex.matchAsPrefix(input);
    if (match == null) return null;
    try {
      return PitchScale.common(
          tonic: Pitch.parse(match[1]!),
          minor: match[2] != null &&
              (match[2] == 'm' ||
                  match[2]!.contains(RegExp('minor', caseSensitive: false))));
    } catch (_) {
      return null;
    }
  }
}

class Section extends StatelessWidget {
  const Section({
    Key? key,
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.children,
    required this.onChanged,
    this.suffixIcon,
  }) : super(key: key);

  final String title;
  final String hintText;
  final String labelText;
  final List<Widget> children;
  final void Function(String) onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headline5),
        const SizedBox(height: 8),
        TextField(
          maxLines: 1,
          decoration: InputDecoration(
            isDense: true,
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 600,
            ),
            hintText: hintText,
            labelText: labelText,
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
        ),
        ...children,
      ],
    );
  }
}
