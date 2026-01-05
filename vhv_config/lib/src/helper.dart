import 'package:vhv_shared/vhv_shared.dart';

Future<void> accountGetDataInit(Map data)async{
  await account.assign(data);
}