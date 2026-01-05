import 'package:flutter/material.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/software/school_health/account_profile/detail.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/software/school_health/account_profile/sh_insurance_log/detail.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class DynamicCodeGenerationDetail extends StatelessWidget {
  const DynamicCodeGenerationDetail(this.params, {super.key,
    this.ignoreTypes = const ['Columns', 'Rows'],
    required this.builder,
    required this.noData
  });
  final Map params;
  final List<String> ignoreTypes;
  List<Map> get items => (toList(params['formColumns']).whereType<Map>()).toList();
  final Widget Function(Widget child) builder;
  final Widget Function(Widget child) noData;

  @override
  Widget build(BuildContext context) {
    if(!empty(params['isCustomFormDetailLayout'])) {
      switch (params['formDetailLayout']) {
        case 'Software.School.Health.AccountProfile.detail':
          return builder(SoftwareSchoolHealthAccountProfileDetail(
              params));
        case 'Software.School.Health.AccountProfile.SHInsuranceLog.detail':
          return builder(SoftwareSchoolHealthAccountProfileSHInsuranceLogDetail(
              params));
        default:
          return Text(params['formDetailLayout']);
      }
    }


    bool isDisplay(Map e){
      if(!empty(e['displayCode']) && !empty(e['displayValue'], true)){
        return e['displayValue'] == params[e['displayCode']];
      }
      return e['code'] != e['title'];
    }
    dynamic getValue(Map e){
      dynamic finalValue;
      final reg = RegExp(r'([a-zA-Z0-9_]+)(\[([a-zA-Z0-9_]+)\])+');
      if(reg.hasMatch(e['code'])){
        final alls = RegExp(r'([a-zA-Z0-9_]+)').allMatches(e['code']);
        final keys = alls.map((e){
          return e.group(1);
        }).whereType<String>().toList();
        if(keys.length > 1) {
          Map value = params;
          for (String key in keys) {
            final isLast = keys.last == key;
            if(isLast){
              finalValue = '${value['$key-DisplayTitle'] ?? value[key] ?? ''}';
              break;
            }
            if (value[key] is Map){
              value = value[key];
            }else{
              finalValue = '';
              break;
            }
          }
        }
        return finalValue;
      }  else {
        finalValue = params['${e['code']}-DisplayTitle'] ?? params[e['code']] ?? '';
        if(e['type'] == 'Uploadify' && finalValue.toString().isImageFileName){
          return GestureDetector(
            onTap: () => openFile(finalValue),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200
              ),
              child: ImageViewer(finalValue),
            ),
          );
        }
        if (finalValue is List) {
          return finalValue.join(', ');
        } else {
          if(e['type'] == 'DatePicker') {
            finalValue = date(finalValue);
          }
          return '${finalValue ?? ''}';
        }
      }
    }

    final items = this.items.where((e) => !ignoreTypes.contains(e['type'])
        && isDisplay(e));

    if(items.isNotEmpty){
      return builder(BoxContent(
        padding: EdgeInsets.all(contentPaddingBase),
        child: SizedBox(
          width: double.infinity,
          child: ItemBaseContent.twoLines(
              items: items.map<ContentLineInfo>((e){
                  return ContentLineInfo('${e['title'] ?? ''}', getValue(e));
              }).toList()
          ),
        )
      ));
    }
    return noData(
      NoData()
    );
  }
}