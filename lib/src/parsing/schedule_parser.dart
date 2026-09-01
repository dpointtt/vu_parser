import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/schedule_event.dart';

class ScheduleParser {
  ScheduleParser._();

  static List<ScheduleEvent> parse(String response) {
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final events = decoded['events'] as List;
    return events.cast<Map<String, dynamic>>().map(_parseEvent).toList();
  }

  static ScheduleEvent _parseEvent(Map<String, dynamic> event) {
    final className = event['className'] as String?;
    final rawTitle = event['title'] as String;
    final start = DateTime.parse(event['start'] as String);
    final end = DateTime.parse(event['end'] as String);

    if (!_isHtml(rawTitle)) {
      return ScheduleEvent(
        className: className,
        title: rawTitle,
        start: start,
        end: end,
      );
    }

    final link = html_parser.parse(rawTitle).querySelector('a');

    return ScheduleEvent(
      className: className,
      title: link?.text.trim() ?? '',
      start: start,
      end: end,
      types: _extractAttributeText(link, 'data-showed_type', prefix: 'Tipas: '),
      professors: _extractAttributeText(link, 'data-academics', prefix: 'Dėstytojai: '),
      groups: _extractGroups(link?.attributes['data-groups']),
      subgroups: _extractAttributeText(link, 'data-subgroups', prefix: 'Pogrupiai: '),
      classroom: _extractAttributeText(link, 'data-rooms', prefix: 'Patalpos: '),
    );
  }

  static bool _isHtml(String value) {
    return html_parser.parseFragment(value).children.isNotEmpty;
  }

  static String? _extractAttributeText(
      Element? element,
      String attribute, {
        required String prefix,
      }) {
    final raw = element?.attributes[attribute];
    if (raw == null) return null;

    final text = html_parser.parse(raw).body?.text ?? '';
    final withoutPrefix =
    text.startsWith(prefix) ? text.substring(prefix.length) : text;

    return withoutPrefix.isEmpty ? null : withoutPrefix;
  }

  static List<String>? _extractGroups(String? value) {
    if (value == null || value.isEmpty) return null;

    final groups = html_parser
        .parse(value)
        .querySelectorAll('a')
        .map((element) => element.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    return groups.isEmpty ? null : groups;
  }

}