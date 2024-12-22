import 'package:flutter/material.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/periods/period.dart';
import 'package:rrule_generator/src/pickers/helpers.dart';

import '../rrule_generator_config.dart';

class Hourly extends StatelessWidget implements Period {
  @override
  final RRuleGeneratorConfig config;
  @override
  final RRuleTextDelegate textDelegate;
  @override
  final void Function() onChange;
  @override
  final String initialRRule;
  @override
  final DateTime initialDate;

  final hourNotifier = ValueNotifier(0);

  Hourly(this.config, this.textDelegate, this.onChange, this.initialRRule, this.initialDate, {super.key}) {
    if (initialRRule.contains('HOURLY')) {
      handleInitialRRule();
    } else {
      hourNotifier.value = initialDate.hour;
    }
  }

  @override
  void handleInitialRRule() {
    if (initialRRule.contains('INTERVAL=')) {
      int intervalIndex = initialRRule.indexOf('INTERVAL=') + 9;
      int intervalEndIndex = initialRRule.indexOf(';', intervalIndex);
      if (intervalEndIndex == -1) {
        intervalEndIndex = initialRRule.length;
      }
      String interval = initialRRule.substring(intervalIndex, intervalEndIndex);
      hourNotifier.value = int.parse(interval); // Set hourNotifier to interval value
    }
  }

  @override
  String getRRule() {
    final hour = hourNotifier.value;
    return 'FREQ=HOURLY;INTERVAL=${hour > 0 ? hour : 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildElement(
          title: textDelegate.every,
          style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
          child: Row(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: hourNotifier,
                builder: (context, hour, child) {
                  return DropdownButton<int>(
                    value: hour,
                    items: List.generate(
                        23,
                        (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text((index + 1).toString()),
                            )),
                    onChanged: (value) {
                      if (value != null) {
                        hourNotifier.value = value;
                        onChange();
                      }
                    },
                  );
                },
              ),
              const Text('Hour(s)'),
            ],
          ),
        ),
      ],
    );
  }
}
