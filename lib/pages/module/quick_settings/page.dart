import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ModuleQuickSettingsPage extends StatefulWidget {
  const ModuleQuickSettingsPage({
    super.key,
  });

  @override
  State<ModuleQuickSettingsPage> createState() =>
      _ModuleQuickSettingsPageState();
}

class _ModuleQuickSettingsPageState extends State<ModuleQuickSettingsPage> {
  late List<String> ids;
  @override
  void initState() {

    super.initState();
  }

  @override
  void didChangeDependencies() {
    ids = context.read<ModulesBloc>().state.quickAccessIds;
    super.didChangeDependencies();
  }

  void changedQuickAccess(Map e){
    final String id = e['id'];
    if(ids.contains(id)){
      ids.remove(id);
    }else{
      if(context.read<ModulesBloc>().maxQuickAccess <= ids.length){
        showMessage("Bạn chỉ có thể chọn tối đa {max} tính năng!".lang(namedArgs: {
          'max': '${context.read<ModulesBloc>().maxQuickAccess}'
        }), type: 'FAIL');
        return;
      }
      ids.add(id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModulesBloc, ModulesState>(
      builder: (context, state){
        return Scaffold(
          appBar: BaseAppBar(context: context, title: Text("Cài đặt truy cập nhanh".lang()),),
          body: ListView.separated(
            padding: const EdgeInsets.only(bottom: 10),
            itemBuilder: (_, index) {
              final item = state.originCategories.elementAt(index);
              return Padding(
                padding:
                EdgeInsets.all(paddingBase).copyWith(bottom: 7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!empty(item.title))
                      Text(
                        item.title ?? '',
                        style: AppTextStyles.title,
                      ).marginOnly(bottom: paddingBase),
                    if (!empty(item.items))
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: item.items.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8
                              ).copyWith(
                                right: 0
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: ImageViewer(
                                      urlConvert(e['logo'], true),
                                      notThumb: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(e['title']),
                                    )
                                  ),
                                  CupertinoSwitch(
                                    activeTrackColor: AppColors.primary,
                                    value: ids.contains(e['id']),
                                    onChanged: (val) {
                                      changedQuickAccess(e);
                                    }
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ).marginSymmetric(vertical: 5),
                      )
                  ],
                ),
              );
            },
            separatorBuilder: (_, _) {
              return const SizedBox(
                height: 0,
              );
            },
            itemCount: state.originCategories.length
          ),
          bottomNavigationBar: BottomNavigationBarBase.button(
            onPressed: state.hasSaveQuickAccess(ids) ? () {
              context.read<ModulesBloc>().add(SaveQuickAccessModules(ids));
            } : null,
            child: Text("Lưu lại".lang())
          )
        );
      }
    );
  }
}
