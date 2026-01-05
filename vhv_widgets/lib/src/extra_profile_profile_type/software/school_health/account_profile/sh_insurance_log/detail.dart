import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class SoftwareSchoolHealthAccountProfileSHInsuranceLogDetail extends StatelessWidget {
  const SoftwareSchoolHealthAccountProfileSHInsuranceLogDetail(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start    ,
      children: [
        BoxContent(child: Padding(
          padding: EdgeInsets.all(contentPaddingBase),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin thẻ bảo hiểm y tế', style: AppTextStyles.title),
              h12,
              const Divider(height: 1,),
              ItemBaseContent(
                items: [
                  ContentLineInfo('Họ và tên', params['fullName']),
                  ContentLineInfo('Ngày sinh', date(params['birthDate'])),
                  ContentLineInfo('Giới tính', getGenderTitle(params['gender'])),
                  ContentLineInfo('Địa chỉ', params['address']),
                  if(!empty(params['hasInsurance']))...[
                    ContentLineInfo('Số thẻ', params['insuranceCode']),
                    ContentLineInfo('Nơi ĐKKCBBĐ', params['treatmentPlaceTitle']),
                    ContentLineInfo('Thời điểm đủ 5 năm liên tục', date(params['enoughTime'])),
                    ContentLineInfo('Hình thức tham gia', params['deploymentTypeTitle']),
                    ContentLineInfo('Quyền lợi', Row(
                      children: [
                        Spacer(),
                        HtmlView(params['interest'])
                      ],
                    )),
                  ],
                  if(empty(params['hasInsurance']))...[
                    ContentLineInfo('Số thẻ', !empty(params['insuranceCode']) ? params['insuranceCode'] : lang('Chưa tham gia')),
                  ]
                ],
                hasDivider: true,
              ),
            ],
          ),
        )),
      ],
    );
  }
  String getTitleDeploymentType(dynamic code){
    if(code == 1 || code == 'VOLUNTARY'){
      return 'Tự nguyện'.lang();
    }else if(code == 2 || code == 'UNDER_POLICY'){
      return 'Diện chính sách'.lang();
    }
    return '';
  }
}

