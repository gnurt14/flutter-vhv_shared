import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalarySalaryDetailListOtherPayment extends StatelessWidget {
  const HRMSalarySalaryDetailListOtherPayment(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    return TableResponsive(items: toList(params).whereType<Map>().toList(),
        labels: [
          TableResponsiveData(label: 'STT'.lang(),
              alignment: Alignment.center,
              valueBuilder: (e) => '${e.key+1}'
          ),
          TableResponsiveData(label: 'Mã phụ cấp'.lang(),
              code: 'code'
          ),
          TableResponsiveData(label: 'Phụ cấp'.lang(), code: 'allowanceTitle'),
          TableResponsiveData(label: 'Phải đóng bảo hiểm'.lang(), valueBuilder: (e) => (!empty(e.value['hasInsurance']) ? 'Có' : 'Không').lang()),
          TableResponsiveData(label: 'Được miễn thuế'.lang(), valueBuilder: (e) => (!empty(e.value['notTax']) ? 'Có' : 'Không').lang()),
          TableResponsiveData(label: 'Giá trị'.lang(), valueBuilder: (e) => number(e.value['amount'], decimalDigits: 0))
        ]);
  }
}
