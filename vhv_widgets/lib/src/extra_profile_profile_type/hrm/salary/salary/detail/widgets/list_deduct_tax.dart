import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class HRMSalarySalaryDetailListDeductTax extends StatelessWidget {
  const HRMSalarySalaryDetailListDeductTax(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    ///taxExemption Miễn thuế
    ///reduce Giảm trừ
    final taxExemption = params.entries.where((e) => e.value['deductionType'] == 'taxExemption').toList();
    final reduce = params.entries.where((e) => e.value['deductionType'] == 'reduce').toList();
    const labelStyle = TextStyle(
        fontWeight: FontWeight.w500
    );
    return TableResponsive(items: [{}],
      labels: [
        TableResponsiveData(
          label: 'Tên các khoản',
          valueBuilder: (e) => 'Số tiền'
        ),
        TableResponsiveData(
          label: '',
          padding: EdgeInsets.zero,
          labelBuilder: (){
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('Các khoản miễn thuế'.lang(), style: labelStyle,),
                  ),
                ),
                const Divider(height: 1,),
                IntrinsicHeight(
                  child: Row(
                    children: taxExemption.map<Widget>((e){
                      return SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(e.value['title'], style: labelStyle,),
                        ).paddingSymmetric(
                          horizontal: contentPaddingBase
                        ),
                      );
                    }).toList().insertBetween(const VerticalDivider(width: 1,)),
                  ),
                )
              ],
            );
          },
          alignment: Alignment.center,
          builder: (e){
            return IntrinsicHeight(
              child: Row(
                children: taxExemption.map<Widget>((e){
                  return SizedBox(
                    height: 40,
                    child: Center(
                      child: Stack(
                        children: [
                          Opacity(opacity: 0, child: Text(e.value['title'], style: labelStyle,)),
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Text(number(e.value['amount'], decimalDigits: 0),),
                          )
                        ],
                      ),
                    ).paddingSymmetric(
                        horizontal: contentPaddingBase
                    ),
                  );
                }).toList().insertBetween(const VerticalDivider(width: 1,)),
              ),
            );
          },
        ),
        TableResponsiveData(
          label: '',
          padding: EdgeInsets.zero,

          labelBuilder: (){
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('Các khoản giảm trừ'.lang(), style: labelStyle,),
                  ),
                ),
                const Divider(height: 1,),
                IntrinsicHeight(
                  child: Row(
                    children: reduce.map<Widget>((e){
                      return SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(e.value['title'], style: labelStyle,),
                        ).paddingSymmetric(
                            horizontal: contentPaddingBase
                        ),
                      );
                    }).toList().insertBetween(const VerticalDivider()),
                  ),
                )
              ],
            );
          },
          alignment: Alignment.center,
          builder: (e){
            return IntrinsicHeight(
              child: Row(
                children: reduce.map<Widget>((e){
                  return SizedBox(
                    height: 40,
                    child: Center(
                      child: Stack(
                        children: [
                          Opacity(opacity: 0, child: Text(e.value['title'], style: labelStyle,)),
                          Text(number(e.value['amount'], decimalDigits: 0),)
                        ],
                      ),
                    ).paddingSymmetric(
                        horizontal: contentPaddingBase
                    ),
                  );
                }).toList().insertBetween(const VerticalDivider()),
              ),
            );
          },
        ),
    ]);
  }
}
