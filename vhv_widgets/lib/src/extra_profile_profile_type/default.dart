
import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'widgets/dynamic_code_generation_detail.dart';
import 'widgets/dynamic_code_generation_form_field.dart';
import 'widgets/item_list.dart';

class ExtraProfileProfileType<B extends ExtraProfileProfileTypeBloc> extends StatelessWidget {
  const ExtraProfileProfileType({super.key, this.hideAppBar = false});
  final bool hideAppBar;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<B>();
    return BlocBuilder<B, ExtraProfileProfileTypeState>(
      builder: (context, state){
        if(empty(state.service)){
          return Scaffold(
            appBar: hideAppBar ? null : BaseAppBar(context: context),
            body: const Loading(),
          );
        }
        List<Map> tabs = toList(state.extraData['tabs']).whereType<Map>().toList();
        final maxLength = ((context.width - ((context.theme.tabBarTheme.labelPadding?.horizontal ?? 30) * tabs.length)) / 100).floor() * 10;
        final tabTitles = tabs.map((e) => e['title'] ?? '').join('');
        final isScroll = tabTitles.length > maxLength;
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: hideAppBar ? null : BaseAppBar(
              context: context,
              title: ValueListenableBuilder<String>(
                valueListenable: context.read<B>().title,
                builder: (c, title, _){
                  return Text(title);
                }
              ),
              bottom: tabs.length > 1 ? TabBar(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingBase
                ),
                isScrollable: isScroll,
                tabAlignment: !isScroll ? null : TabAlignment.start,
                onTap: (index){
                  final item = tabs.elementAt(index);
                  context.read<B>().loadModule(
                      formId: item['formId'],
                      id: item['id'],
                      isMultiple: !empty(item['isMultiple'])
                  );

                },
                tabs: tabs.map((e){
                  return Tab(text: e['title'] ?? '',);
                }).toList(),
              ) : null,
            ),
            body: empty(state.queries) ? const Loading() : SizedBox(
              key: ValueKey('ExtraProfileProfileType-$B-${state.formId}'),
              child: state.isMultiple ? BlocProvider(
                create: (_) => ExtraProfileProfileTypeListBloc(state.service,
                  extraParams: state.queries,
                  options: {
                    'itemsPerPage': 20,
                    'pageNo': 1,
                    'type': 'Salary'
                  },
                  onLoaded: (res){
                    if(!empty(res['formTitle']) && empty(bloc.title.value)){
                      bloc.title.value = res['formTitle'];
                    }
                  }
                ),
                child: _ExtraProfileProfileTypeContentList<B>(
                  extraData: state.extraData,
                  formId: state.formId,
                ),
              ) : BlocProvider(
                create: (_) => ExtraProfileProfileTypeDetailBloc(state.service,
                  queries: state.queries,
                  onLoaded: (res){
                    if(!empty(res['formTitle']) && empty(bloc.title.value)){
                      bloc.title.value = res['formTitle'];
                    }
                  }
                ),
                child: _ExtraProfileProfileTypeContentDetail<B>(
                  extraData: state.extraData,
                  formId: state.formId,
                ),
              ),
            ),
          )
        );
      },
    );
  }
}

///Dạng chi tiết
class _ExtraProfileProfileTypeContentDetail<B extends ExtraProfileProfileTypeBloc> extends StatelessWidget{
  final Map<String, dynamic> extraData;
  final String? formId;
  const _ExtraProfileProfileTypeContentDetail({super.key,
    required this.extraData,
    this.formId,
  });
  @override
  Widget build(BuildContext context) {
    return BaseDetailWidget<ExtraProfileProfileTypeDetailBloc>(
      builder: (context, state, result){
        if(state.showLoading){
          return const Loading();
        }
        return DynamicCodeGenerationDetail(result,
          builder: (child){
            return SingleChildScrollView(
              padding: basePadding,
              child: child,
            );
          },
          noData: (child){
            return child;
          },
        );
      },
    );
  }
}
///Dạng danh sách
class _ExtraProfileProfileTypeContentList<B extends ExtraProfileProfileTypeBloc> extends StatelessWidget{
  final Map<String, dynamic> extraData;
  final String? formId;
  const _ExtraProfileProfileTypeContentList({super.key, required this.extraData, this.formId});
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<B>();
    return BlocSelector<ExtraProfileProfileTypeListBloc, BaseListState, String?>(
      selector: (state) => state.isLoaded ? (state.data['customLayout'] ?? state.data['listLayout'] ?? '') : null,
      builder: (context, customLayout){
        if(customLayout == null){
          return const Loading();
        }
        if(!empty(customLayout)) {
          final child = bloc.customLayoutBuilder.call(customLayout);
          if(child != null){
            return child;
          }
        }


        final extraBloc = context.read<ExtraProfileProfileTypeListBloc>();
        return Scaffold(
          body: BaseListView<ExtraProfileProfileTypeListBloc, BaseListState<Map>, Map>(
            detailBuilder: (context, item, isSelected){

              final data = extraBloc.state.data;
              return BoxContent(
                child:
                ExtraProfileProfileTypeItemList(
                  item,
                  params: context.read<ExtraProfileProfileTypeListBloc>().state.data,
                  actions: empty(data['hideAction']) ? [
                    if(!empty(data['editable']) || !empty(item['editable']))ItemMenuAction(
                      label: 'Chỉnh sửa'.lang(),
                      iconData: ViIcons.pencil,
                      onPressed: () async{
                        final bool result = await appNavigator.push(Edit({...item, 'customerId': extraBloc.state.queryParams['customerId']},
                            formId: formId ?? data['formId'],
                            service: changeTail(extraBloc.state.service, 'select'),
                            noDraft: extraBloc.state.options['noDraft'] ?? ''
                        ))??false;
                        if(result == true && context.mounted) {
                          extraBloc.add(RefreshBaseList());
                        }
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    if(!empty(data['isMultiple']))ItemMenuAction(
                      label: 'Xóa'.lang(),
                      iconData: ViIcons.trash_can,
                      backgroundColor: AppColors.delete,
                      foregroundColor: Colors.white,
                      onPressed: () {
                         AppDialogs.delete(
                          context: context,
                          service: changeTail(extraBloc.state.service, 'delete'),
                          params: {'id': item['id'], 'formId': bloc.state.formId},
                          title: 'Xoá {}'.lang(
                              args: ['${data['formTitle'] ?? ''}'.toLowerCase()]
                          ),
                          message:
                          'Bạn có chắc chắn muốn xóa {}'.lang(
                              args: ['${data['formTitle'] ?? ''}'.toLowerCase()]
                          ),
                          onSuccess: (response) {
                            appNavigator.pop();
                            extraBloc.add(RefreshBaseList());
                          },
                          onCancel: () {
                            appNavigator.pop();
                          },
                        );
                      },
                    ),
                  ] : <ItemMenuAction>[],
                ),
              );
            },
          ),
          floatingActionButton: !empty(extraBloc.state.data['editable'])
              && extraBloc.state.data['type'] == 'CustomerProfile.Contact'
              ? FloatingActionButton(onPressed: () async {
            final res = await appNavigator.push(Edit( {'customerId': bloc.state.id},
                formId: formId ?? extraBloc.state.data['formId'],
                service: changeTail(extraBloc.state.service, 'select'),
                noDraft: extraBloc.state.options['noDraft'] ?? ''
            ));
            if(res == true && context.mounted) {
              extraBloc.add(RefreshBaseList());
            }
          },
            child: Icon(ViIcons.plus_large),
          ) : null,
        );
      }
    );
  }
}

class Edit extends StatelessWidget {
  const Edit(this.params, {super.key, this.formId = '', this.service = '', this.noDraft = ''});
  final Map params;
  final String formId;
  final String service;
  final String noDraft;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExtraProfileProfileTypeEditBloc(
        params,
        selectService: service,
        formId: formId,
      ),
      child: BaseFormWidget<ExtraProfileProfileTypeEditBloc, BaseFormState>(
        builder: (context, state, wrapper){
          if(state.showLoading){
            return Material(
              child: Loading(),
            );
          }
          return DynamicCodeGenerationFormField(state.data,
            wrapper: wrapper,
            builder: (child){
              return Scaffold(
                backgroundColor: Theme.of(context).cardColor,
                appBar: BaseAppBar(context: context,
                  title: Text('${!empty(params['id']) ? 'Chỉnh sửa' : 'Thêm mới'} ${'${state.data['formTitle'] ?? ''}'.toLowerCase()}'),
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: child,
                ),
                bottomNavigationBar: BaseFormWidget.saveAndNext<ExtraProfileProfileTypeEditBloc, BaseFormState>(context),
              );
            },
            noData: (child){
              return child;
            },
          );
        }
      ),
    );
  }
}

