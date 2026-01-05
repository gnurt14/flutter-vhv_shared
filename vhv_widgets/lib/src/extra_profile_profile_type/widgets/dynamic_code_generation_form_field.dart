import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class DynamicCodeGenerationFormField extends StatelessWidget {
  const DynamicCodeGenerationFormField(this.params, {super.key,
    this.ignoreTypes = const ['Columns', 'Rows'],
    required this.builder,
    required this.noData,
    required this.wrapper
  });
  final Map params;
  final List<String> ignoreTypes;
  List<Map> get items => (toList(params['formColumns']).whereType<Map>()).toList();
  final Widget Function(Widget child) builder;
  final Widget Function(Widget child) noData;
  // final Function(String key, dynamic value) onChanged;
  final FormFieldWrapperFunc wrapper;

  @override
  Widget build(BuildContext context) {
    if(!empty(params['isCustomFormDetailLayout'])) {
      switch (params['formDetailLayout']) {
        default:
          return Text(params['formDetailLayout']);
      }
    }


    bool isDisplay(Map e){
      if(!empty(e['displayCode']) && !empty(e['displayValue'], true)){
        return e['displayValue'] == params[e['displayCode']];
      }
      return e['code'] != e['title'];
    }

    final items = this.items.where((e) => !ignoreTypes.contains(e['type'])
        && isDisplay(e));

    if(items.isNotEmpty){
      return builder(BoxContent(
          padding: EdgeInsets.all(contentPaddingBase),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              spacing: contentPaddingBase,
              children: items.map<Widget>((e){
                final type = e['type'];
                switch(type){
                  case 'Text':
                    return wrapper<String>(e['code'],
                      builder: (context, data, onChanged){
                        return FormTextField(
                          value: data.getValue(),
                          onChanged: (val){
                            onChanged(val);
                          },
                          labelText: e['title'] ?? '',
                          errorText: data.error,
                          focusNode: data.focusNode(),
                          required: toList(e['rules']).firstWhereOrNull((e) => e['type'] == 'required') != null,
                        );
                      }
                    );
                }
                return Container();
              }).toList(),
            ),
          )
      ));
    }
    return noData(
        NoData()
    );
  }
}