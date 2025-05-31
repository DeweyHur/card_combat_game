import 'package:flame/components.dart';

class DataComponent extends Component {
  final Function(dynamic)? onDataChanged;
  String? _dataKey;
  dynamic _data;

  DataComponent({this.onDataChanged});

  void setDataKey(String key) {
    _dataKey = key;
    // TODO: Subscribe to data changes using the key
  }

  void setData(dynamic data) {
    _data = data;
    onDataChanged?.call(data);
  }

  dynamic get data => _data;
  String? get dataKey => _dataKey;
}
