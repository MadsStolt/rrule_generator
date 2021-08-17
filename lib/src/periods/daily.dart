import 'package:flutter/material.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/periods/pickers/interval.dart';
import 'package:rrule_generator/src/periods/period.dart';

class Daily extends StatelessWidget implements Period {
  final RRuleTextDelegate textDelegate;
  final Function onChange;

  final intervalController = TextEditingController(text: '1');

  Daily(this.textDelegate, this.onChange);

  String getRRule() {
    int interval = int.tryParse(intervalController.text) ?? 0;
    return 'FREQ=DAILY;INTERVAL=${interval >= 0 ? interval : 0}';
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(textDelegate.every),
          IntervalPicker(intervalController, onChange),
          Text(textDelegate.days),
        ],
      );
}