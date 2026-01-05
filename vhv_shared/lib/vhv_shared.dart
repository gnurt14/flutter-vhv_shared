library;
import 'package:vhv_shared/src/global.dart';


export 'src/path_provider/path_provider.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:equatable/equatable.dart';
export 'package:dotted_border/dotted_border.dart';
export 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

export 'package:responsive_builder/responsive_builder.dart' hide WidgetBuilder;
export 'package:loader_overlay/loader_overlay.dart';

export 'src/account_base.dart';
export 'src/global.dart';
export 'src/helper.dart';
export 'src/extension.dart';
export 'src/get_utils.dart';
export 'src/enum.dart';

export 'src/theme/app_colors.dart';
export 'src/theme/app_text_styles.dart';

export 'src/widgets/base_app_bar.dart';
export 'src/widgets/base_button.dart' show BaseButton;
export 'src/widgets/circle_button.dart';
export 'src/widgets/no_data.dart';
export 'src/widgets/loading.dart';
export 'src/widgets/no_result.dart';
export 'src/widgets/item_base_content.dart';
export 'src/widgets/item_menu_action.dart';

export 'src/icons/vi_icons.dart';

export 'src/services/device_service.dart';
export 'src/services/app_permissions.dart';
export 'src/services/vhv_form_validation.dart';
export 'src/services/app_snackbar.dart';
export 'src/services/app_dialog.dart';
export 'src/services/app_loading_manager.dart';

export 'src/utils/app_box_shadow.dart';
export 'src/utils/datetime_utils.dart';
export 'src/utils/device_type.dart';
export 'src/utils/app_status.dart';
export 'src/utils/countdown_timer.dart';

export 'src/regexs.dart';

export 'src/theme_extension.dart';

export 'src/input_borders/ifta_input_border.dart';

export 'src/services/application_state_notifier.dart';

export 'package:flutter_svg/flutter_svg.dart';
export 'package:bot_toast/bot_toast.dart';
export 'package:flutter_widget_from_html/flutter_widget_from_html.dart' hide ImageSource;
export 'package:collection/collection.dart';
export 'package:nested/nested.dart';
export 'package:easy_localization/easy_localization.dart' hide TextDirection, MapExtension;
export 'package:vhv_shared/src/services/trace_performance_base.dart';


class VHVShared{
  VHVShared._();
  static VHVShared? _instance;
  factory VHVShared(){
    _instance ??= VHVShared._();
    return _instance!;
  }
  Function(dynamic action)? _applicationControl;
  Function(String service, {Map? params})? _call;
  void initAction({
    Function(dynamic action)? applicationControl,
    Function(String service, {Map? params})? call,
  }){
    _call = call;
    if(applicationControl != null){
      if(_applicationControl == null){
        _applicationControl = applicationControl;
      }else{
        throw Exception('applicationControl đã được khởi tạo từ trước');
      }
    }
  }

  Future<void> applicationControl(dynamic action)async{
    if(action == 'LoginVerify') {
      account.needVerify(true);
    }
    await _applicationControl?.call(action);
  }

  Future<dynamic> callAPI(String service, {Map? params})async{
    return await _call?.call(service, params: params);
  }
}