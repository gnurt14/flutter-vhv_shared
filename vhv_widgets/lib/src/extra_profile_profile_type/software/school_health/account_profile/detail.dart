import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class SoftwareSchoolHealthAccountProfileDetail extends StatelessWidget {
  const SoftwareSchoolHealthAccountProfileDetail(this.params, {super.key});
  final Map params;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxContent(child: ListTile(
          contentPadding: EdgeInsets.all(paddingBase),
          minTileHeight: 0,
          leading: Avatar(
            params['fullName'] ?? '',
            image: params['image'] ?? '',
            width: 44,
          ),
          title: Text(params['fullName'] ?? ''),
          subtitle: Text(params['code'] ?? ''),
        )),
        columnSpacing,
        BoxContent(child: Padding(
          padding: EdgeInsets.all(contentPaddingBase),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin chung', style: AppTextStyles.title),
              h12,
              Divider(height: 1,),
              ItemBaseContent(
                items: [
                  if(!hasComponent('Group.Education.School.University') && !hasComponent('Group.Education.Academy'))...[
                    ContentLineInfo('Ngày sinh'.lang(), date(params['birthDate'])),
                    ContentLineInfo('Giới tính'.lang(), params['genderTitle']),
                    // ContentLineInfo('Nơi sinh'.lang(), params['birthPlace']),
                    ContentLineInfo('Quốc tịch'.lang(), params['nationality']),
                    ContentLineInfo('Điện thoai'.lang(), params['phone']),
                    ContentLineInfo('Email'.lang(), params['email']),
                  ],
                  if(!(!hasComponent('Group.Education.School.University') && !hasComponent('Group.Education.Academy')))...[
                    ContentLineInfo('Ngày sinh'.lang(), date(params['birthDate'])),
                    ContentLineInfo('Giới tính'.lang(), params['genderTitle']),
                    // ContentLineInfo('Nơi sinh'.lang(), params['birthPlace']),
                  ],
                  if(inArray(CSystem.componentCodes['Account.Teacher'], 'Account.Teacher'))...[
                    ContentLineInfo('Mã cán bộ'.lang(), params['code']),
                    ContentLineInfo('Trạng thái làm việc'.lang(), ''),
                    ContentLineInfo('Vị trí làm việc'.lang(), params['jobPosition']),
                    ContentLineInfo('Chức danh'.lang(), params['representativePosition']),
                    ContentLineInfo('Nơi cư trú'.lang(), params['address']),
                    ContentLineInfo('Tình trạng hôn nhân'.lang(), params['maritalStatus']),
                    ContentLineInfo('Số lượng con'.lang(), '${toList(params['childrenIds']).length}'),
                  ] else ...[
                    ContentLineInfo('Mã học sinh'.lang(), params['code']),
                    ContentLineInfo('Khối'.lang(), params['gradesTitle']),
                    ContentLineInfo('Lớp'.lang(), params['classroomIdTitle']),
                    ContentLineInfo('Trạng thái'.lang(), Align(
                      alignment: Alignment.centerRight,
                      child: AppStatus.success('Đang học'.lang()),
                    )),
                    ContentLineInfo('Địa chỉ cư trú'.lang(), params['address']),
                    // ContentLineInfo('Địa chỉ nơi tạm trú'.lang(), params['temporaryAddress']),
                    // ContentLineInfo('Nhóm máu'.lang(), params['bloodGroup']),
                  ]
                ],
                hasDivider: true,
              )
            ],
          ),
        )),
        if(!hasComponent('Group.Education.School.University') && !hasComponent('Group.Education.Academy'))...[
          columnSpacing,
          BoxContent(child: Padding(
            padding: EdgeInsets.all(contentPaddingBase),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thông tin gia đình', style: AppTextStyles.title),
                h12,
                Divider(height: 1,),
                ItemBaseContent(
                  items: [
                    ContentLineInfo('Họ và tên giám hộ'.lang(), params['protectorFullName']),
                    ContentLineInfo('Ngày sinh'.lang(), date(params['protectorBirthDate'])),
                    ContentLineInfo('Nghề nghiệp'.lang(), params['protectorJob']),
                    ContentLineInfo('Email'.lang(), params['protectorEmail']),
                    ContentLineInfo('Điện thoại'.lang(), params['protectorPhone']),
                  ],
                  hasDivider: true,
                ),
                Divider(height: 1,),
                fatherInfo(),
                // Divider(height: 1,),
                motherInfo(),
                if(empty(params['isPupil']) && !empty(params['childrens']))...[
                  Divider(height: 1,),
                  childrenInfo(),
                ]
              ],
            ),
          )),
          columnSpacing,
          BoxContent(child: Padding(
            padding: EdgeInsets.all(contentPaddingBase),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quá trình sinh trưởng', style: AppTextStyles.title),
                h12,
                const Divider(height: 1,),
                ItemBaseContent(
                  items: [
                    ContentLineInfo('Con thứ mấy'.lang(), params['childIndex']),
                    ContentLineInfo('Tổng số con trong gia đình'.lang(), params['totalChild']),
                    ContentLineInfo('Tuổi thai lúc sinh'.lang(), params['ageGestational']),
                    ContentLineInfo('Cân cặng lúc sinh'.lang(), params['weightBirth']),
                    ContentLineInfo('Cách sinh'.lang(), params['birthMethodTitle']),
                    ContentLineInfo('Dị tật bẩm sinh (nếu có)'.lang(), params['defectBirth']),
                    ContentLineInfo('Bệnh lý của mẹ trong thai kỳ'.lang(), params['maternalDiagnose']),
                    ContentLineInfo('Tiền sử gia đình (Bao gồm bố mẹ, anh chị em ruột)'.lang(), params['familyMedicalHistorysTitle']),
                    ContentLineInfo('Trẻ đã từng được chẩn đoán mắc các bệnh sau đây'.lang(), params['diseaseHistorysTitle']),
                  ],
                  hasDivider: true,
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }
  Widget childrenInfo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Danh sách các con'.lang(), style: AppTextStyles.bold,).paddingSymmetric(
            vertical: 10
        ),
        ...toList(params['childrens']).map((params){
          return Container(
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(color: AppColors.dividerColor)
                )
            ),
            padding: EdgeInsets.only(
                left: 10
            ),
            child: ItemBaseContent(
              items: [
                ContentLineInfo('Họ và tên'.lang(), Text(params['fullName'] ?? '', style: AppTextStyles.bold,)),
                ContentLineInfo('Ngày sinh'.lang(), date(params['birthDate'])),
                ContentLineInfo('Giới tính'.lang(), params['gender']),
                ContentLineInfo('Nơi học/ nơi làm việc'.lang(), params['placeWork']),
              ],
              hasDivider: true,
            ),
          );
        }),

      ],
    );
  }
  Widget motherInfo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Mẹ', style: AppTextStyles.bold,).paddingSymmetric(
            vertical: 10
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(color: AppColors.dividerColor)
              )
          ),
          padding: EdgeInsets.only(
              left: 10
          ),
          child: ItemBaseContent(
            items: [
              ContentLineInfo('Họ và tên mẹ', params['motherFullName']),
              ContentLineInfo('Ngày sinh', params['motherBirthDate']),
              ContentLineInfo('Nghề nghiệp', params['motherJob']),
              ContentLineInfo('Email', params['motherEmail']),
              ContentLineInfo('Điện thoại', params['motherPhone']),
            ],
            hasDivider: true,
          ),
        )
      ],
    );
  }
  Widget fatherInfo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Bố', style: AppTextStyles.bold,).paddingSymmetric(
            vertical: 10
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(color: AppColors.dividerColor)
              )
          ),
          padding: EdgeInsets.only(
              left: 10
          ),
          child: ItemBaseContent(
            items: [
              ContentLineInfo('Họ và tên bố', params['fatherFullName']),
              ContentLineInfo('Ngày sinh', params['fatherBirthDate']),
              ContentLineInfo('Nghề nghiệp', params['fatherJob']),
              ContentLineInfo('Email', params['fatherEmail']),
              ContentLineInfo('Điện thoại', params['fatherPhone']),
            ],
            hasDivider: true,
          ),
        ),
      ],
    );
  }
}
