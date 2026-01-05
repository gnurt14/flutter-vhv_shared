import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_utils/vhv_utils.dart';

class InAppUpdate extends StatelessWidget {
  final Map info;

  const InAppUpdate(this.info, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text( "Cập nhật ứng dụng?".lang(), style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500
          )),
          const SizedBox(height: 15),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Đã có bản cập nhật mới! Phiên bản {newVersion} hiện đã sẵn sàng - phiên bản hiện tại {currentVersion}.".lang(namedArgs:{
                "newVersion":'${info['new']['version']}(${info['new']['buildNumber']})',
                "currentVersion":'${info['current']['version']}(${info['current']['buildNumber']})'
              }  ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14
                ),),
              const SizedBox(height: 10),
              Text("Bạn có muốn cập nhật luôn?".lang(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14
              ))
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                !empty(info['requiredUpdate'])?InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: exitApp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(lang('Thoát ứng dụng'.lang())),
                    )
                ):InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: (){
                      appNavigator.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(lang('Bỏ qua'.lang())),
                    )
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: Text('Cập nhật ngay'.lang()),
                  onPressed: (){
                    urlLaunch(info['link']);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
