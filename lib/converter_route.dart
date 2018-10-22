import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:unit_converter_app/unit.dart';

const _padding = EdgeInsets.all(16.0);

class ConverterRoute extends StatefulWidget {
  /// This [Category]'s name.
  final String name;

  /// Color for this [Category].
  final Color color;

  /// Units for this [Category].
  final List<Unit> units;

  const ConverterRoute({
    @required this.name,
    @required this.color,
    @required this.units,
  })
      : assert(name != null),
        assert(color != null),
        assert(units != null);

  @override
  _ConverterRouteState createState() => _ConverterRouteState();

}

class _ConverterRouteState extends State<ConverterRoute> {
  Unit _fromValue;
  Unit _toValue;
  double _inputValue;
  String _convertedValue = '';
  List<DropdownMenuItem> _unitMenuItems;
  bool _showValidationError = false;

  /// Creates fresh list of [DropdownMenuItem] widgets, given a list of [Unit]s.
  void _createDropDownMenuItems() {
    var newMenuItems = <DropdownMenuItem>[];
    for (var unit in widget.units) {
      newMenuItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }
    setState(() {
      _unitMenuItems = newMenuItems;
    });
  }

  /// Sets the default values for the 'from' and 'to' [Dropdown]s.
  void _setDefaults() {
    setState(() {
      _fromValue = widget.units[0];
      _toValue = widget.units[1];
    });
  }

  @override
  void initState() {
    super.initState();
    _createDropDownMenuItems();
    _setDefaults();
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
      } else {
        // Even though we are using the numerical keyboard, we still have to check
        // for non-numerical input such as '5..0' or '6 -3
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print(e);
          _showValidationError = true;
        }
      }
    });
  }

  void _updateConversion() {
    setState(() {
      _convertedValue =
          _format(_inputValue * (_toValue.conversion / _fromValue.conversion));
    });
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  Unit _getUnit(String unitName) {
    return widget.units.firstWhere((Unit unit) {
      return unit.name == unitName;
    },
        orElse: null);
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  Widget _createDropDown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        // This sets the color of the [DropdownButton] itself
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[400],
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      // This sets the color of the [DropdownMenuItem]
      child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.green[50]),
          child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  value: currentValue,
                  items: _unitMenuItems,
                  onChanged: onChanged,
                  style: Theme
                      .of(context)
                      .textTheme
                      .title,),
              )
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // This is the widget that accepts text input. In this case, it
          // accepts numbers and calls the onChanged property on update.
          // You can read more about it here: https://flutter.io/text-input
          TextField(
            style: Theme
                .of(context)
                .textTheme
                .display1,
            decoration: InputDecoration(
                labelStyle: Theme
                    .of(context)
                    .textTheme
                    .display1,
                labelText: 'Input',
                errorText: _showValidationError ? 'Invalid number error' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                )
            ),
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
          ),
          // call createDropDown menu method
          _createDropDown(_fromValue.name, _updateFromConversion)
        ],
      ),
    );

    final arrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );

    final output = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
            ),
            decoration: InputDecoration(
                labelStyle: Theme
                    .of(context)
                    .textTheme
                    .display1,
                labelText: 'Output',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                )
            ),
          ),
          // call createDropDown menu method
          _createDropDown(_toValue.name,_updateToConversion)
        ],
      ),
    );

    final converter = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        input,
        arrows,
        output
      ],
    );

    return Padding(
      padding: _padding,
      child: converter,
    );
  }

}
