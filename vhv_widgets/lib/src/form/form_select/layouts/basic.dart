import 'dart:math';

import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/src/core/input_decoration_base.dart';

import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectBasic extends FormSelectWrapper {
  const FormSelectBasic({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.itemBuilder,
    super.makeTree,
    super.focusNode,
    required this.options,
  });
  final BasicOptions options;


  @override
  Widget child(BuildContext context, FormSelectState state) {
    InputDecorationBase inputDecoration = VHVForm.instance.inputDecoration(options.decoration).copyWith(
      enabled: enabled
    );
    inputDecoration = VHVForm.instance.extraInputDecoration(context, inputDecoration);


    return BlocConsumer<FormSelectBloc, FormSelectState>(
      listener: (context, state){
        if(options.itemsCallback != null && state.isLoaded){
          options.itemsCallback!(state.originItems.values.toList());
        }
      },
      buildWhen: (prev, current){
        return !isEqual(prev.selectedIds, current.selectedIds)
            || !isEqual(prev.originItems, current.originItems);
      },
      builder: (context, state){
        final bloc = context.read<FormSelectBloc>();
        final value = state.selectedIds;
        if(options.widgetBuilder != null){
          return options.widgetBuilder!(getValue(value, bloc) ?? '', isEnabled ?
              () => openItems(context, state) : null);
        }
        return InputDecoratorBase(
          focusNode: focusNode,
          onPressed: isEnabled ? () async {
            openItems(context, state);
          } : null,
          isEmpty: (value == null || value.isEmpty || value.first == ''),
          value: getValue(value, bloc),
          decoration: inputDecoration.copyWith(
            hintText: hintText,
            labelText: options.labelText,
            required: options.required,
            suffixIcon: options.trailing ?? BlocSelector<FormSelectBloc, BaseListState<Map>, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isLoading){
                if(isLoading){
                  return const SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  );
                }
                return const Icon(ViIcons.chevron_down);
              },
            ),
            errorText: isEnabled ? errorText : null
          ),
          enabled: isEnabled,
        );
      }
    );
  }


  Future<void> openItems(BuildContext context, FormSelectState state)async{
    final sizeSearchBar = Size(context.appTheme?.searchBarListHeight ?? defaultSearchBarHeight, context.appTheme?.searchBarListHeight ?? defaultSearchBarHeight);
    bool hasDelayed = false;
    try{
      hasDelayed = MediaQuery.of(globalContext).viewInsets.bottom > 10;
    }catch(_){}
    FocusScope.of(context).requestFocus(FocusNode());
    if(hasDelayed){
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if(!context.mounted){
      return;
    }
    if(state.isFail){
      context.read<FormSelectBloc>().add(RefreshBaseList(completer: null));
    }
    AppBottomSheets().showFlexibleBottomSheet(
      context: context,
      title: options.menuTitle,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      builder: (context3, scrollController, pos){
        final GlobalKey key = GlobalKey();
        return SafeArea(
          child: LayoutBuilder(
              builder: (context2, c) {
                if((c.maxHeight - context3.mediaQueryViewInsets.bottom) < 250 && context3.mediaQueryViewInsets.bottom > 0){
                  FocusScope.of(context3).requestFocus(FocusNode());
                }
                return BlocProvider.value(
                  value: context.read<FormSelectBloc>(),
                  child: Builder(
                    builder: (context){
                      final bloc = context.read<FormSelectBloc>();
                      final showDoneButton = bloc.isMulti && pos > 0.3;
                      Widget itemWidget(BuildContext context, Map item, bool isSelected){
                        return ListTileTheme(
                          data: ListTileThemeData(
                            horizontalTitleGap: 12,
                            minTileHeight: 0,
                            minVerticalPadding: 3,
                            minLeadingWidth: 0,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: paddingBase,
                                vertical: 8
                            ).copyWith(
                                left: max(makeTree ? parseDouble((paddingBase * 2) * max(0, parseInt(item['level']) - 1)) : paddingBase, paddingBase)
                            ),
                          ),
                          child: Material(
                            elevation: 0,
                            color: Colors.transparent,
                            child: wrapper(
                                context: context,
                                item: item,
                                state: state,
                                builder: (title, isSelected, onChanged) {
                                  if(itemBuilder != null){
                                    return itemBuilder!(item, () => onChanged(), isSelected);
                                  }
                                  return ListTile(
                                      leading: IgnorePointer(
                                        ignoring: true,
                                        child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: bloc.isMulti ? Checkbox(value: isSelected, onChanged: (_){})
                                              : Radio(value: isSelected, groupValue: true, onChanged: (_){}),
                                        ),
                                      ),
                                      title: Text(title, style: TextStyle(decoration: !empty(item['disabled']) ? TextDecoration.lineThrough : TextDecoration.none,),),
                                      enabled: isEnabled,
                                      onTap: !empty(item['disabled']) ? null : (){
                                        onChanged((){
                                          if(!bloc.isMulti) {
                                            Navigator.of(context).pop();
                                          }
                                        });
                                      },
                                  );
                                }
                            ),
                          ),
                        );
                      }
                      final firstActive = state.items.firstWhereOrNull((element) => state.selectedIds?.contains(bloc.getItemId(element.value)) == true);
                      final firstActiveIndex = state.items.indexWhere((element) => state.selectedIds?.contains(bloc.getItemId(element.value)) == true);
                      return GestureDetector(
                        onTap: (){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          children: [
                            BaseListView<FormSelectBloc, FormSelectState, Map>(
                              cacheExtent: 10000,
                              shrinkWrap: true,
                              onCreated: (controller){
                                if(firstActive != null){
                                  Future.delayed(Duration(milliseconds: 50),(){
                                    safeRun(()async{
                                      controller.jumpTo(firstActiveIndex * 25
                                          // , duration: Duration(milliseconds: 300), curve: Curves.linear
                                      );
                                      if (key.currentContext != null) {
                                        Scrollable.ensureVisible(
                                          key.currentContext!,
                                          duration: Duration.zero,
                                        ).then((_) {
                                          final box = key.currentContext!
                                              .findRenderObject() as RenderBox;
                                          box.localToGlobal(
                                              Offset.zero);
                                        });
                                      }
                                    });
                                  });
                                }
                              },
                              physics: ClampingScrollPhysics(),
                              pinnedHeader: BaseListViewPinnedHeader(
                                height: !options.showSearch ? contentPaddingBase : sizeSearchBar.height + (contentPaddingBase * 2),
                                pinned: true,
                                child: !options.showSearch ? Container(
                                  color: Theme.of(context).cardColor,
                                  height: paddingBase,
                                  width: double.infinity,
                                ) : Material(
                                  color: Theme.of(context).cardColor,
                                  elevation: 0,
                                  child: Padding(
                                    padding: basePadding.copyWith(
                                      top: 0
                                    ),
                                    child: BlocBuilder<FormSelectBloc, FormSelectState>(
                                      bloc: bloc,
                                      buildWhen: (prev, current){
                                        return prev.keyword != current.keyword
                                            || prev.selectedIds != current.selectedIds
                                            || prev.status != current.status
                                        ;
                                      },
                                      builder: (context, state){
                                          final trailing = [
                                            Visibility(
                                              visible: bloc.textEditingSearchController.text != '',
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  style: IconButton.styleFrom(
                                                    fixedSize: sizeSearchBar,
                                                    minimumSize: sizeSearchBar,
                                                    maximumSize: sizeSearchBar,
                                                  ),
                                                  onPressed: (){
                                                    FocusScope.of(context).requestFocus(FocusNode());
                                                    bloc.textEditingSearchController.clear();
                                                    if(bloc.isAutocomplete){
                                                      bloc.add(SearchBaseList('', key: options.searchKey));
                                                    }else{
                                                      bloc.add(LocalSearchBaseList(''));
                                                    }
                                                  },
                                                  icon: const Icon(ViIcons.x_circle)
                                              ),
                                            ),
                                            Visibility(
                                              visible: (bloc.isMulti && state.isLoaded && !options.hideSelectAll),
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  style: IconButton.styleFrom(
                                                    fixedSize: sizeSearchBar,
                                                    minimumSize: sizeSearchBar,
                                                    maximumSize: sizeSearchBar,
                                                  ),
                                                  onPressed: (){
                                                    bloc.add(ToggleSelectAllBaseList());
                                                  },
                                                  tooltip: "Chọn tất cả".lang(),
                                                  icon: Icon(state.isSelectingAll
                                                      ? Icons.check_circle : Icons.check_circle_outlined,
                                                    color: state.isSelectingAll ? Theme.of(context).primaryColor : null,
                                                  )
                                              ),
                                            )
                                          ];
                                          return SizedBox(
                                            height: sizeSearchBar.height,
                                            child: SearchBar(
                                              controller: bloc.textEditingSearchController,
                                              backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
                                              hintText: "Tìm kiếm".lang(),
                                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                                              trailing: trailing,
                                              leading: SizedBox(
                                                width: sizeSearchBar.width,
                                                height: sizeSearchBar.height,
                                                child: Center(
                                                  child: Icon(ViIcons.search,
                                                    color: context.isDarkMode ? AppColors.gray400 : AppColors.gray500,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (val) {
                                                if(bloc.isAutocomplete){
                                                  bloc.add(SearchBaseList(val, key: options.searchKey));
                                                }else{
                                                  bloc.add(LocalSearchBaseList(val));
                                                }
                                              },
                                              onSubmitted: (val) {
                                                final newVal = val.trimLeft();
                                                if (newVal != val) {
                                                  bloc.textEditingSearchController.text = newVal;
                                                }
                                                if(bloc.isAutocomplete){
                                                  bloc.add(SearchBaseList(val.trim(), key: options.searchKey));
                                                }else{
                                                  bloc.add(LocalSearchBaseList(val.trim()));
                                                }
                                              },
                                              textInputAction: TextInputAction.search,
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                )
                              ),
                              controller: scrollController,
                              hasRefresh: false,
                              padding: const EdgeInsets.only(
                                  bottom: 10
                              ),
                              separatorBuilder:options.separatorBuilder ?? (context, index){
                                return const SizedBox.shrink();
                              },
                              detailBuilder: (context, item, isSelected){
                                if(firstActive?.key == bloc.getItemId(item)) {
                                  return SizedBox(
                                    key: key,
                                    child: itemWidget(
                                        context, item, isSelected ?? false),
                                  );
                                }else{
                                  return itemWidget(
                                      context, item, isSelected ?? false);
                                }
                              }
                            ).marginOnly(
                                bottom: (showDoneButton) ? 44 + (paddingBase * 2) : 0
                            ),
                            if(showDoneButton)Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Padding(
                                padding: EdgeInsets.all(paddingBase),
                                child: SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: BaseButton(onPressed: (){
                                    appNavigator.pop();
                                  }, child: Text('Xong'.lang())),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ).paddingOnly(
                    bottom: MediaQuery.of(context2).viewInsets.bottom
                );
              }
          ),
        );
      }
    ).then((res){
      if(context.mounted) {
        final bloc = context.read<FormSelectBloc>();
        if (bloc.changeAfterDone) {
          bloc.onValueChanged();
        }
        FocusScope.of(context).requestFocus(FocusNode());
        bloc.textEditingSearchController.clear();
        if(empty(bloc.state.keyword, true)){
          return;
        }
        if (bloc.isAutocomplete) {
          bloc.add(SearchBaseList('', key: options.searchKey));
        } else {
          bloc.add(LocalSearchBaseList(''));
        }
      }
    });
  }
  String? get hintText{
    if(options.hideHintText){
      return null;
    }
    return options.hintText ?? '-- ${"Chọn".lang()} --';
  }

  String? getValue(dynamic value, FormSelectBloc bloc){
    if((value == null || value.isEmpty || value.first == '')){
      return null;
    }
    if(bloc.isMulti){
      if(bloc.selectedIdsTitle.length > options.maxVisibleSelections){
        return
          "number_of_selections".lang(namedArgs: {"count": "${bloc.selectedIdsTitle.length}"},value: bloc.selectedIdsTitle.length);
      }
    }
    final selectedIdsTitleVal = bloc.selectedIdsTitle.where((title) =>
    title.toString().trim().isNotEmpty
    ).toList();

    return selectedIdsTitleVal.isNotEmpty ? selectedIdsTitleVal.join(', ') : '';
  }
}