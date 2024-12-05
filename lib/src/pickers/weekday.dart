import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/rrule_generator_config.dart';

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker(
    this.weekdayNotifiers,
    this.textDelegate,
    this.onChange, {
    super.key,
    required this.config,
  });

  final RRuleTextDelegate textDelegate;
  final Function onChange;

  final RRuleGeneratorConfig config;

  final List<ValueNotifier<bool>> weekdayNotifiers;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: List.generate(
            7,
            (index) => ValueListenableBuilder(
              valueListenable: weekdayNotifiers[index],
              builder: (context, value, child) {
                // Start with Monday as per ISO-8601 (Monday = 1, Sunday = 7)
                final date = DateTime(2023, 1, 2 + index);
                final weekday = DateFormat.E(textDelegate.locale).format(date);

                return Expanded(
                  child: InkWell(
                    child: Container(
                      margin: const EdgeInsets.only(right: 2),
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        color: value
                            ? Theme.of(context).colorScheme.primary // Use theme's primary color
                            : Theme.of(context).colorScheme.surface, // Use surface color
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FittedBox(
                        child: Text(
                          weekday,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: value
                                    ? Theme.of(context).colorScheme.onPrimary // Text color on selected
                                    : Theme.of(context).colorScheme.onSurface, // Text color on default
                              ),
                        ),
                      ),
                    ),
                    onTap: () {
                      weekdayNotifiers[index].value = !value;
                      onChange();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
}
