import 'package:meta/meta.dart';

class Unit {
  final String name;
  final double conversion;

  const Unit({
    @required this.name,
    @required this.conversion,
  })
      : assert(name != null),
        assert(conversion != null);

  Unit.fromJson(Map jsonMap)
      : assert(jsonMap['name'] != null),
        assert(jsonMap['conversion'] != null),
        this.name = jsonMap['name'],
        this.conversion = jsonMap['conversion'].toDouble();

}