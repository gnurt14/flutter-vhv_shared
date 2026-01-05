import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_advance_salary.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_allowance.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_bonus.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_deduct_tax.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_other_payment.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_salary_by_calendar.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/salary/detail/widgets/list_workday_feature.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalaryAccountDetailPage extends StatelessWidget {
  const HRMSalaryAccountDetailPage(this.params, {super.key, this.service});
  final Map params;
  final String? service;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HRMSalaryAccountDetailBloc(service ?? 'HRM.Salary.Account.Salary.select',
          queries: {
            'id': params['id']
          }
      ),
      child: Builder(builder: (context){
        return BaseDetailWidget<HRMSalaryAccountDetailBloc>(
          loading: Scaffold(
            appBar: BaseAppBar(context: context),
            body: const Loading(),
          ),
          builder: (context, state, params){
            Map bankInfo = checkType<Map>(params['bankInfo']) ?? {};
            Map salaryType = checkType<Map>(params['salaryType']) ?? {};
            Map extraParams = checkType<Map>(params['extraParams']) ?? {};
            Map values = checkType<Map>(params['values']) ?? {};
            return Scaffold(
              appBar: BaseAppBar(context: context,
                title: Text(params['title'] ?? ''),
              ),
              backgroundColor: Theme.of(context).cardColor,
              body: ListView(
                padding: basePadding,
                children: [
                  ItemBaseContent.wrap(
                      iconSize: 18,
                      labelSuffix: ':',
                      items: [
                        ContentLineInfo('Thời gian'.lang(), date(params['createdTime']), iconData: ViIcons.clock),
                        ContentLineInfo('Ngày công chuẩn'.lang(), values['NCC'], iconData: ViIcons.calendar),
                      ]
                  ),
                  h20,
                  PanelDefault(title: 'Thông tin cơ bản'.lang(),
                      // showBorder: true,
                      titlePadding: EdgeInsets.zero.copyWith(
                          bottom: 10
                      ),
                      contentPadding: EdgeInsets.zero,
                      hideDivider: true,
                      child: ItemBaseContent(
                          items: [
                            ContentLineInfo('Tên nhân viên'.lang(), params['accountFullName'] ?? ''),
                            ContentLineInfo('Đơn vị'.lang(), params['groupTitle'] ?? ''),
                            ContentLineInfo('Tiền lương thực nhận'.lang(), currency(params['totalAmount'])),
                            ContentLineInfo('Số tiền đã trả'.lang(), currency(params['totalPaid'])),
                            ContentLineInfo('Số nợ phải trả'.lang(), currency(params['totalDebt'])),
                            ContentLineInfo('Hình thức thanh toán'.lang(), (){
                              switch(params['paymentMethod']){
                                case 'transfer': return 'Chuyển khoản'.lang();
                              }
                              return 'Tiền mặt'.lang();
                            }),
                            if(params['paymentMethod'] == 'transfer' && bankInfo.isNotEmpty)...[
                              ContentLineInfo('Số tài khoản ngân hàng'.lang(), bankInfo['accountBank']),
                              ContentLineInfo('Tên chủ tài khoản'.lang(), bankInfo['accountBankTitle']),
                              ContentLineInfo('Ngân hàng'.lang(), bankInfo['bankTitle'] ?? params['bankInfoBankTitle']),
                              ContentLineInfo('Chi nhánh'.lang(), bankInfo['branchTitle']),
                            ]
                          ]
                      )
                  ),
                  if(salaryType.isNotEmpty && !empty(params['values']))Builder(
                    builder: (_){
                      final elements = (params['salaryType'] is Map ? toList(params['salaryType']['elements']) : []).whereType<Map>().toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          columnSpacing,
                          PanelDefault(title: 'Chi tiết lương thực nhận'.lang(),
                              titlePadding: EdgeInsets.zero.copyWith(
                                  bottom: 10
                              ),
                              contentPadding: EdgeInsets.zero,
                              hideDivider: true,
                              child: TableResponsive(items: elements, labels: [
                                TableResponsiveData(label: 'Tiêu đề'.lang(), code: 'title'),
                                TableResponsiveData(label: 'Công thức tính'.lang(), code: 'recipeTitle',
                                    width: 150
                                ),
                                TableResponsiveData(label: 'Giá trị'.lang(), code: '',
                                    alignment: Alignment.centerRight,
                                    valueBuilder: (e){
                                      if(!empty(e.value['code']) && isset(params['values'])){
                                        return number(params['values'][e.value['code']] ?? 0, decimalDigits: 0);
                                      }
                                      return '0';
                                    }
                                ),
                              ])
                          )
                        ],
                      );
                    },
                  ),
                  if(!empty(salaryType['customLayouts']))...toList(salaryType['customLayouts']).map((e){
                    final d = extraParams[e['code']];
                    final data = checkType<Map>(d is String ? json.decode(d) : d) ?? {};
                    if(data.isEmpty){
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        columnSpacing,
                        PanelDefault(title: e['title'] ?? '',
                          titlePadding: EdgeInsets.zero.copyWith(
                              bottom: 10
                          ),
                          contentPadding: EdgeInsets.zero,
                          hideDivider: true,
                          child: Builder(
                            builder: (_){
                              switch(e['layout']){
                                case 'HRM.Salary.Salary.Detail.listWorkdayFeature':
                                  return HRMSalarySalaryDetailListWorkdayFeature(data);
                                case 'HRM.Salary.Salary.Detail.listSalaryByCalendar':
                                  return HRMSalarySalaryDetailListSalaryByCalendar(data);
                                case 'HRM.Salary.Salary.Detail.listBonus':
                                  return HRMSalarySalaryDetailListBonus(data);
                                case 'HRM.Salary.Salary.Detail.listAllowance':
                                  return HRMSalarySalaryDetailListAllowance(data);
                                case 'HRM.Salary.Salary.Detail.listOtherPayment':
                                  return HRMSalarySalaryDetailListOtherPayment(data);
                                case 'HRM.Salary.Salary.Detail.listDeductTax':
                                  return HRMSalarySalaryDetailListDeductTax(data);
                                case 'HRM.Salary.Salary.Detail.listAdvanceSalary':
                                  return HRMSalarySalaryDetailListAdvanceSalary(data);
                              }
                              return const SizedBox.shrink();
                            },
                          )
                        )
                      ],
                    );
                  })
                ],
              ),
            );
          },
        );
      }),
    );

  }
}

class HRMSalaryAccountDetailBloc extends BaseDetailBloc<BaseDetailState>{
  HRMSalaryAccountDetailBloc(super.service, {super.queries}) : super();
}
