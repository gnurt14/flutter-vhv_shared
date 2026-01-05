import 'package:vhv_core/pages/account/information/bloc.dart';
import 'package:vhv_core/vhv_core.dart';

@ignoreRouter
class AccountInformationPage extends StatelessWidget {
  const AccountInformationPage({super.key, this.hideAppBar = false, this.hideMenus = false});
  final bool hideAppBar;
  final bool hideMenus;

  String get title => 'Tài khoản'.lang();
  static String? redirect(BuildContext context, GoRouterState state) {
    if (!account.isLogin()) {
      return context.loginRouter;
    }
    return null;
  }
  Widget topRegion(BuildContext context){
    return const SizedBox.shrink();
  }
  Widget bottomRegion(BuildContext context){
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar ? null : BaseAppBar(context: context,
        title: Text(title),
      ),
      body: BlocProvider(
        create: (_) => AccountInformationBloc(),
        child: Builder(
          builder: (context){
            return ListView(
              padding: EdgeInsets.all(paddingBase),
              children: [
                BoxContent(
                  child: ListTile(
                    onTap: () {
                      appNavigator.pushNamed('/Account/Home');
                    },
                    contentPadding: EdgeInsets.all(paddingBase),
                    minTileHeight: 0,
                    leading: Avatar(
                      account.fullName,
                      image: account.image,
                      width: 44,
                    ),
                    title: Text(account.fullName),
                    subtitle: Text(account.code),
                    trailing: const Icon(ViIcons.chevron_right),
                  ),
                ),
                topRegion(context),
                if(!hideMenus)BlocBuilder<AccountInformationBloc, List<Map>>(builder: (context, menuItems) {
                  if (menuItems.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final updatedMenuItems = List<Map<String, dynamic>>.from(menuItems);

                  if (AppInfo.domain == 'https://tnn-svs-academy.coquan.vn' || AppInfo.domain == 'https://sinhvien.tnu.edu.vn') {
                    updatedMenuItems.add({
                      'id': 'update_information_history',
                      'title': 'Lịch sử cập nhật dữ liệu'.lang(),
                      'isMultiple': false,
                    });
                  }
                  return BoxContent(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: updatedMenuItems.map<Widget>((e) {
                            return actionItem(
                              padding: basePadding.copyWith(
                                top: 7,
                                bottom: 7
                              ),
                              onPressed: () {
                                if (e['id'] == 'update_information_history') {
                                  appNavigator.pushNamed(
                                    '/Account/Information/UpdateHistory'
                                  );
                                } else {
                                  appNavigator.pushNamed('/Account/Home', arguments: {
                                      'groupName': e['id'],
                                      'title': e['title'],
                                      'isMultiple': e['isMultiple']
                                    });
                                }
                                },
                              label: e['title'],
                              trailing: const Icon(ViIcons.chevron_right),
                            );
                          }).toList(),
                        ),
                      )
                  ).marginOnly(top: columnSpacing.height ?? 0);
                }),
                columnSpacing,
                bottomRegion(context),
                if(AppInfo.domain == 'https://sinhvien.tnu.edu.vn')...[
                  BoxContent(
                    child: actionItem(
                      onPressed: () {
                        appNavigator.pushNamed('/Account/ChangePassword');
                      },
                      iconData: ViIcons.key,
                      label: 'Đổi mật khẩu'.lang(),
                      forcegroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  h8,
                ],
                BoxContent(
                  child: actionItem(
                    onPressed: () {
                      account.logout();
                    },
                    iconData: ViIcons.log_in_circle,
                    label: 'Đăng xuất'.lang(),
                    forcegroundColor: const Color(0xffC2243E)
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
  Widget actionItem({
    Function()? onPressed,
    IconData? iconData,
    required String label,
    Widget? trailing,
    Color? forcegroundColor,
    EdgeInsets? padding
  }){
    return ListTile(
      onTap: onPressed,
      contentPadding: padding ?? basePadding,
      minTileHeight: 0,
      minLeadingWidth: 0,
      horizontalTitleGap: 20,
      trailing: trailing,
      leading: iconData != null ? SizedBox(
        width: 20,
        child: Icon(iconData, color: forcegroundColor ?? AppColors.primary),
      ) : null,
      title: Text(label,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: forcegroundColor
        ),
      ),
    );
  }
}