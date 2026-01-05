import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class ModuleItemWidget extends StatelessWidget {
  const ModuleItemWidget(this.e, {super.key, this.isWrapIcon = true});

  final Map e;
  final bool isWrapIcon;

  @override
  Widget build(BuildContext context) {
    final bloc =  context.read<ModulesBloc>();
    return InkWell(
      splashColor: Colors.transparent,
      borderRadius: baseBorderRadius,
      onTap: () {
        bloc.goToModule(e);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(7),
              decoration: isWrapIcon ? BoxDecoration(
                  color: const Color(0xffF5FAFF),
                  borderRadius: BorderRadius.circular(12)
              ) : null,
              child: Center(
                child: ImageViewer(urlConvert(e['logo'], true), notThumb: true,),
              ),
            ).marginOnly(
                bottom: 10
            ),
            Text('${e['title'] ?? ''}',
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
