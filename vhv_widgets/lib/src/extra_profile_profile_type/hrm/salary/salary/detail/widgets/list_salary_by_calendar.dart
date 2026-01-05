import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalarySalaryDetailListSalaryByCalendar extends StatelessWidget {
  const HRMSalarySalaryDetailListSalaryByCalendar(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    return TableResponsive(items: toList(params).whereType<Map>().toList(), labels: [
      TableResponsiveData(label: 'STT'.lang(), code: '',
          alignment: Alignment.center,
          valueBuilder: (e) => '${e.key+1}'),
      TableResponsiveData(label: 'Nội dung'.lang(), code: 'title'),
      TableResponsiveData(label: 'Ngày'.lang(), valueBuilder: (e) => date(e.value['startTime'])),
      TableResponsiveData(label: 'Thời gian'.lang(),
          valueBuilder: (e) => '${date(e.value['startTime'], 'HH:mm')} - ${date(e.value['endTime'], 'HH:mm')}'),
      TableResponsiveData(label: 'Ghi chú'.lang(), code: 'content'),

      TableResponsiveData(label: 'Giá trị'.lang(), code: 'bonusValueTitle')
    ]);
  }
}
