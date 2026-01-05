import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
import '../form/form_select/form_select.dart';

class _AppPaginationData{
  final bool hasNext;
  final bool hasPrev;
  final int maxPage;
  final int currentPage;
  final bool enabled;
  final bool isLoading;

  _AppPaginationData({
    required this.hasNext,
    required this.hasPrev,
    required this.maxPage,
    required this.currentPage,
    this.enabled = true,
    this.isLoading = false,
  });
}

class AppPagination<B extends BaseListBloc<BaseListState, Object>> extends StatelessWidget {
  final String type;
  final Function(bool isLoading)? onLoad;
   
  const AppPagination.minimal({super.key,
   this.onLoad})
      : type = 'minimal';
  
  const AppPagination.navigationButton({super.key, this.onLoad})
      : type = 'navigationButton';
  
  const AppPagination.loadMore({super.key, this.onLoad})
      : type = 'loadMore';
  
  const AppPagination.number({super.key, this.onLoad})
      : type = 'number';
  
  const AppPagination.dropdown({super.key, this.onLoad})
      : type = 'dropdown';
  
  bool get isMinimal => type == 'minimal';
  bool get isNavigationButton => type == 'navigationButton';
  bool get isLoadMore => type == 'loadMore';
  bool get isNumber => type == 'number';

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, BaseListState, _AppPaginationData>(
        selector: (state) => _AppPaginationData(
            hasNext: state.maxPage > 1 && state.pageNo < state.maxPage,
            hasPrev: state.maxPage > 1 && state.pageNo > 1,
            maxPage: state.maxPage,
            currentPage: state.pageNo,
            enabled: state.maxPage > 1,
            isLoading: state.isLoading || state.isLoadingMore
        ),
        builder: (context, data){
          if(!data.enabled){
            return const SizedBox.shrink();
          }
          switch(type){
            case 'minimal':
              return _minimal(context, data);
            case 'navigationButton':
              return _navigationButton(context, data);
            case 'loadMore':
              return _loadMore(context, data);
            case 'number':
              return _number(context, data);
            case 'dropdown':
              return _dropdown(context, data);
          }
          return const SizedBox.shrink();
        }
    );
  }
  Widget _navigationButton(BuildContext context, _AppPaginationData data){
    final bloc = context.read<B>();
    return Row(
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(
              right: paddingBase,
              left: paddingBase/2
            )
          ),
          onPressed: data.hasPrev ? (){
            bloc.add(PreviousPageBaseList(
              onLoad: onLoad
            ));
          } : null,
          label: Text('Trang trước'.lang()),
          icon: const Icon(ViIcons.chevron_left, size: 24,),
        ),
        const Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(
              left: paddingBase,
              right: paddingBase/2
            )
          ),
          onPressed: data.hasNext ? (){
            bloc.add(NextPageBaseList(
              onLoad: onLoad
            ));
          } : null,
          label: Text('Trang sau'.lang()),
          iconAlignment: IconAlignment.end,
          icon: const Icon(ViIcons.chevron_right, size: 24,),
        )
      ],
    );
  }
  Widget _minimal(BuildContext context, _AppPaginationData data){
    final bloc = context.read<B>();
    return Row(
      children: [
        IconButton(
          onPressed: data.hasPrev ? (){
            bloc.add(PreviousPageBaseList(
              onLoad: onLoad
            ));
          } : null,
          icon: const Icon(ViIcons.chevron_left, size: 24,)
        ),
        w12,
        IconButton(
            onPressed: data.hasNext ? (){
              bloc.add(NextPageBaseList(
                onLoad: onLoad
              ));
            } : null,
            icon: const Icon(ViIcons.chevron_right, size: 24,)
        ),
      ],
    );
  }
  Widget _loadMore(BuildContext context, _AppPaginationData data){
    final bloc = context.read<B>();
    if(data.isLoading || data.maxPage == data.currentPage){
      return const SizedBox.shrink();
    }
    return TextButton.icon(
      onPressed: data.hasNext ? (){
        bloc.add(LoadMoreBaseList());
      } : null,
      label: Text('Tải thêm'.lang()),
    );
  }
  Widget _number(BuildContext context, _AppPaginationData data){
    final bloc = context.read<B>();
    const sizeIcon = Size(32, 32);
    final buttonStyle = IconButton.styleFrom(
        fixedSize: sizeIcon,
        maximumSize: sizeIcon,
        minimumSize: sizeIcon,
        padding: EdgeInsets.zero
    );
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          IconButton(
            style: buttonStyle,
            onPressed: data.hasPrev && data.currentPage > 1 ? (){
              bloc.add(GoToPageBaseList(1, onLoad: onLoad));
            } : null,
            icon: const Icon(ViIcons.chevron_left_double, size: 26,),
          ),
          IconButton(
            style: buttonStyle,
            onPressed: data.hasPrev ? (){
              bloc.add(PreviousPageBaseList(onLoad: onLoad));
            } : null,
            icon: const Icon(ViIcons.chevron_left, size: 24,),
          ),
          Expanded(
            child: FittedBox(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if(data.currentPage > 1)...List.generate(data.currentPage - 1, (index){
                    return SizedBox(
                      width: 32,
                      child: IconButton.outlined(
                          style: buttonStyle.copyWith(
                            backgroundColor: WidgetStatePropertyAll(AppColors.cardColor),
                          ),
                          onPressed: (){
                            bloc.add(GoToPageBaseList(index + 1, onLoad: onLoad));
                          },
                          icon: Text('${index + 1}')
                      ),
                    );
                  }).reversed.take(2).toList().reversed,
                  SizedBox(
                    width: 32,
                    child: IgnorePointer(
                      ignoring: true,
                      child: IconButton(
                          style: buttonStyle.copyWith(
                            backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                            foregroundColor: WidgetStatePropertyAll(AppColors.white),
                          ),
                          onPressed: (){},
                          icon: Text('${data.currentPage}', style: TextStyle(
                              color: AppColors.onPrimary
                          ),)
                      ),
                    ),
                  ),
                  if(data.maxPage > data.currentPage)...List.generate(data.maxPage - data.currentPage, (index){
                    final i = data.currentPage + index + 1;
                    return SizedBox(
                      width: 32,
                      child: IconButton.outlined(
                          style: buttonStyle.copyWith(
                            backgroundColor: WidgetStatePropertyAll(AppColors.cardColor),
                          ),
                          onPressed: (){
                            bloc.add(GoToPageBaseList(i, onLoad: onLoad));
                          },
                          icon: Text('$i')
                      ),
                    );
                  }).take(2),
                ],
              ),
            ),
          ),
          IconButton(
            style: buttonStyle,
            onPressed: data.hasNext ? (){
              bloc.add(NextPageBaseList(
                onLoad: onLoad
              ));
            } : null,
            icon: const Icon(ViIcons.chevron_right, size: 24,),
          ),
          IconButton(
            style: buttonStyle,
            onPressed: data.hasNext && (data.maxPage - data.currentPage) > 0 ? (){
              bloc.add(GoToPageBaseList(data.maxPage, onLoad: onLoad));
            } : null,
            icon: const Icon(ViIcons.chevron_right_double, size: 26,),
          ),
        ],
      ).marginSymmetric(
        vertical: contentPaddingBase
      ),
    );
  }
  Widget _dropdown(BuildContext context, _AppPaginationData data){
    final bloc = context.read<B>();
    return IntrinsicWidth(
      child: FormSelect.dropdown(
        onChanged: (val){
          if(val != data.currentPage.toString()){
            bloc.add(GoToPageBaseList(parseInt(val), onLoad: onLoad));
          }
        },
        widgetBuilder: (label){
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 12
            ),
            child: Text.rich(
                TextSpan(
                    text: '',
                    children: [
                      TextSpan(text: 'Trang {}'.lang(args: [label]),
                          style: AppTextStyles.primary
                      ),
                      TextSpan(text: '/${data.maxPage}'),
                    ]
                )
            ),
          );
        },
        value: data.currentPage.toString(),
        items: {for(int i = 1; i <= data.maxPage; i++)'$i': '$i'},
      ),
    );
  }
}