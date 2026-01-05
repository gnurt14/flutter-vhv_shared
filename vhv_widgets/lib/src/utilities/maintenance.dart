import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class Maintenance extends StatefulWidget {
  const Maintenance({super.key, this.message});
  final String? message;

  @override
  State<Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(!empty(AppInfo.logo))...[
                  SvgViewer(
                    AppInfo.logo(context),
                    height: 35,
                  ),
                  const SizedBox(height: 50,),
                ],
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Center(
                      child: Image.asset('assets/images/maintenance.png', package: 'vhv_basic',),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Text(widget.message??"Hệ thống đang nâng cấp".lang())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
