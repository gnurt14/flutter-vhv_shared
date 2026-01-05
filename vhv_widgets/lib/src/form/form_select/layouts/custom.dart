import 'package:vhv_state/vhv_state.dart';

import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectCustom extends StatelessWidget {
  const FormSelectCustom({
    super.key,
    required this.options
  });
  final CustomOptions options;


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormSelectBloc, FormSelectState>(
      buildWhen: options.buildWhen,
      builder: (context, state){
        return options.builder(context, state);
      }
    );
  }
}