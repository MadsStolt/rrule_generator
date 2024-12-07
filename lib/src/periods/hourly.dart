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
  final intervalNotifier = ValueNotifier(1);

  Hourly(this.config, this.textDelegate, this.onChange, this.initialRRule, this.initialDate, {super.key}) {
    if (initialRRule.contains('HOURLY')) {
      handleInitialRRule();
    } else {
      hourNotifier.value = initialDate.hour;
    }
  }

  @override
  void handleInitialRRule() {
    // Parse the initial RRule to set the interval and hourNotifier value
    if (initialRRule.contains('INTERVAL=')) {
      int intervalIndex = initialRRule.indexOf('INTERVAL=') + 9;
      int intervalEndIndex = initialRRule.indexOf(';', intervalIndex);
      if (intervalEndIndex == -1) {
        intervalEndIndex = initialRRule.length;
      }
      String interval = initialRRule.substring(intervalIndex, intervalEndIndex);
      intervalNotifier.value = int.parse(interval);
      hourNotifier.value = int.parse(interval); // Set hourNotifier to interval value
    }
  }

  @override
  String getRRule() {
    final interval = intervalNotifier.value;
    final hour = hourNotifier.value;
    return 'FREQ=HOURLY;INTERVAL=$interval;BYHOUR=$hour';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildContainer(
          child: buildElement(
            title: 'Hour',
            style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
            child: ValueListenableBuilder<int>(
              valueListenable: hourNotifier,
              builder: (context, hour, child) {
                return DropdownButton<int>(
                  value: hour,
                  items: List.generate(
                      24,
                      (index) => DropdownMenuItem(
                            value: index,
                            child: Text(index.toString()),
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
          ),
        ),
        buildContainer(
          child: buildElement(
            title: 'Interval',
            style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
            child: ValueListenableBuilder<int>(
              valueListenable: intervalNotifier,
              builder: (context, interval, child) {
                return TextField(
                  controller: TextEditingController(text: interval.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    intervalNotifier.value = int.tryParse(value) ?? 1;
                    onChange();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
