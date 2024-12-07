import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rrule_generator/localizations/english.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/periods/daily.dart';
import 'package:rrule_generator/src/periods/hourly.dart';
import 'package:rrule_generator/src/periods/monthly.dart';
import 'package:rrule_generator/src/periods/period.dart';
import 'package:rrule_generator/src/periods/weekly.dart';
import 'package:rrule_generator/src/periods/yearly.dart';
import 'package:rrule_generator/src/pickers/exclude_dates.dart';
import 'package:rrule_generator/src/pickers/helpers.dart';
import 'package:rrule_generator/src/pickers/interval.dart';
import 'package:rrule_generator/src/rrule_generator_config.dart';

class RRuleGenerator extends StatelessWidget {
  late final RRuleGeneratorConfig config;
  final RRuleTextDelegate textDelegate;
  final void Function(String newValue)? onChange;
  final String initialRRule;
  final DateTime? initialDate;
  final bool withExcludeDates;
  final frequencyNotifier = ValueNotifier(0);
  final countTypeNotifier = ValueNotifier(0);
  final pickedDateNotifier = ValueNotifier(DateTime.now());
  final timeNotifier = ValueNotifier(const TimeOfDay(hour: 0, minute: 0));

  final instancesController = TextEditingController(text: '1');
  final List<Period> periodWidgets = [];
  late final ExcludeDates? _excludeDatesPicker;

  RRuleGenerator({super.key, RRuleGeneratorConfig? config, this.textDelegate = const EnglishRRuleTextDelegate(), this.onChange, this.initialRRule = '', this.withExcludeDates = false, this.initialDate}) {
    this.config = config ?? RRuleGeneratorConfig();

    periodWidgets.addAll([
      Yearly(
        this.config,
        textDelegate,
        valueChanged,
        initialRRule,
        initialDate ?? DateTime.now(),
      ),
      Monthly(
        this.config,
        textDelegate,
        valueChanged,
        initialRRule,
        initialDate ?? DateTime.now(),
      ),
      Weekly(
        this.config,
        textDelegate,
        valueChanged,
        initialRRule,
        initialDate ?? DateTime.now(),
      ),
      Daily(
        this.config,
        textDelegate,
        valueChanged,
        initialRRule,
        initialDate ?? DateTime.now(),
      ),
      Hourly(
        // Added Hourly option
        this.config,
        textDelegate,
        valueChanged,
        initialRRule,
        initialDate ?? DateTime.now(),
      ),
    ]);
    _excludeDatesPicker = withExcludeDates
        ? ExcludeDates(
            this.config,
            textDelegate,
            valueChanged,
            initialRRule,
            initialDate ?? DateTime.now(),
          )
        : null;

    handleInitialRRule();
  }

  void handleInitialRRule() {
    if (initialRRule.contains('MONTHLY')) {
      frequencyNotifier.value = 1;
    } else if (initialRRule.contains('WEEKLY')) {
      frequencyNotifier.value = 2;
    } else if (initialRRule.contains('DAILY')) {
      frequencyNotifier.value = 3;
    } else if (initialRRule.contains('HOURLY')) {
      frequencyNotifier.value = 4;
    } else if (initialRRule == '') {
      frequencyNotifier.value = 5;
    }

    if (initialRRule.contains('COUNT')) {
      countTypeNotifier.value = 1;
      final countIndex = initialRRule.indexOf('COUNT=') + 6;
      int countEnd = initialRRule.indexOf(';', countIndex);
      countEnd = countEnd == -1 ? initialRRule.length : countEnd;
      instancesController.text = initialRRule.substring(countIndex, countEnd);
    } else if (initialRRule.contains('UNTIL')) {
      countTypeNotifier.value = 2;
      final dateIndex = initialRRule.indexOf('UNTIL=') + 6;
      final dateEnd = initialRRule.indexOf(';', dateIndex);
      pickedDateNotifier.value = DateTime.parse(
        initialRRule.substring(dateIndex, dateEnd == -1 ? initialRRule.length : dateEnd),
      );
    }

    if (initialRRule.contains('BYHOUR=')) {
      int hourIndex = initialRRule.indexOf('BYHOUR=') + 7;
      int hourEndIndex = initialRRule.indexOf(';', hourIndex);
      if (hourEndIndex == -1) {
        hourEndIndex = initialRRule.length;
      }
      String hour = initialRRule.substring(hourIndex, hourEndIndex);
      int hourValue = int.parse(hour);

      int minuteValue = 0;
      if (initialRRule.contains('BYMINUTE=')) {
        int minuteIndex = initialRRule.indexOf('BYMINUTE=') + 9;
        int minuteEndIndex = initialRRule.indexOf(';', minuteIndex);
        if (minuteEndIndex == -1) {
          minuteEndIndex = initialRRule.length;
        }
        String minute = initialRRule.substring(minuteIndex, minuteEndIndex);
        minuteValue = int.parse(minute);
      }
      timeNotifier.value = TimeOfDay(hour: hourValue, minute: minuteValue);
    }
  }

  void valueChanged() {
    final fun = onChange;
    if (fun != null) fun(getRRule());
  }

  String getRRule() {
    if (frequencyNotifier.value == 5) {
      return '';
    }

    final String excludeDates = _excludeDatesPicker?.getRRule() ?? '';
    final time = timeNotifier.value;
    final localTimeOffset = DateTime.now().timeZoneOffset.inHours;
    final hour = (time.hour - localTimeOffset) % 24;
    final minute = time.minute;
    const second = 0; // Default seconds to 0

    String timePart = frequencyNotifier.value != 4 ? ';BYHOUR=$hour;BYMINUTE=$minute;BYSECOND=$second' : '';

    String baseRRule = periodWidgets[frequencyNotifier.value].getRRule();
    // Remove any existing time parts from the base RRule to avoid duplicates
    baseRRule = baseRRule.replaceAll(RegExp(r';BYHOUR=\d{1,2}'), '');
    baseRRule = baseRRule.replaceAll(RegExp(r';BYMINUTE=\d{1,2}'), '');
    baseRRule = baseRRule.replaceAll(RegExp(r';BYSECOND=\d{1,2}'), '');

    if (countTypeNotifier.value == 0) {
      String rrule = 'RRULE:$baseRRule$timePart$excludeDates';
      print(rrule);
      return rrule;
    } else if (countTypeNotifier.value == 1) {
      final instances = int.tryParse(instancesController.text) ?? 0;
      String rrule = 'RRULE:$baseRRule$timePart;COUNT=$instances$excludeDates';
      print(rrule);
      return rrule;
    }
    final pickedDate = pickedDateNotifier.value;

    final day = pickedDate.day > 9 ? '${pickedDate.day}' : '0${pickedDate.day}';
    final month = pickedDate.month > 9 ? '${pickedDate.month}' : '0${pickedDate.month}';

    String rrule = 'RRULE:$baseRRule$timePart;UNTIL=${pickedDate.year}$month$day$excludeDates';
    print(rrule);
    return rrule;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: frequencyNotifier,
          builder: (context, period, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildContainer(
                child: buildElement(
                  title: config.headerEnabled ? textDelegate.repeat : null,
                  style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                  child: buildDropdown(
                    child: DropdownButton(
                      isExpanded: true,
                      value: period,
                      onChanged: (newPeriod) {
                        frequencyNotifier.value = newPeriod!;
                        valueChanged();
                      },
                      items: List.generate(
                        6,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(
                            textDelegate.periods[index],
                            style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                    context: context,
                  ),
                ),
              ),
              if (period != 5) ...[
                periodWidgets[period],
                buildContainer(
                  child: Column(
                    children: [
                      if (period != 4)
                        Row(
                          children: [
                            Expanded(
                              child: buildContainer(
                                child: buildElement(
                                  title: 'Time',
                                  style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                  child: ValueListenableBuilder<TimeOfDay>(
                                    valueListenable: timeNotifier,
                                    builder: (context, time, child) {
                                      if (time == const TimeOfDay(hour: 0, minute: 0) && initialDate != null) {
                                        final initialTime = TimeOfDay.fromDateTime(initialDate!);
                                        timeNotifier.value = initialTime;
                                        time = initialTime;
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          valueChanged();
                                        });
                                      }
                                      return TextField(
                                        key: ValueKey(timeNotifier.value),
                                        readOnly: true,
                                        controller: TextEditingController(
                                          text: time.format(context),
                                        ),
                                        decoration: const InputDecoration(
                                          suffixIcon: Icon(Icons.access_time),
                                        ),
                                        onTap: () async {
                                          final TimeOfDay? picked = await showTimePicker(
                                            context: context,
                                            initialTime: time,
                                          );
                                          if (picked != null) {
                                            timeNotifier.value = picked;
                                          }
                                          valueChanged();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      buildContainer(
                        child: Row(
                          children: [
                            Expanded(
                              child: buildElement(
                                title: textDelegate.end,
                                style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                child: buildDropdown(
                                  child: ValueListenableBuilder(
                                    valueListenable: countTypeNotifier,
                                    builder: (context, countType, child) => DropdownButton(
                                      isExpanded: true,
                                      value: countType,
                                      onChanged: (newCountType) {
                                        countTypeNotifier.value = newCountType!;
                                        valueChanged();
                                      },
                                      items: [
                                        DropdownMenuItem(
                                          value: 0,
                                          child: Text(
                                            textDelegate.neverEnds,
                                            style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 1,
                                          child: Text(
                                            textDelegate.endsAfter,
                                            style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 2,
                                          child: Text(
                                            textDelegate.endsOnDate,
                                            style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  context: context,
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: countTypeNotifier,
                              builder: (context, countType, child) => SizedBox(
                                width: countType == 0 ? 0 : 8,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: countTypeNotifier,
                              builder: (context, countType, child) {
                                switch (countType) {
                                  case 1:
                                    return Expanded(
                                      child: buildElement(
                                        title: textDelegate.instances,
                                        style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                        child: IntervalPicker(
                                          instancesController,
                                          valueChanged,
                                          config: config,
                                        ),
                                      ),
                                    );
                                  case 2:
                                    return Expanded(
                                      child: buildElement(
                                        title: textDelegate.date,
                                        style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                        child: ValueListenableBuilder(
                                          valueListenable: pickedDateNotifier,
                                          builder: (context, pickedDate, child) => OutlinedButton(
                                            onPressed: () async {
                                              final picked = await showDatePicker(
                                                context: context,
                                                locale: Locale(
                                                  textDelegate.locale.split('-')[0],
                                                  textDelegate.locale.contains('-') ? textDelegate.locale.split('-')[1] : '',
                                                ),
                                                initialDate: pickedDate,
                                                firstDate: DateTime.utc(2020, 10, 24),
                                                lastDate: DateTime(2100),
                                              );

                                              if (picked != null && picked != pickedDate) {
                                                pickedDateNotifier.value = picked;
                                                valueChanged();
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 24,
                                              ),
                                            ),
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Text(
                                                DateFormat.yMd(
                                                  textDelegate.locale,
                                                ).format(pickedDate),
                                                style: const TextStyle().copyWith(color: Theme.of(context).colorScheme.onSurface),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  default:
                                    return Container();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (child != null) child,
            ],
          ),
          child: _excludeDatesPicker,
        ),
      );
}
