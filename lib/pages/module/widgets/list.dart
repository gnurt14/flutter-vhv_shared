import 'package:vhv_core/vhv_core.dart';
import 'item.dart';
export 'item.dart';
export 'item_type2.dart';


class ModuleList extends StatefulWidget {
  const ModuleList({
    super.key,
    this.shrinkWrap = true,
    this.hideSearch = false,
    this.hideChangedUserType = false,
    this.physics,
    this.padding,
    this.header,
    this.searchEditingController,
    this.backgroundColor,
    this.itemsInRow = 3,
    this.itemBuilder,
    this.separatorBuilder
  });
  final bool shrinkWrap;
  final bool hideSearch;
  final bool hideChangedUserType;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget? header;
  final TextEditingController? searchEditingController;
  final Color? backgroundColor;
  final int itemsInRow;
  final Widget Function(BuildContext context, ModuleItem item)? itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  State<ModuleList> createState() => _ModuleListState();
}

class _ModuleListState extends State<ModuleList> {
  String keyword = '';
  late TextEditingController textEditingController;
  bool hasLoadData = false;
  @override
  void initState() {
    textEditingController = widget.searchEditingController ?? TextEditingController();
    textEditingController.addListener(listener);
    super.initState();
  }
  void listener(){
    if(mounted){
      setState(() {
        keyword = textEditingController.text;
      });
    }
  }
  @override
  void didChangeDependencies() {
    if(hasLoadData) {
      try {
        final bloc = context.read<ModulesBloc>();
        bloc.add(FetchDataModules());
      } catch (_) {}
    }else{
      Future.delayed(Duration(seconds: 1),(){
        if(mounted){
          hasLoadData = true;
        }
      });
    }
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    final sizeSearchBar = Size(context.appTheme?.searchBarListHeight ?? defaultSearchBarHeight, context.appTheme?.searchBarListHeight ?? defaultSearchBarHeight);
    return BlocBuilder<ModulesBloc, ModulesState>(
      builder: (context, state){
        if(state.status == ModulesStateStatus.fail){
          return NoData(
            msg: 'Không thể tải dữ liệu'.lang(),
          );
        }
        if(state.status != ModulesStateStatus.loaded){
          return Loading();
        }
        final items = state.categories.map((e){
          return e.copyWith(
            items: e.items.where((item)
            => convertUtf8ToLatin(item['title'].toString().toLowerCase())
            .contains(convertUtf8ToLatin(keyword.toString().toLowerCase()))).toList()
          );
        }).where((e) => e.items.isNotEmpty);
        final showChangedUserType = (!widget.hideChangedUserType && state.userTypes.isNotEmpty);
        final showSearch = !widget.hideSearch;
        return Ink(
          color: widget.backgroundColor,
          child: CustomScrollView(
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics ?? const NeverScrollableScrollPhysics(),
            slivers: [
              if(showChangedUserType || showSearch)SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: _MySliverPersistentHeaderDelegate(
                  child: Container(
                    color: widget.backgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(showSearch)Container(
                          padding: basePadding,
                          child: SearchBar(
                            controller: textEditingController,
                            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                            leading: SizedBox(
                              width: sizeSearchBar.width,
                              height: sizeSearchBar.height,
                              child: Center(
                                child: Icon(ViIcons.search,
                                  color: context.isDarkMode ? AppColors.gray400 : AppColors.gray500,
                                ),
                              ),
                            ),
                            trailing: [
                              Visibility(
                                visible: keyword != '',
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  style: IconButton.styleFrom(
                                    fixedSize: sizeSearchBar,
                                    minimumSize: sizeSearchBar,
                                    maximumSize: sizeSearchBar
                                  ),
                                  onPressed: (){
                                    textEditingController.text = '';
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: const Icon(ViIcons.x_small)
                                ),
                              )
                            ],
                            hintText: "Tìm kiếm".lang(),
                            onChanged: (e){

                            },
                          ),
                        ),
                        if(showChangedUserType)FormSelect.choice(
                          value: state.userTypeId,
                          items: { for (var v in state.userTypes.values) v['id'] : v['title'] },
                          onChanged: (val){
                            context.read<ModulesBloc>().add(UpdateUserTypeModules(val));
                          },
                        ).paddingOnly(
                            right: paddingBase,
                            left: paddingBase,
                            bottom: contentPaddingBase
                        )
                      ],
                    ),
                  ),
                  height: (showSearch ? (sizeSearchBar.height + (contentPaddingBase * 2)) : 0) + (showChangedUserType ? 60 : 0)
                ),
              ),
              if(items.isEmpty && state.status == ModulesStateStatus.loaded)const SliverFillRemaining(
                child: NoData(),
              ),
              if(widget.header != null) SliverToBoxAdapter(child: widget.header,),
              SliverToBoxAdapter(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                      bottom: contentPaddingBase,
                      top: !(showChangedUserType || showSearch) ? contentPaddingBase : 0
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index){
                    final item = items.elementAt(index);
                    if(widget.itemBuilder != null){
                      return widget.itemBuilder!(context, item);
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingBase
                      ),
                      child: BoxContent(
                        child: Padding(
                          padding: EdgeInsets.all(contentPaddingBase),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(!empty(item.title))Text(item.title ?? '',
                                style: AppTextStyles.title,
                              ).marginOnly(
                                  bottom: paddingBase
                              ),
                              if(!empty(item.items))Wrap(
                                spacing: 0,
                                runSpacing: 5,
                                children: item.items.map((e){
                                  return FractionallySizedBox(
                                    widthFactor: 1/widget.itemsInRow,
                                    child: ModuleItemWidget(e, isWrapIcon: false,),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        )
                      ),
                    );
                  },
                  separatorBuilder: widget.separatorBuilder
                      ?? (_, _) => columnSpacing,
                  itemCount: items.length
                ),
              )
            ],
          ),
        ).tapRemoveFocus(context);
      },
    );
  }
}
class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  _MySliverPersistentHeaderDelegate({required this.height, required this.child});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return child;
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}