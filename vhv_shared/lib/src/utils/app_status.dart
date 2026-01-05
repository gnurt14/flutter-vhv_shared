import 'package:flutter/cupertino.dart';
import 'package:vhv_shared/src/extension.dart';
import 'package:vhv_shared/src/theme/app_colors.dart';
enum AppStatusType{expired, error, warning, success, information, other1, other2, custom}
enum AppStatusSize{normal, large}
class AppStatus extends StatelessWidget{
  final String label;
  final IconData? leading;
  final AppStatusType type;
  final AppStatusSize size;
  final Color? color;
  final Color? backgroundColor;
  
  bool get isLarge => size == AppStatusSize.large;
  bool get isCustom => type == AppStatusType.custom;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isCustom ? color?.withValues(alpha: 0.15)  : getBackground()),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: !isLarge ? 8 : 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(leading != null)Icon(leading,
            size: !isLarge ? 16 : 18,
            color: color ?? getColor(),
          ).marginOnly(
            right: 4
          ),
          Flexible(
            child: Text(label,
              style: TextStyle(
                color: color ?? getColor(),
                fontWeight: FontWeight.w500,
                fontSize: !isLarge ? 12 : null
              ),
            ),
          )
        ],
      ),
    );
  }
  Color? getColor(){
    switch(type){
      case AppStatusType.expired:
        return AppColors.gray700;
      case AppStatusType.error:
        return Color(0xffB32318);
      case AppStatusType.warning:
        return AppColors.orange700;
      case AppStatusType.success:
        return AppColors.green700;
      case AppStatusType.information:
        return AppColors.blue700;
      case AppStatusType.other1:
        return AppColors.violet700;
      case AppStatusType.other2:
        return AppColors.pink700;
      default:
        return null;
    }
  }
  Color? getBackground(){
    switch(type){
      case AppStatusType.expired:
        return AppColors.gray100;
      case AppStatusType.error:
        return AppColors.red100;
      case AppStatusType.warning:
        return AppColors.orange100;
      case AppStatusType.success:
        return AppColors.green100;
      case AppStatusType.information:
        return AppColors.blue100;
      case AppStatusType.other1:
        return AppColors.violet100;
      case AppStatusType.other2:
        return AppColors.pink100;
      default:
        return null;
    }
  }
  const AppStatus.expired(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.expired, backgroundColor = null, color = null;
  const AppStatus.error(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.error, backgroundColor = null, color = null;
  const AppStatus.warning(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.warning, backgroundColor = null, color = null;
  const AppStatus.success(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.success, backgroundColor = null, color = null;
  const AppStatus.information(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.information, backgroundColor = null, color = null;
  const AppStatus.other1(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.other1, backgroundColor = null, color = null;
  const AppStatus.other2(this.label, {super.key, this.leading, this.size = AppStatusSize.normal})
      : type = AppStatusType.other2, backgroundColor = null, color = null;
  const AppStatus.custom(this.label, {super.key, this.leading, this.size = AppStatusSize.normal,
    required Color this.color, this.backgroundColor})
      : type = AppStatusType.custom;

  factory AppStatus.expiredLarge(String label, {Key? key, IconData? leading}){
    return AppStatus.expired(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.errorLarge(String label, {Key? key, IconData? leading}){
    return AppStatus.error(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.warningLarge(String label, {Key? key, IconData? leading}){
    return AppStatus.warning(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.informationLarge(String label, {Key? key, IconData? leading}){
    return AppStatus.information(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.successLarge(String label, {Key? key, IconData? leading}){
    return AppStatus.success(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.other1Large(String label, {Key? key, IconData? leading}){
    return AppStatus.other1(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.other2Large(String label, {Key? key, IconData? leading}){
    return AppStatus.other2(label, leading: leading, key: key, size: AppStatusSize.large);
  }
  factory AppStatus.customLarge(String label, {
    required Color color,
    Color? backgroundColor,
    Key? key,
    IconData? leading
  }){
    return AppStatus.custom(label,
      leading: leading,
      key: key,
      color: color,
      backgroundColor: backgroundColor,
      size: AppStatusSize.large,
    );
  }


  factory AppStatus.status(String status, {required String label, bool isLarge = false}){
    if(status.contains('success')){
      return AppStatus.success(label, size: isLarge ? AppStatusSize.large : AppStatusSize.normal);
    }else if(status.contains('error')){
      return AppStatus.error(label, size: isLarge ? AppStatusSize.large : AppStatusSize.normal);
    }else if(status.contains('warning')) {
      return AppStatus.warning(label, size: isLarge ? AppStatusSize.large : AppStatusSize.normal);
    }else if(status.contains('information')) {
      return AppStatus.information(label, size: isLarge ? AppStatusSize.large : AppStatusSize.normal);
    }else if(status.contains('expired')) {
      return AppStatus.expired(label, size: isLarge ? AppStatusSize.large : AppStatusSize.normal);
    }
    return AppStatus.expired(label, size: isLarge ? AppStatusSize.large : AppStatusSize.normal);
  }
}