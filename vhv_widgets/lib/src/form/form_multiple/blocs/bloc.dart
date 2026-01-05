import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';

import 'state.dart';
import 'event.dart';

export 'state.dart';
export 'event.dart';

class FormMultipleBloc extends BaseBloc<FormMultipleEvent, FormMultipleState> {
  final dynamic initialValue;

  FormMultipleBloc(this.initialValue, {
    this.onEventListener,
    this.onInit,
    this.hasEmptyList = true
  }) : super(createInitialValue(initialValue)) {
    on<FormMultipleInitial>(_initial);
    on<FormMultipleDelete>(_delete);
    on<FormMultipleAdd>(_add);
    on<FormMultipleUpdate>(_update);
    onInit?.call(state.items);
  }

  final Function(FormMultipleEvent event)? onEventListener;
  final Function(Map<String, Map> initData)? onInit;
  final bool hasEmptyList;

  static FormMultipleState createInitialValue(dynamic initialValue, { bool?hasEmptyList}) {
    final items = <String, Map>{};
    if ((initialValue is Map || initialValue is List) && initialValue.isNotEmpty) {
      int sortOrder = 1;
      for (var item in toList(initialValue)) {
        if (item is Map) {
          items.addAll({
            '$sortOrder': {
              ...item,
              'sortOrder': sortOrder++
            }
          });
        } else if (item is String) {
          items.addAll({
            '$sortOrder': {
              'title': item,
              'sortOrder': sortOrder++
            }
          });
        } else {
          items.addAll({
            '$sortOrder': {
              'sortOrder': sortOrder++
            }
          });
        }
      }
    } else {
      if (!(hasEmptyList ?? false)) {
        items.addAll({
          '1': {
            'sortOrder': 1
          }
        });

      }
    }
    return FormMultipleState(items: items);
  }

  void _initial(FormMultipleInitial event, Emitter emit) {
    emit(createInitialValue(event.value, hasEmptyList: event.hasEmptyList));
  }

  void _delete(FormMultipleDelete event, Emitter emit) {
    final newItems = Map<String, Map>.from(state.items);
    int sortOrder = 1;

    newItems.remove(event.key);
    if (newItems.isEmpty && !hasEmptyList) {
      newItems.addAll({
        '1': {
          'sortOrder': 1
        }
      });
    }

    emit(state.copyWith(
        items: newItems.map((k, v) =>
            MapEntry('$sortOrder', {
              ...v,
              'sortOrder': sortOrder++
            })),
        lastUpdateKey: '[${event.key}][^]'
    ));
  }

  void _add(FormMultipleAdd event, Emitter emit) {
    final newItems = Map<String, Map>.from(state.items);
    newItems.addAll({
      '${newItems.length + 1}': {
        'sortOrder': '${newItems.length + 1}'
      }
    });
    emit(state.copyWith(
        items: newItems,
        lastUpdateKey: ''
    ));
  }

  void _update(FormMultipleUpdate event, Emitter emit) {
    ///String key, Map value
    final newItems = Map<String, Map>.from(state.items);
    newItems.addAll({
      event.itemKey: {
        ...(newItems[event.itemKey] ?? {}),
        event.key: event.value,
      }
    });
    final item = newItems[event.itemKey];
    emit(state.copyWith(
        items: newItems,
        lastUpdateKey: event.updateKey ?? (item != null ? '[${item['sortOrder']}][${event.key}]' : '')
    ));
  }

  @override
  void onEvent(FormMultipleEvent event) {
    if (onEventListener != null) {
      onEventListener!(event);
    }
    super.onEvent(event);
  }
}