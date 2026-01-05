import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalarySalaryDetailListAdvanceSalary extends StatelessWidget {
  const HRMSalarySalaryDetailListAdvanceSalary(this.params, {super.key});
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
              valueBuilder: (e) => date(e.value['receiptTime'], 'dd/MM/yyyy')
          ),
          TableResponsiveData(label: 'Nội dung'.lang(), code: 'title'),
          TableResponsiveData(label: 'Số tiền'.lang(), valueBuilder: (e) => number(e.value['totalAmount'], decimalDigits: 0)),
        ]);
  }
}
