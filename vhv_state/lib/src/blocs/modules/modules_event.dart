import 'package:vhv_state/src/bloc.dart';

class ModulesEvent extends BaseEvent{}

class FetchDataModules extends ModulesEvent{}
class ClearDataModules extends ModulesEvent{}
class ChangedModule extends ModulesEvent{
  final Map params;
  ChangedModule(this.params);
  @override
  List<Object?> get props => [params];
}
class SaveQuickAccessModules extends ModulesEvent{
  final List<String> ids;
  SaveQuickAccessModules(this.ids);
  @override
  List<Object?> get props => [ids];
}

class UpdateUserTypeModules extends ModulesEvent{
  final String userType;
  UpdateUserTypeModules(this.userType);
  @override
  List<Object?> get props => [userType];
}