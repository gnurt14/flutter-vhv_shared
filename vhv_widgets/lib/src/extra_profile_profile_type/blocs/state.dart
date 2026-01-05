

import 'package:vhv_state/vhv_state.dart';

class ExtraProfileProfileTypeState extends BaseState{
  final bool isMultiple;
  final String formId;
  final String id;
  final String entityTitle;
  final Map<String, dynamic> queries;
  final Map<String, dynamic> extraData;
  final String service;


  const ExtraProfileProfileTypeState({
    this.isMultiple = false,
    this.formId = '',
    this.id = '',
    this.entityTitle = '',
    this.queries = const {},
    this.extraData = const {},
    this.service = '',
  });

  @override
  List<Object?> get props => [isMultiple, formId, id, entityTitle, queries, extraData, service];

  ExtraProfileProfileTypeState copyWith({
    bool? isMultiple,
    String? formId,
    String? id,
    String? entityTitle,
    Map<String, dynamic>? queries,
    Map<String, dynamic>? extraData,
    String? service
  }){
    return ExtraProfileProfileTypeState(
      isMultiple: isMultiple ?? this.isMultiple,
      formId: formId ?? this.formId,
      id: id ?? this.id,
      entityTitle: entityTitle ?? this.entityTitle,
      queries: queries ?? this.queries,
      extraData: extraData ?? this.extraData,
      service: service ?? this.service,
    );
  }
}
