import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

List<HighlightGroup> intellijDarkHgroups = [
  HighlightGroup(name: 'keyword', textColor: Color(0xFFCE8E6D), priority: 1),

  HighlightGroup(name: 'variable', textColor: Colors.red, priority: 10),
  HighlightGroup(name: 'string', textColor: Color(0xFF6AAB73), priority: 10),
  HighlightGroup(name: 'class', textColor: Colors.lightBlue, priority: 10),
  HighlightGroup(name: 'meta', textColor: Colors.yellowAccent, priority: 10),
  HighlightGroup(name: 'title', textColor: Colors.tealAccent, priority: 10),
  HighlightGroup(name: 'type', textColor: Colors.tealAccent, priority: 10),
  HighlightGroup(name: 'function', textColor: Color(0xFF57A8F5), priority: 10),
  HighlightGroup(name: 'built_in', textColor: Color(0xFF57A8F5), priority: 10),
  HighlightGroup(name: 'number', textColor: Colors.tealAccent, priority: 10),
];
