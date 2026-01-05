import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class AppNotFoundPage extends StatelessWidget {
  final Map params;
  const AppNotFoundPage(this.params, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigator.canPop(context)?AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleMedium?.color,
      ):null,
      backgroundColor: Theme.of(context).cardColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NoData(
              icon: !empty(AppInfo.logo)?Center(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: globalContext.width * 2/3,
                  ),
                  child: Center(
                    child: ImageViewer(AppInfo.logo(context), fit: BoxFit.contain,),
                  ),
                ),
              ):const Text('404', style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w600
              ),),
              msg: params['message'],
            ),
          ),
          if(account.isLogin())TextButton(onPressed: (){
            account.logout();
          }, child: Text(
              "Đăng xuất".lang()
          )),
        ],
      ),
    );
  }
}
