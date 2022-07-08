import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import '../main.dart';

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
    this.useCheckbox = false,
  }) : super(key: key);

  final String title;
  final String hintText;
  final String labelText;
  final bool useCheckbox;
  final List<Widget> children;
  final void Function(dynamic) onChanged;
  final Widget? suffixIcon;
  final String resultString;
  final String? inputString;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  late final TextEditingController _controller;
  bool value = false;

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
        (widget.useCheckbox
            ? Row(
              children: [
                Text(widget.labelText),
                Checkbox(
                    value: value,
                    onChanged: (val) => setState(() {
                      value = val!;
                      widget.onChanged(value);
                    }),
                  ),
              ],
            )
            : TextField(
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
              )),
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
