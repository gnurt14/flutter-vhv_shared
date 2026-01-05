import 'package:collection/collection.dart';
import 'package:vhv_state/src/bloc.dart';
enum ModulesStateStatus{initial, loading, loaded, fail}
class ModulesState extends BaseState{
  final Map<String, Map> quickAccessItems;
  final List<ModuleItem> originCategories;
  final List<ModuleItem> categories;
  final String userTypeId;
  final Map<String, Map> userTypes;
  final ModulesStateStatus status;
  final String currentModuleId;
  const ModulesState({
    this.quickAccessItems = const {},
    this.originCategories = const [],
    this.categories = const [],
    this.userTypes = const {},
    this.userTypeId = '',
    this.status = ModulesStateStatus.initial,
    this.currentModuleId = ''
  });
  @override
  List<Object?> get props => [quickAccessItems, originCategories, categories, userTypeId, userTypes, status, currentModuleId];

  List<String> get quickAccessIds => quickAccessItems.keys.toList();
  Map<String, Map> get items => <String, Map>{ for (var e in originCategories.fold(<Map>[], (value, e){
      return <Map>[
        ...value,
        ...e.items
      ];
    })) '${e['id'] ?? ''}' : e };
  ModulesState copyWith({
    Map<String, Map>? quickAccessItems,
    List<ModuleItem>? originCategories,
    List<ModuleItem>? categories,
    String? userTypeId,
    Map<String, Map>? userTypes,
    ModulesStateStatus? status,
    String? currentModuleId
  }){
    return ModulesState(
      quickAccessItems: quickAccessItems ?? this.quickAccessItems,
      originCategories: originCategories ?? this.originCategories,
      categories: categories ?? this.categories,
      userTypeId: userTypeId ?? this.userTypeId,
      userTypes: userTypes ?? this.userTypes,
      status: status ?? this.status,
      currentModuleId: currentModuleId ?? this.currentModuleId,
    );
  }

  bool isQuickAccess(Map e){
    return quickAccessIds.contains(e['id']);
  }
  bool hasSaveQuickAccess(List<String> newQuickAccessIds){
    if(newQuickAccessIds.isEmpty){
      return false;
    }
    return !(const DeepCollectionEquality().equals(quickAccessIds.sorted(), newQuickAccessIds.sorted()));
  }
}

class ModuleItem extends Equatable{
  final String? title;
  final Map? data;
  final List<Map> items;

  const ModuleItem({
    this.title,
    this.data,
    required this.items
  });
  @override
  List<Object?> get props => [title, items, data];

  ModuleItem copyWith({String? title, Map? data, List<Map>? items}){
    return ModuleItem(
      title: title ?? this.title,
      data: data ?? this.data,
      items: items ?? this.items
    );
  }
}