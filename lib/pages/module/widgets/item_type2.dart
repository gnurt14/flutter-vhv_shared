import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class ModuleItemWidgetType2 extends StatelessWidget {
  const ModuleItemWidgetType2(this.e, {super.key, this.iconBackgroundColor,
    this.crossAxisAlignment,
    this.padding,
    this.width,
    this.textAlign,
  });

  final Map e;
  final Color? iconBackgroundColor;
  final CrossAxisAlignment? crossAxisAlignment;
  final EdgeInsets? padding;
  final double? width;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final bloc =  context.read<ModulesBloc>();
    return BoxContent(
      child: InkWell(
        splashColor: Colors.transparent,
        borderRadius: baseBorderRadius,
        onTap: () {
          bloc.goToModule(e);
        },
        child: SizedBox(
          width: width ?? double.infinity,
          child: Padding(
            padding: padding ?? EdgeInsets.all(contentPaddingBase),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(9),
                  decoration:  BoxDecoration(
                      color: iconBackgroundColor ?? Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(52),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff101828).withValues(alpha: 0.2),
                            blurRadius: 3,
                            offset: Offset(0, 2)
                        )
                      ]
                  ),
                  child: Center(
                    child: ImageViewer(urlConvert(e['logo'], true), notThumb: true,),
                  ),
                ).marginOnly(
                    bottom: 10
                ),
                Text('${e['title'] ?? ''}',
                  textAlign: textAlign ?? TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
