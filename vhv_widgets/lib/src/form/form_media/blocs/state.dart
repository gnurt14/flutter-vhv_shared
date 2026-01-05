import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';


class MediaItem extends Equatable{
  final String? path;
  final String? link;
  final int? size;
  final String title;
  final String sortOrder;
  final String? error;
  final bool isUploading;
  final bool hasRetry;
  final double percentUploading;
  final String key;

  const MediaItem({
    required this.key,
    this.path,
    this.link,
    this.size,
    required this.title,
    required this.sortOrder,
    this.error,
    this.isUploading = false,
    this.hasRetry = false,
    this.percentUploading = 0.0
  });
  @override
  List<Object?> get props => [key, path, link, size, title, sortOrder, error, hasRetry, isUploading, percentUploading];

  MediaItem copyWith({
    String? path,
    String? link,
    int? size,
    String? title,
    String? sortOrder,
    String? error,
    bool? isUploading,
    bool? hasRetry,
    double? percentUploading,
  }){
    return MediaItem(
      path: path ?? this.path,
      link: link ?? this.link,
      size: size ?? this.size,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      error: (isUploading == true || !empty(link)) ? null : (error ?? this.error),
      isUploading: isUploading ?? this.isUploading,
      hasRetry: hasRetry ?? this.hasRetry,
      key: key,
      percentUploading: percentUploading ?? this.percentUploading,
    );
  }

}
class FormMediaState extends BaseState{
  final Map<String, MediaItem> items;
  const FormMediaState({this.items = const {}});

  FormMediaState copyWith({
    Map<String, MediaItem>? items,
  }){
    return FormMediaState(
      items: items ?? this.items,
    );
  }

  FormMediaState update(String key, MediaItem item){
    if(!items.containsKey(key)){
      return this;
    }
    return copyWith(
      items: <String, MediaItem>{
        ...items,
        key: item
      }
    );
  }
  FormMediaState remove(String key){
    return copyWith(
      items: <String, MediaItem>{...items}..remove(key)
    );
  }

  @override
  List<Object?> get props => [items];
  @override
  String toString() {
    return itemsToString(items);
  }
  String itemsToString(Map<String, MediaItem> items){
    return items.values.map((e) => '${e.path}|${e.link}|${e.size}|${e.title}|${e.sortOrder}|${e.error}|${e.isUploading}|${e.hasRetry}').toString();
  }

  MediaItem? getItem(String id){
    return items[id];
  }
  bool get isUploading => items.isNotEmpty
      && items.values.where((value) => value.isUploading).length == items.length;
}