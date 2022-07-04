import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmony_dashboard/widgets/parser_widgets.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/tests/parsing_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
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

class Section extends StatefulWidget {
  const Section({
    Key? key,
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.children,
    required this.onChanged,
    required this.resultString,
    this.inputString,
    this.suffixIcon,
  }) : super(key: key);

  final String title;
  final String hintText;
  final String labelText;
  final List<Widget> children;
  final void Function(String) onChanged;
  final Widget? suffixIcon;
  final String resultString;
  final String? inputString;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.title,
            children: [
              WidgetSpan(
                child: IconButton(
                  icon: const Icon(Icons.bug_report_rounded),
                  iconSize: 20.0,
                  splashRadius: 18.0,
                  onPressed: () async {
                    final ReportResult? result =
                        await _pushReportDialog(context);
                    if (result != null) {
                      if (result == ReportResult.success) {
                        _controller.text = '';
                        widget.onChanged('');
                      }
                      ScaffoldMessenger.of(context).clearSnackBars();
                      final color = result.color;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          padding: const EdgeInsets.all(4.0),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            textColor: color,
                            onPressed: () {},
                          ),
                          content: ListTile(
                            iconColor: color,
                            textColor: color,
                            minLeadingWidth: 5.0,
                            leading: Icon(result.icon),
                            title: Text(result.message),
                          ),
                        ),
                      );
                    }
                  },
                ),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              )
            ],
          ),
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 1,
          decoration: InputDecoration(
            isDense: true,
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 600,
            ),
            hintText: widget.hintText,
            labelText: widget.labelText,
            suffixIcon: widget.suffixIcon,
          ),
          onChanged: widget.onChanged,
        ),
        ...widget.children,
      ],
    );
  }

  Future<ReportResult?> _pushReportDialog(BuildContext context) =>
      showGeneralDialog<ReportResult>(
        context: context,
        barrierDismissible: true,
        barrierLabel: '${widget.title} bug report',
        pageBuilder: (context, _, __) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 600,
                maxWidth: 700,
                minHeight: 200,
                maxHeight: 600,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          '${widget.title} Bug Report',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Expanded(
                        child: _SectionReportForm(
                          testName: widget.title,
                          input: widget.inputString ?? _controller.text,
                          result: widget.resultString,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _SectionReportForm extends StatefulWidget {
  const _SectionReportForm({
    Key? key,
    required this.testName,
    required this.input,
    required this.result,
  }) : super(key: key);

  final String testName;
  final String input;
  final String result;

  @override
  State<_SectionReportForm> createState() => _SectionReportFormState();
}

class _SectionReportFormState extends State<_SectionReportForm> {
  final _formKey = GlobalKey<FormState>();
  bool _expectedRTL = false, _detailsRTL = false;
  late final TextEditingController input, result, expected, details;

  @override
  void initState() {
    input = TextEditingController(text: widget.input);
    result = TextEditingController(text: widget.result);
    expected = TextEditingController();
    details = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    input.dispose();
    result.dispose();
    expected.dispose();
    details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          TextFormField(
            controller: input,
            maxLines: 1,
            style: const TextStyle(fontSize: 14.0),
            validator: (input) {
              if (input == null || input.isEmpty) {
                return 'Input is required. Please type something.';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Input',
              alignLabelWithHint: true,
              helperText: 'What was the input for the bug.',
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: result,
            maxLines: 5,
            style: const TextStyle(fontSize: 14.0),
            validator: (input) {
              if (input == null || input.isEmpty) {
                return 'Input Result is required. Please type something.';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Result',
              alignLabelWithHint: true,
              helperText: 'What was the result the input produced.',
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: expected,
            maxLines: 2,
            style: const TextStyle(fontSize: 14.0),
            onChanged: (input) => setState(() => _expectedRTL = _isRTL(input)),
            textDirection: _expectedRTL ? TextDirection.rtl : TextDirection.ltr,
            validator: (input) {
              if (input == null || input.isEmpty) {
                return 'Expected is required. Please type something.';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Expected',
              alignLabelWithHint: true,
              helperText: 'What was the expected result for the bug.',
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: details,
            maxLines: 6,
            validator: (input) {
              if (input == null || input.isEmpty) {
                return 'Report Details are required. Please type something.';
              }
              return null;
            },
            onChanged: (input) => setState(() => _detailsRTL = _isRTL(input)),
            textDirection: _detailsRTL ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(fontSize: 14.0),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Details',
              alignLabelWithHint: true,
              helperText: 'Why is the desired result expected? '
                  'Type here the details of your report.',
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Submit'),
                onPressed: _handleSubmit,
              ),
              TextButton.icon(
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    const String createUrl =
        r"https://harmony-dashboard-server.herokuapp.com/create";
    if (_formKey.currentState!.validate()) {
      final headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": '*',
      };
      final newPageData = {
        "test": widget.testName,
        "parent": databaseID,
        "input": widget.input,
        "expected": expected.text,
        "result": widget.result,
        "details": details.text,
      };
      final response = await http.post(
        Uri.parse(createUrl),
        headers: headers,
        body: jsonEncode(newPageData),
      );
      Navigator.of(context).pop(
        response.statusCode == 200
            ? ReportResult.success
            // TODO: Fix api to return whether it exits and not just read the fail message...
            : (response.body.contains("exists")
                ? ReportResult.exists
                : ReportResult.failed),
      );
    }
  }

  bool _isRTL(String text) => intl.Bidi.detectRtlDirectionality(text);
}

enum ReportResult {
  success,
  failed,
  exists,
}

extension ReportResultExtension on ReportResult {
  String get message {
    switch (this) {
      case ReportResult.success:
        return 'Successfully Sent Your Report!';
      case ReportResult.failed:
        return 'Failed To Send Your Report.';
      case ReportResult.exists:
        return 'This Reports Already Exists!';
    }
  }

  Color get color {
    switch (this) {
      case ReportResult.success:
        return Colors.green;
      case ReportResult.failed:
        return Colors.red;
      case ReportResult.exists:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case ReportResult.success:
        return Icons.check_rounded;
      case ReportResult.failed:
        return Icons.close_rounded;
      case ReportResult.exists:
        return Icons.close_rounded;
    }
  }
}
