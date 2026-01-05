import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ExtraProfileProfileTypeItemList extends StatelessWidget {
  const ExtraProfileProfileTypeItemList(this.item, {super.key, required this.params, this.actions = const []});
  final Map item;
  final Map params;
  final List<ItemMenuAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(contentPaddingBase),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemBaseContent(
            items: toList(params['columns']).whereType<Map>().map<ContentLineInfo>((e){
              return ContentLineInfo(e['title'] ?? '', getContent(e));
            }).toList(),
            hasDivider: true,
          ),
          if(actions.isNotEmpty)Wrap(
            children: actions.map((e){
              return IconButton(
                onPressed: e.onPressed,
                icon: Icon(e.iconData),
                style: IconButton.styleFrom(
                  backgroundColor: e.backgroundColor,
                  foregroundColor: e.foregroundColor
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
  dynamic getContent(Map e){
    final value = item['${e['code']}-DisplayTitle'] ?? item[e['code']];
    if(value != null){
      if(e['type'] == 'DatePicker'){
        return date(value);
      }
      if(e['type'] == 'Number'){
        return number(value);
      }
    }
    return value;
  }
}

// class ExtraProfileProfileTypeEditableItemList extends StatelessWidget {
//   const ExtraProfileProfileTypeEditableItemList(this.item, {super.key, required this.params,required this.actions});
//   final Map item;
//   final Map params;
//   final List<ItemMenuAction> actions;
//
//   @override
//   Widget build(BuildContext context) {
//     return ItemBase(
//       title: !(empty(item['fullName'])) ? Text(
//         item['fullName'],
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//       ) : null,
//       actions: actions,
//       content: ItemBaseContent(
//         space: 12,
//         items: toList(params['columns']).whereType<Map>()
//             .where((e) => e['code'] != 'fullName').map<ContentLineInfo>((e){
//           return ContentLineInfo(e['title'] ?? '', getContent(e));
//         }).toList(),
//         hasDivider: false,
//       ),
//     );
//   }
//   dynamic getContent(Map e){
//     final value = item['${e['code']}-DisplayTitle'] ?? item[e['code']];
//     if(value != null){
//       if(e['type'] == 'DatePicker'){
//         return date(value);
//       }
//       if(e['type'] == 'Number'){
//         return number(value);
//       }
//     }
//     return value;
//   }
// }