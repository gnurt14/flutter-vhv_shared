import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'detail/page.dart';

class HRMSalaryAccountList extends StatelessWidget {
  const HRMSalaryAccountList({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ExtraProfileProfileTypeListBloc>();
    return Material(
      elevation: 0,
      color: Theme.of(context).cardColor,
      child: BlocSelector<ExtraProfileProfileTypeListBloc, BaseListState<Map>, List<Map>>(
        selector: (state) => state.items.map((e) => e.value).toList(),
        builder: (context, items){
          if(items.isEmpty){
            return const NoData();
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(padding: basePadding,
                  child: TableResponsive(
                    labels: [
                      TableResponsiveData(
                          label: 'STT'.lang(),
                          alignment: Alignment.center,
                          code: '',
                          valueBuilder: (e) => '${e.key + 1}'
                      ),
                      TableResponsiveData(label: 'Trạng thái'.lang(), code: 'statusTitle'),
                      TableResponsiveData(label: 'Tiêu đề bảng lương'.lang(), code: 'title',
                      ),
                      TableResponsiveData(label: 'Tháng'.lang(), code: 'month'),
                      TableResponsiveData(label: 'Năm'.lang(), code: 'year'),
                      TableResponsiveData(label: 'Người tạo'.lang(), code: 'creatorAccountTitle'),
                      TableResponsiveData(label: 'Phòng ban'.lang(), code: 'groupTitle'),
                      TableResponsiveData(label: 'Thành tiền'.lang(),
                          code: '',
                          alignment: Alignment.centerRight,
                          valueBuilder: (e){
                            return currency(e.value['totalAmount']);
                          }
                      ),
                      TableResponsiveData(
                          label: 'Hành động'.lang(),
                          padding: EdgeInsets.zero,
                          code: '',
                          builder: (e){
                            return Center(
                              child: IconButton(
                                onPressed: (){
                                  appNavigator.showFullDialog(child: HRMSalaryAccountDetailPage({
                                    'id': e.value['id']
                                  },
                                    service: !empty(bloc.state.data['customService']) ? changeTail(bloc.state.data['customService'], 'select') : null,));
                                },
                                icon: const Icon(ViIcons.eye),
                              ),
                            );
                          }
                      ),
                    ],
                    items: items,
                  ),
                ),
                const AppPagination<ExtraProfileProfileTypeListBloc>.navigationButton(),
                h12
              ],
            ),
          );
        },
      ),
    );
  }
}




