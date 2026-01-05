import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';

class BottomSheetMenu extends StatelessWidget {
  final Widget? child;
  final Widget? bottom;
  final dynamic title;
  final Widget? actionRight;
  final Widget? actionLeft;
  final BottomSheetType? type;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadiusGeometry? borderRadius;
  const BottomSheetMenu(
      {super.key,
      this.title,
      this.child,
      this.bottom,
      this.actionRight,
      this.actionLeft,
      this.type,
      this.backgroundColor,
      this.padding,
      this.borderRadius
      });
  @override
  Widget build(BuildContext context) {
    BottomSheetType sheetType = type??(checkType<BottomSheetType>(factories['bottomSheetType'])
        ??BottomSheetType.type1);
    return Container(
      constraints: BoxConstraints(
          maxHeight: globalContext.height - MediaQuery.of(context).padding.top - 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (sheetType == BottomSheetType.type1)
            GestureDetector(
              onTap: (){
                appNavigator.pop();
              },
              child: Container(
                height: 20,
                color: Colors.transparent,
                width: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  height: 6,
                  width: 70,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
            ),
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: borderRadius??const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  color: backgroundColor??Theme.of(context).cardColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (sheetType == BottomSheetType.type2)InkWell(
                      child: Container(
                        height: 5,
                        width: 50,
                        margin: const EdgeInsets.only(bottom: 5, top: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      onTap: () {
                        appNavigator.pop();
                      },
                    ),
                    if(title != null)Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1.0,
                              color: const Color(0xffF1F1F1).withValues(alpha: 0.5)),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          if(actionLeft != null)actionLeft!,
                          Expanded(child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Builder(
                              builder: (_){

                                return Align(
                                  alignment: getAlignment(),
                                  child: DefaultTextStyle(
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    child: title is Widget ? title : Text(
                                      '$title',
                                    ),
                                  ),
                                );
                              },
                            ),
                          )),
                          if(actionRight != null)LayoutBuilder(
                              builder: (context, con){
                                return actionRight!;
                              }
                          ),
                        ],
                      ),
                    ),
                    if(bottom == null)Flexible(
                      child: SingleChildScrollView(
                        padding: padding??EdgeInsets.only(
                            left: paddingBase,
                            right: paddingBase,
                            top: paddingBase + 5,
                            bottom: MediaQuery.of(context).viewPadding.bottom +
                                paddingBase),
                        child: child,
                      ),
                    ),
                    if(bottom != null)...[
                      Flexible(child: Padding(
                        padding: padding??EdgeInsets.only(
                            left: paddingBase,
                            right: paddingBase,
                            top: paddingBase ,
                            bottom: MediaQuery.of(context).viewPadding.bottom +
                                paddingBase),
                        child: child,
                      )),
                      bottom!
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment getAlignment() {
    if(actionLeft != null && actionRight != null){
      return Alignment.center;
    }else if(actionLeft != null){
      return Alignment.centerRight;
    }else if(actionRight != null){
      return Alignment.centerLeft;
    }else{
      return Alignment.center;
    }
  }
}
