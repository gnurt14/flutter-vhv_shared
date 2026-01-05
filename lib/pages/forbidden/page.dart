import 'package:vhv_core/vhv_core.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('403'),
      ),
      body: Center(
          child: Text("BẠN KHÔNG CÓ QUYỀN TRUY CẬP.".lang())),
    );
  }
}
