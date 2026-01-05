part of 'base_detail_bloc.dart';
enum BaseDetailStateStatus{initial, loading, loaded, error}
class BaseDetailState extends BaseState{
  final Map<String, dynamic>? queries;
  final Map result;
  final Map<String, dynamic> extraData;
  final BaseDetailStateStatus status;
  final String? error;
  final bool isRefreshing;

  const BaseDetailState({
    this.status = BaseDetailStateStatus.initial,
    this.queries,
    this.extraData = const <String, dynamic>{},
    this.result = const {},
    this.error,
    this.isRefreshing = false,
  });
  @override
  List<Object?> get props => [status, queries, result, extraData, error, isRefreshing];
  BaseDetailState copyWith({
    Map<String, dynamic>? queries,
    Map? result,
    Map<String, dynamic>? extraData,
    BaseDetailStateStatus? status,
    String? error,
    bool? isRefreshing
  }){
    if(status != null && status == BaseDetailStateStatus.error
    && (error == null || error == '')){
      throw Exception('Error is not empty');
    }
    if(status != null && status == BaseDetailStateStatus.loaded
        && (result == null)){
      throw Exception('result is not empty');
    }
    return BaseDetailState(
      queries: queries ?? this.queries,
      result: result ?? this.result,
      extraData: extraData ?? this.extraData,
      status: status ?? this.status,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing
    );
  }

  BaseDetailState addToExtraData(String key, dynamic value){
    final newData = Map<String, dynamic>.from(extraData);
    newData.addAll(<String, dynamic>{
      key: value
    });
    return copyWith(extraData: newData);
  }
}