part of 'search_bar_base.dart';
enum _SearchBarWidgetType { basic, icon }

class SearchBarWidget<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object> extends StatefulWidget {
  const SearchBarWidget({super.key,
    required this.option,
    this.enabled = true,
    this.badgeThemeData,
  })
      : _type = _SearchBarWidgetType.basic;
  final SearchBarOption<B, S, T> option;
  final bool enabled;
  final _SearchBarWidgetType _type;
  final BadgeThemeData? badgeThemeData;

  const SearchBarWidget.icon({
    super.key,
    required this.option,
    this.enabled = true,
    this.badgeThemeData
  }) : _type = _SearchBarWidgetType.icon;

  @override
  State<SearchBarWidget<B, S, T>> createState() => _SearchBarWidgetState<B, S, T>();
}

class _SearchBarWidgetState<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object>
    extends State<SearchBarWidget<B, S, T>> {
  InputBorder get border => InputBorder.none;

  String get searchKey => widget.option.keySearch ?? 'filters[suggestTitle]';
  late TextEditingController textEditingController;
  late ValueNotifier<String> textValue;

  late Map<String, dynamic> filters;
  String? orderBy;
  bool loaded = false;
  late List<String> counterKeys;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() {
          loaded = true;
        });
      }
    });

    super.initState();
  }


  @override
  void didChangeDependencies() {
    counterKeys = List<String>.from(widget.option.counterKeys);
    if (counterKeys.isEmpty) {
      final bloc = context.read<B>();
      if (bloc.counterKeys != null) {
        counterKeys.addAll(bloc.counterKeys ?? []);
      }
    }
    filters = <String, dynamic>{};
    textEditingController = TextEditingController()
      ..addListener(listen);
    textValue = ValueNotifier<String>(textEditingController.text);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    textValue.dispose();
    super.dispose();
  }

  void listen() {
    if (mounted) {
      textValue.value = textEditingController.text;
    }
  }

  void onApply(BuildContext context, S state, Map<String, dynamic> filters) {
    try {
      appNavigator.pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
    final stateFilters = Map<String, dynamic>.from(state.filters);
    final otherFilters = Map<String, dynamic>.fromEntries(stateFilters.entries.where((k) => !counterKeys.contains(k.key)));
    final newFilters = Map<String, dynamic>.fromEntries(filters.entries.where((k) => counterKeys.contains(k.key)));
    final equals = const DeepCollectionEquality().equals;
    final finalFilters = <String, dynamic>{...otherFilters, ...newFilters};
    if (!equals(finalFilters, state.filters)) {
      context.read<B>().add(FilterBaseList(finalFilters, orderBy: orderBy, overwrite: true));
      widget.option.onPrepareFilterSearchBar?.call();
    }
  }

  void Function(void Function())? setStateFilterList;

  void onCancel(BuildContext context, S state) {
    if (true) {
      context.read<B>().add(ResetFilterBaseList(except: [searchKey], onResult: (filters) {
        if (mounted) {
          setStateFilterList?.call(() {
            filters.clear();
            this.filters.clear();
            this.filters.addAll(filters);
          });
        }
      }));
    }
    widget.option.onResetFilterSearchBar?.call();
  }

  void onChanged<D extends Object?>(String k, D? v) {
    if (k == 'orderBy' && v is String) {
      orderBy = v;
    } else if (k != 'orderBy') {
      filters.addAll(<String, dynamic>{k: v});
    }
  }

  Size get iconSize => Size(defaultSearchBarHeight, defaultSearchBarHeight);

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return IgnorePointer(
        ignoring: true,
        child: placeholder(context),
      );
    }
    final bloc = context.read<B>();
    return BlocSelector<B, S, SearchBarData>(
        selector: (state) {
          final data = SearchBarData(
              showExtra: true,
              showMultiActions: widget.option.multiActionBuilder != null && state.selectedIds != null,
              hintText: widget.option.hintText ?? "Tìm kiếm".lang(),
              keyword: widget.option.useLocalSearch ? (state.keyword ?? '') : (bloc.getSearchKeyword(searchKey) ?? ''),
              showActionLeft: true,
              showActionRight: true,
              enabled: !state.isAccessDenied
          );
          if (widget.option.customSearchBar != null) {
            return widget.option.customSearchBar!(state, data);
          }
          return data;
        },
        builder: (context, data) {
          final state = context
              .read<B>()
              .state;
          if (widget.option.customSearchBar != null) {
            textEditingController.text = data.keyword;
          } else {
            if (widget.option.useLocalSearch && textEditingController.text != (state.keyword ?? '')) {
              textEditingController.text = state.keyword ?? '';
            } else if ((bloc.getSearchKeyword(searchKey) ?? '') != textEditingController.text) {
              textEditingController.text = bloc.getSearchKeyword(searchKey) ?? '';
            }
          }
          final Widget? iconFilter = ((widget.option.extraBuilder != null || widget.option.extraFilters != null)
              && data.showExtra) ? BlocSelector<B, S, Map<String, dynamic>>(
            selector: (state) => state.filters,
            builder: (context, newFilters) {
              return Row(
                children: [
                  IconButton(
                      key: widget.option.extraButtonKey,
                      style: IconButton.styleFrom(
                          fixedSize: iconSize,
                          minimumSize: iconSize,
                          maximumSize: iconSize,
                          padding: EdgeInsets.zero
                      ),
                      onPressed: widget.enabled ? () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        filters.clear();
                        filters.addAll(Map<String, dynamic>.from(newFilters));
                        orderBy = state.options['orderBy'];
                        if (widget.option.filtersViewType == FiltersViewType.page) {
                          openFullFilters(context);
                        } else {
                          openBottomSheetFilters(context);
                        }
                      } : null,
                      icon: Builder(builder: (context) {
                        final counter = widget.option.customCounter != null ? widget.option.customCounter!(
                            newFilters, counterKeys)
                            : (counterKeys.isNotEmpty ? newFilters.keys
                            .where((k) =>
                        counterKeys.contains(k) && !empty(newFilters[k], true))
                            .length
                            : 0);
                        return Badge(
                          isLabelVisible: counter > 0,
                          label: Text('$counter'),
                          backgroundColor: widget.badgeThemeData?.backgroundColor
                              ?? Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                          textColor: widget.badgeThemeData?.textColor,
                          child: !empty(widget.option.iconFilter)
                              ? widget.option.iconFilter
                              : Icon(ViIcons.settings_line),
                        );
                      })
                  ),
                  if(!empty(widget.option.extraWidgetFilter))
                    Container(child: widget.option.extraWidgetFilter),
                ],
              );
            },
          ) : null;

          if (!data.enabled) {
            return const SizedBox.shrink();
          }
          if (widget._type == _SearchBarWidgetType.icon) {
            return iconFilter ?? const SizedBox.shrink();
          }

          return Container(
            padding: widget.option.padding ?? basePadding,
            width: double.infinity,
            color: widget.option.backgroundColor ?? Theme
                .of(context)
                .scaffoldBackgroundColor,
            child: data.showMultiActions ?
            widget.option.multiActionBuilder!(context)
                : Row(
              children: [
                if (widget.option.actionLeft != null && data.showActionLeft) widget.option.actionLeft!,
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: context.appTheme?.searchBarListHeight ?? context.theme.searchBarTheme.constraints?.minHeight,
                    child: widget.option.primaryBuilder != null
                        ? widget.option.primaryBuilder!(context, iconFilter)
                        : SearchBar(
                      key: widget.option.searchBarKey,
                      enabled: widget.enabled,
                      focusNode: widget.option.searchBoxFocusNode,
                      controller: textEditingController,
                      side: WidgetStateProperty.all(widget.option.borderSide),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      backgroundColor:
                      (widget.option.boxSearchColor != null) ? WidgetStateProperty.all(widget.option.boxSearchColor) : null,
                      leading: SizedBox(
                        width: iconSize.width,
                        height: iconSize.height,
                        child: Center(
                          child: Icon(ViIcons.search,
                            color: context.isDarkMode ? AppColors.gray400 : AppColors.gray500,
                          ),
                        ),
                      ),
                      hintText: data.hintText,
                      trailing: [
                        ValueListenableBuilder<String>(
                            valueListenable: textValue,
                            builder: (context, value, child) {
                              if (value.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                width: defaultSearchBarHeight,
                                height: defaultSearchBarHeight,
                                child: IconButton(
                                    style: IconButton.styleFrom(
                                        fixedSize: iconSize,
                                        minimumSize: iconSize,
                                        padding: EdgeInsets.zero
                                    ),
                                    onPressed: () {
                                      textEditingController.text = '';
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      if (widget.option.useLocalSearch) {
                                        context.read<B>().add(LocalSearchBaseList('', searchKey));
                                      } else {
                                        context.read<B>().add(SearchBaseList('', key: searchKey,
                                            delayTime: Duration.zero));
                                      }

                                      if (!empty(widget.option.onAfterFunctionClear)) {
                                        widget.option.onAfterFunctionClear!.call();
                                      }
                                    },
                                    icon: const Icon(ViIcons.x_circle)
                                ),
                              );
                            }
                        ),
                        if(!empty(widget.option.extraWidget))
                          Container(child: widget.option.extraWidget),
                        if (iconFilter != null
                            && widget.option.actionType == SearchBarActionType.type1)iconFilter
                      ],
                      onChanged: (val) {
                        if (widget.option.useLocalSearch) {
                          context.read<B>().add(LocalSearchBaseList(val, searchKey));
                        } else {
                          context.read<B>().add(SearchBaseList(val, key: searchKey));
                        }
                      },
                      onSubmitted: (val) {
                        if (widget.option.useLocalSearch) {
                          context.read<B>().add(LocalSearchBaseList(val.trim(), searchKey));
                        } else {
                          context.read<B>().add(SearchBaseList(val.trim(), key: searchKey, delayTime: Duration.zero));
                        }
                      },
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                if (iconFilter != null
                    && widget.option.actionType == SearchBarActionType.type2)BoxContent(
                  margin: EdgeInsets.only(
                      left: contentPaddingBase
                  ),
                  child: iconFilter,
                ),
                if (widget.option.actionRight != null && data.showActionRight) widget.option.actionRight!,
              ],
            ),
          );
        }
    );
  }

  Widget placeholder(BuildContext context) {
    final Widget? iconFilter = ((widget.option.extraBuilder != null || widget.option.extraFilters != null))
        ? Row(
      children: [
        IconButton(
            key: widget.option.extraButtonKey,
            style: IconButton.styleFrom(
                fixedSize: iconSize,
                minimumSize: iconSize,
                maximumSize: iconSize,
                padding: EdgeInsets.zero
            ),
            onPressed: widget.enabled ? () {} : null,
            icon: Builder(builder: (context) {
              return Badge(
                isLabelVisible: false,
                label: Text('0'),
                backgroundColor: widget.badgeThemeData?.backgroundColor
                    ?? Theme
                        .of(context)
                        .colorScheme
                        .primary,
                textColor: widget.badgeThemeData?.textColor,
                child: !empty(widget.option.iconFilter)
                    ? widget.option.iconFilter
                    : Icon(ViIcons.settings_line),
              );
            })
        ),
        if(!empty(widget.option.extraWidgetFilter))
          Container(child: widget.option.extraWidgetFilter),
      ],
    ) : null;
    if (widget._type == _SearchBarWidgetType.icon) {
      return iconFilter ?? const SizedBox.shrink();
    }
    return Container(
      padding: widget.option.padding ?? basePadding,
      width: double.infinity,
      color: widget.option.backgroundColor ?? Theme
          .of(context)
          .scaffoldBackgroundColor,
      child: Row(
        children: [
          if (widget.option.actionLeft != null) widget.option.actionLeft!,
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: context.appTheme?.searchBarListHeight ?? context.theme.searchBarTheme.constraints?.minHeight,
              child: widget.option.primaryBuilder != null ? widget.option.primaryBuilder!(context, iconFilter) : SearchBar(
                key: widget.option.searchBarKey,
                enabled: true,
                side: WidgetStateProperty.all(widget.option.borderSide),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                backgroundColor:
                (widget.option.boxSearchColor != null) ? WidgetStateProperty.all(widget.option.boxSearchColor) : null,
                leading: SizedBox(
                  width: iconSize.width,
                  height: iconSize.height,
                  child: Center(
                    child: Icon(ViIcons.search,
                      color: context.isDarkMode ? AppColors.gray400 : AppColors.gray500,
                    ),
                  ),
                ),
                hintText: widget.option.hintText ?? "Tìm kiếm".lang(),
                trailing: [
                  if(!empty(widget.option.extraWidget))
                    Container(child: widget.option.extraWidget),
                  if (iconFilter != null
                      && widget.option.actionType == SearchBarActionType.type1)iconFilter
                ],
              ),
            ),
          ),
          if (iconFilter != null
              && widget.option.actionType == SearchBarActionType.type2)BoxContent(
            margin: EdgeInsets.only(
                left: contentPaddingBase
            ),
            child: iconFilter,
          ),
          if (widget.option.actionRight != null) widget.option.actionRight!,
        ],
      ),
    );
  }

  Future<void> openFullFilters(BuildContext context) async {
    openBottomSheetFilters(context);
  }

  dynamic getFilter(String key) {
    final filters = <String, dynamic>{
      ...this.filters,
      if(orderBy != null)'orderBy': orderBy
    };
    if (key != 'orderBy' && !counterKeys.contains(key)) {
      counterKeys.add(key);
    }
    context
        .read<B>()
        .counterKeys = counterKeys;
    return filters[key];
  }

  Future<void> openBottomSheetFilters(BuildContext context) async {
    final bloc = context.read<B>();
    final state = bloc.state;
    await AppBottomSheets().show(
        key: widget.option.extraFilterKey,
        context: context,
        title: lang('Bộ lọc'),
        child: BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (c, setState) {
              setStateFilterList = setState;
              return widget.option.extraFilters != null ? widget.option.extraFilters!(getFilter, <D>(String k, D? v) {
                onChanged<D>(k, v);
              }) : widget.option.extraBuilder!(<String, dynamic>{
                ...filters,
                if(orderBy != null)'orderBy': orderBy
              }, <D>(String k, D? v) {
                onChanged<D>(k, v);
              });
            },
          ),
        ),
        bottom: MultiActionsBottom(
          actions: [
            ItemMenuAction(label: 'Áp dụng'.lang(), iconData: Icons.save, onPressed: () {
              onApply(context, state, filters);
            }),
            ItemMenuAction(label: 'Đặt lại'.lang(), iconData: Icons.refresh, onPressed: () {
              onCancel(context, state);
            }),
          ],
        )
    );
    setStateFilterList = null;
  }
}