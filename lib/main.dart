import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmony_dashboard/widgets/parser_widgets.dart';
import 'package:harmony_dashboard/widgets/section.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/tests/parsing_test.dart';
import 'package:harmony_theory/tests/progression_parsing_test.dart';
import 'package:tonic/tonic.dart';

void main() {
  runApp(const MyApp());
}

const String databaseID = r"73162819dd27463591aadf676443733f";

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
  ProgressionParsingTestResult? progressionResult;
  String progressionParsingInput = '';
  bool hardAnalysis = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    flex: 7,
                    child: Section(
                      title: 'Chord Parsing Test',
                      resultString: result == null
                          ? ''
                          : (result!.error == null
                              ? _resultFromSpec(result!.originalSpec)
                              : result!.error!.toString()),
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
                      inputString: result == null || result!.error != null
                          ? ''
                          : '"$parsingInput" converted in "${scale ?? PitchScale.cMajor}"',
                      resultString: _resultFromSpec(result?.convertedSpec),
                      hintText:
                          (result == null || result!.convertedScale == null)
                              ? 'Type a scale here...'
                              : result!.convertedScale!,
                      labelText: 'Try Scale: ',
                      suffixIcon: scale == null
                          ? null
                          : const Icon(Icons.check_rounded),
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
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    flex: 7,
                    child: Section(
                      title: 'SDProgression Parsing Test',
                      resultString: progressionResult == null
                          ? ''
                          : (progressionResult!.error == null
                              ? progressionResult!.result!
                              : progressionResult!.error!.toString()),
                      hintText: 'Type a chord here...',
                      labelText: 'Try Parsing: ',
                      suffixIcon: const Icon(Icons.forward_rounded),
                      onChanged: (input) =>
                          setState(() => _handleProgressionInput(input)),
                      children: progressionResult == null
                          ? const []
                          : [
                              const SizedBox(height: 20.0),
                              (progressionResult!.error != null
                                  ? ParseError(
                                      exception: progressionResult!.error!)
                                  : ProgressionParseInfo(
                                      result: progressionResult!.result!)),
                            ],
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    flex: 7,
                    child: Section(
                      title: 'Analyzer Test',
                      useCheckbox: true,
                      inputString: progressionResult == null ||
                              progressionResult!.error != null
                          ? ''
                          : '"${progressionResult!.result!}" analyzed (${hardAnalysis ? '' : 'not '}"hard")"',
                      resultString: progressionResult == null
                          ? ''
                          : (progressionResult!.error == null
                              ? progressionResult!.analyzedResult!
                              : progressionResult!.error!.toString()),
                      labelText: 'Hard Analysis',
                      onChanged: (val) => setState(() =>
                          _handleProgressionInput(
                              progressionParsingInput, val)),
                      hintText: '',
                      children: progressionResult == null
                          ? const []
                          : [
                              const SizedBox(height: 20.0),
                              if (progressionResult!.error == null)
                                ProgressionParseInfo(
                                  result: progressionResult!.analyzedResult!,
                                ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleProgressionInput(String input, [bool? hard]) {
    progressionParsingInput = input;
    if (hard != null) hardAnalysis = hard;
    progressionResult = ProgressionParsingTest.test(progressionParsingInput,
        hard: hardAnalysis);
  }

  String _resultFromSpec(ParsingTestResultSpec? spec) =>
      spec == null ? '' : '-- ${spec.object} --\n$spec';

  _handleInput(String input) {
    parsingInput = input;
    result = parsingInput.isEmpty
        ? null
        : ParsingTest.test(parsingInput, scale: scale);
  }

  static final RegExp _scaleRegex = RegExp(
      r"([a-gA-G],*'*[#b♯♭𝄪𝄫]*)[\W]*(minor|major|m)",
      caseSensitive: false);

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
