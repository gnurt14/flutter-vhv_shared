import 'package:vhv_state/vhv_state.dart';

class FormMultipleEvent extends BaseEvent{
  FormMultipleEvent();
}
class FormMultipleInitial extends FormMultipleEvent{
  final dynamic value;
  final bool? hasEmptyList;
  FormMultipleInitial(this.value, {this.hasEmptyList});
  @override
  List<Object?> get props => [value];
}
class FormMultipleDelete extends FormMultipleEvent{
  final String key;
  FormMultipleDelete(this.key);
  @override
  List<Object?> get props => [key];
}
class FormMultipleUpdate extends FormMultipleEvent{
  final String itemKey;
  final String key;
  final dynamic value;
  final String? updateKey;
  FormMultipleUpdate({required this.itemKey, required this.key, required this.value, this.updateKey});
  @override
  List<Object?> get props => [itemKey, key, value, updateKey];
}

class FormMultipleAdd extends FormMultipleEvent{}
