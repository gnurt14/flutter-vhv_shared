import 'package:vhv_core/vhv_core.dart';
import 'bloc.dart';
export 'bloc.dart';

class LoginVerifyPage extends StatelessWidget {
  const LoginVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginVerifyBloc(),
      child: const _ExtraLoginVerifyVerifyContent(),
    );
  }
}
class _ExtraLoginVerifyVerifyContent extends StatefulWidget {
  const _ExtraLoginVerifyVerifyContent();

  @override
  State<_ExtraLoginVerifyVerifyContent> createState() => _ExtraLoginVerifyVerifyContentState();
}

class _ExtraLoginVerifyVerifyContentState extends State<_ExtraLoginVerifyVerifyContent> {
  late TextEditingController otpController;
  @override
  void initState() {
    otpController = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginVerifyBloc>();
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: BaseAppBar(

        context: context,
        leading: const SizedBox.shrink(),
        elevation: 0.5,
        title: Text('Xác thực đăng nhập'.lang()),
        actions: [
          IconButton(onPressed: (){
            account.logout();
          }, icon: const Icon(ViIcons.log_out))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BaseFormWidget<LoginVerifyBloc, BaseFormState>(
              builder: (context, state, wrapper){
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text('Mã xác thực'.lang(), textAlign: TextAlign.center, style: AppTextStyles.titleLarge?.setFontWeight(FontWeight.w600),),
                      h20,
                      wrapper<String>('verify',
                          builder: (context, data, onChanged){
                            return FormOTPField(
                              hasError: false,
                              onChanged: (val){
                                onChanged(val);
                              },
                              builder: (code) {
                                if (!empty(code) && code != data.getValue()) {
                                  onChanged(code);
                                  safeCallback((){
                                    otpController.text = code ?? '';
                                  });
                                }
                              },
                              controller: otpController,
                            );
                          }
                      ),
                      SizedBox(
                        height: 48,
                        child: Align(
                          alignment: Alignment.center,
                          child: ValueListenableBuilder<int>(
                              valueListenable: bloc.timer,
                              builder: (context, time, child){
                                if(time == 0){
                                  return TextButton(onPressed: (){
                                    bloc.sendOTP();
                                  }, child: Text('Nhận mã xác thực'.lang(), style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16
                                  ),));
                                }
                                return Text('${'Nhập lại sau'.lang()} ${durationToTime(Duration(seconds: time))}', style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16
                                ),);
                              }
                          ),
                        ),
                      ).marginOnly(
                        top: 15
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          BlocSelector<LoginVerifyBloc, BaseFormState, bool>(
              selector: (state) => state.fields['verify'].toString().length == 6,
              builder: (c, hasNext){
                return MultiActionsBottom(
                  actions: [
                    ItemMenuAction(label: 'Xác thực'.lang(), iconData: ViIcons.check, key: 'verify')
                  ],
                  onChanged: (_){
                    bloc.add(SubmitBaseForm());
                  },
                );
              }
          )
        ],
      ),
    );
  }
}