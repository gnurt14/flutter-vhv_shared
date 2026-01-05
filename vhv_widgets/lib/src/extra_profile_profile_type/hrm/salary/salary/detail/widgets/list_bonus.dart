import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalarySalaryDetailListBonus extends StatelessWidget {
  const HRMSalarySalaryDetailListBonus(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    return TableResponsive(items: toList(params).whereType<Map>().toList(),
      labels: [
      TableResponsiveData(label: 'STT'.lang(),
        alignment: Alignment.center,
        valueBuilder: (e) => '${e.key+1}'
      ),
      TableResponsiveData(label: 'Ngày'.lang(),
          valueBuilder: (e) => date(e.value['bonusTime'], 'dd/MM/yyyy HH:mm')
      ),
      TableResponsiveData(label: 'Loại'.lang(), code: 'bonusTypeTitle'),
      TableResponsiveData(label: 'Giá trị'.lang(), valueBuilder: (e) => number(e.value['value'], decimalDigits: 0)),
      TableResponsiveData(label: 'Đơn vị'.lang(), code: 'formTypeValueTitle'),
    ]);
  }
}
