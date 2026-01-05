import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalarySalaryDetailListWorkdayFeature extends StatelessWidget {
  const HRMSalarySalaryDetailListWorkdayFeature(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    return TableResponsive(items: toList(params).whereType<Map>().toList(), labels: [
      TableResponsiveData(label: 'STT'.lang(), code: '',
          alignment: Alignment.center,
          valueBuilder: (e) => '${e.key+1}'),
      TableResponsiveData(label: 'Ngày'.lang(), code: '',
          valueBuilder: (e) => '${date(e.value['time'])}${!empty(e.value['shiftTitle']) ? ' (${e.value['shiftTitle']})' : ''}'),
      TableResponsiveData(label: 'Loại'.lang(), code: '',
        valueBuilder: (e){
          return '${(!empty(e.value['featureTitle']) ? e.value['featureTitle'] : e.value['code']) ?? ''}'
              '${(!empty(e.value['checkInTime']) || !empty(e.value['checkOutTime']))
              ? '${date(e.value['checkInTime'], 'HH:mm')} - ${date(e.value['checkOutTime'], 'HH:mm')}' : ''}';
        }
      ),
      TableResponsiveData(label: 'Nội dung'.lang(), code: 'note'),
      TableResponsiveData(label: 'Đơn vị'.lang(), code: '',
        valueBuilder: (e){
          if(!empty(e.value['featureValueType'])) {
            switch(e.value['featureValueType']){
              case 'coefficient': return 'Ngày công'.lang();
              case 'money': return 'Tiền mặt'.lang();
            }
          }
          return '';
        }
      ),
      TableResponsiveData(label: 'Có lương'.lang(), code: '',
        valueBuilder: (e){
          return (!empty(e.value['isSalary']) ? 'Có' : 'Không').lang();
        }
      ),
      TableResponsiveData(label: 'Có sử dụng ngày phép'.lang(), code: '',
        valueBuilder: (e){
          return (!empty(e.value['isDayOff']) ? 'Có' : 'Không').lang();
        }
      ),
      TableResponsiveData(label: 'Hệ số ngày công'.lang(), code: '',
        valueBuilder: (e){
          return (!empty(e.value['coefficient']) ? number(e.value['coefficient'], decimalDigits: 2) : '');
        }
      ),
      TableResponsiveData(label: 'Giá trị'.lang(), code: '',
        valueBuilder: (e){
          return (!empty(e.value['featureValue']) ? number(e.value['featureValue'], decimalDigits: 0) : '0');
        }
      )
    ]);
  }
}
