import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';

import 'blocs/bloc.dart';
export 'blocs/bloc.dart';

class FormMultiple extends StatelessWidget {
  const FormMultiple({super.key,
    this.onChanged,
    this.hideDelete = false,
    this.bottomBuilder,
    this.value,
    required this.builder,
    this.separatorBuilder,
    this.padding,
    this.enabled = true,
    this.onEvent,
    this.onInit,
    this.focusNode,
    this.decoration,
    this.contentItemPadding,
    this.hasEmptyList = true
  });
  final void Function(String changedKey, Map<String, Map> value)? onChanged;
  final Function(FormMultipleEvent event)? onEvent;
  final bool hideDelete;
  final Widget Function(BuildContext context)? bottomBuilder;
  final dynamic value;
  final Widget Function(BuildContext context, Map item,
      Function(String key, dynamic value, [String? updateKey]) onChanged)
  builder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsets? padding;
  final bool enabled;
  final Function(Map<String, Map> initData)? onInit;
  final FocusNode? focusNode;
  final Decoration? decoration;
  final EdgeInsetsGeometry? contentItemPadding;
  final bool hasEmptyList;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormMultipleBloc(
          value,
        onEventListener: onEvent,
        onInit: onInit,
          hasEmptyList: hasEmptyList
      ),
      child: _FormMultipleContent(
        value: value,
        onChanged: onChanged,
        hideDelete: hideDelete,
        bottomBuilder: bottomBuilder,
        separatorBuilder: separatorBuilder,
        padding: padding,
        builder: builder,
        enabled: enabled,
        focusNode: focusNode,
        decoration: decoration,
        contentItemPadding: contentItemPadding,
        hasEmptyList: hasEmptyList,
      ),
    );
  }
}
class _FormMultipleContent extends StatefulWidget {
  const _FormMultipleContent({
    this.onChanged,
    this.hideDelete = false,
    this.bottomBuilder,
    required this.builder,
    this.separatorBuilder,
    this.padding,
    this.enabled = true,
    this.value,
    this.focusNode,
    this.decoration,
    this.contentItemPadding,
    required this.hasEmptyList
  });
  final void Function(String changedKey, Map<String, Map> value)? onChanged;
  final bool hideDelete;
  final dynamic value;
  final Widget Function(BuildContext context)? bottomBuilder;
  final Widget Function(BuildContext context, Map item, Function(String key, dynamic value, [String? updateKey]) onChanged)
  builder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsets? padding;
  final bool enabled;
  final FocusNode? focusNode;
  final Decoration? decoration;
  final EdgeInsetsGeometry? contentItemPadding;
  final bool hasEmptyList;
  @override
  State<_FormMultipleContent> createState() => _FormMultipleContentState();
}

class _FormMultipleContentState extends State<_FormMultipleContent> {

  FormMultipleBloc? _bloc;
  late Key key;
  @override
  void initState() {
    key = UniqueKey();
    widget.focusNode?.addListener(_handleFocusChange);
    super.initState();
  }

  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus == true && mounted) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }


  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }


  @override
  void didUpdateWidget(_FormMultipleContent oldWidget) {
    if (_bloc != null) {
      if (oldWidget.value.toString() != widget.value.toString()) {
        _bloc!.add(FormMultipleInitial(widget.value, hasEmptyList: widget.hasEmptyList));

      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      widget.focusNode?.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  bool get showDelete{
    if(!widget.hideDelete && widget.enabled){
      if(_bloc?.hasEmptyList == false && _bloc?.state.items.length == 1
        && _bloc?.state.items.values.first.length == 1
        && _bloc?.state.items.values.first.containsKey('sortOrder') == true
      ){
        return false;
      }
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormMultipleBloc, FormMultipleState>(
      listener: (context, state){
        if(widget.onChanged != null){
          widget.onChanged!(state.lastUpdateKey, state.items);
        }
      },
      buildWhen: (prev, current){
        return prev.items.keys.toString() != current.items.keys.toString();
      },
      builder: (context, state){
        final bloc = context.read<FormMultipleBloc>();
        _bloc ??= context.read<FormMultipleBloc>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                final item = state.items.entries.elementAt(index);
                return BlocSelector<FormMultipleBloc, FormMultipleState, Map>(
                  selector: (state) => state.items[item.key] ?? {},
                  builder: (context, e){

                    return Container(
                      padding: widget.contentItemPadding,
                      decoration: widget.decoration,
                      child: Row(
                        key: ValueKey('${key.hashCode}-item-${item.key}'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: widget.builder(context, e, (k, v, [updateKey]){
                                bloc.add(FormMultipleUpdate(
                                    itemKey: item.key,
                                    key: k,
                                    value: v,
                                    updateKey: updateKey
                                ));
                              })
                          ),
                          if(showDelete)IconButton(
                            onPressed: (){
                              FocusScope.of(context).requestFocus(FocusNode());
                              bloc.add(FormMultipleDelete(item.key));
                            },
                            icon: const Icon(ViIcons.trash_can, color: Colors.red,),
                            style: IconButton.styleFrom(
                                fixedSize: const Size(48, 48),
                                minimumSize: const Size(48, 48)
                            ),
                          ).marginOnly(
                              top: 3,
                              left: 5
                          )
                        ],
                      ),
                    );
                  }
                );
              },
              separatorBuilder: (context, index){
                if(widget.separatorBuilder != null){
                  return widget.separatorBuilder!(context, index);
                }
                return const SizedBox(height: 15,);
              },
              itemCount: state.items.length
            ),
            if(widget.bottomBuilder == null)Visibility(
              visible: widget.enabled,
              child: BaseButton(
                  onPressed: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    bloc.add(FormMultipleAdd());
                  },
                  child: Text( "Thêm".lang())
              ).marginOnly(
                  top: 10
              ),
            ),
            if(widget.bottomBuilder != null)widget.bottomBuilder!(context)
          ],
        );
      },
    );
  }
}

