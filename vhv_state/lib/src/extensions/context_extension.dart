part of '../extension.dart';

extension VHVStateContextExtension on BuildContext{

  ConfigBloc get configBloc => read<ConfigBloc>();
}