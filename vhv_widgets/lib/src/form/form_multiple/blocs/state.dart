import 'package:vhv_state/vhv_state.dart';

class FormMultipleState extends BaseState{
  final Map<String, Map> items;
  final String lastUpdateKey;
  const FormMultipleState({required this.items, this.lastUpdateKey = ''});
  @override
  List<Object?> get props => [items, lastUpdateKey];
  FormMultipleState copyWith({
    Map<String, Map>? items,
    String? lastUpdateKey
  }){
    return FormMultipleState(
      items: items ?? this.items,
      lastUpdateKey: lastUpdateKey ?? this.lastUpdateKey,
    );
  }
}