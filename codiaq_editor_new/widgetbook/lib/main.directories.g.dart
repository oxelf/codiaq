// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _i1;
import 'package:widgetbook_workspace/usecases/button.dart' as _i2;
import 'package:widgetbook_workspace/usecases/checkbox.dart' as _i3;
import 'package:widgetbook_workspace/usecases/input_field.dart' as _i6;
import 'package:widgetbook_workspace/usecases/link.dart' as _i4;
import 'package:widgetbook_workspace/usecases/notification_balloon.dart' as _i5;
import 'package:widgetbook_workspace/usecases/text_area.dart' as _i7;

final directories = <_i1.WidgetbookNode>[
  _i1.WidgetbookFolder(
    name: 'ui',
    children: [
      _i1.WidgetbookFolder(
        name: 'cq_widgets',
        children: [
          _i1.WidgetbookComponent(
            name: 'CQButton',
            useCases: [
              _i1.WidgetbookUseCase(
                name: 'Disabled',
                builder: _i2.buildDisabledButton,
              ),
              _i1.WidgetbookUseCase(
                name: 'Primary',
                builder: _i2.buildPrimaryButton,
              ),
              _i1.WidgetbookUseCase(
                name: 'Secondary',
                builder: _i2.buildSecondaryButton,
              ),
            ],
          ),
          _i1.WidgetbookComponent(
            name: 'CQCheckbox',
            useCases: [
              _i1.WidgetbookUseCase(
                name: 'Checked',
                builder: _i3.buildCheckedCheckbox,
              ),
              _i1.WidgetbookUseCase(
                name: 'Disabled',
                builder: _i3.buildDisabledCheckbox,
              ),
            ],
          ),
          _i1.WidgetbookComponent(
            name: 'CQLink',
            useCases: [
              _i1.WidgetbookUseCase(name: 'Default', builder: _i4.buildLink),
              _i1.WidgetbookUseCase(
                name: 'Disabled',
                builder: _i4.builDisabledLink,
              ),
              _i1.WidgetbookUseCase(
                name: 'Dropdown',
                builder: _i4.buildDropdownLink,
              ),
            ],
          ),
          _i1.WidgetbookLeafComponent(
            name: 'CQNotificationBalloon',
            useCase: _i1.WidgetbookUseCase(
              name: 'Default',
              builder: _i5.buildNotificationBalloon,
            ),
          ),
          _i1.WidgetbookComponent(
            name: 'InputField',
            useCases: [
              _i1.WidgetbookUseCase(
                name: 'Default',
                builder: _i6.buildInputField,
              ),
              _i1.WidgetbookUseCase(
                name: 'Prefix',
                builder: _i6.buildInputFieldWithPrefix,
              ),
              _i1.WidgetbookUseCase(
                name: 'Suffix',
                builder: _i6.buildInputFieldWithSuffix,
              ),
            ],
          ),
          _i1.WidgetbookComponent(
            name: 'TextArea',
            useCases: [
              _i1.WidgetbookUseCase(
                name: 'Default',
                builder: _i7.buildInputField,
              ),
              _i1.WidgetbookUseCase(
                name: 'Expand Icon',
                builder: _i7.buildInputFieldWithSuffix,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
