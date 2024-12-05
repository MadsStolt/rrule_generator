import 'package:flutter/material.dart';

class RRuleGeneratorConfig {
  RRuleGeneratorConfig({
    this.textFieldBorderRadius = const Radius.circular(8),  
    this.headerEnabled = true,
  });

  final bool headerEnabled;
  final Radius textFieldBorderRadius;
}
