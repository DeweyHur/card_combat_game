import 'package:flame/components.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

/// A component that binds to a DataController key and calls [onDataChanged]
/// whenever the data for [dataKey] changes. Automatically manages watcher lifecycle.
class DataComponent<T> extends Component {
  String _dataKey;
  final void Function(T value) onDataChanged;
  Function(dynamic)? _watcher;

  DataComponent({required String dataKey, required this.onDataChanged})
      : _dataKey = dataKey;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _attachWatcher();
  }

  void setDataKey(String newKey) {
    if (_dataKey == newKey) return;
    _detachWatcher();
    _dataKey = newKey;
    _attachWatcher();
  }

  void _attachWatcher() {
    _watcher = (dynamic value) => onDataChanged(value as T);
    DataController.instance.watch(_dataKey, _watcher!);
  }

  void _detachWatcher() {
    if (_watcher != null) {
      DataController.instance.unwatch(_dataKey, _watcher!);
      _watcher = null;
    }
  }

  @override
  void onRemove() {
    _detachWatcher();
    super.onRemove();
  }
}
